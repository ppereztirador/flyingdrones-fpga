#include "xparameters.h"
#include "xgpio.h"

#include "platform/platform.h"
#include "ov5640/OV5640.h"
#include "ov5640/ScuGicInterruptController.h"
#include "ov5640/PS_GPIO.h"
#include "ov5640/AXI_VDMA.h"
#include "ov5640/PS_IIC.h"

#include "MIPI_D_PHY_RX.h"
#include "MIPI_CSI_2_RX.h"
#include "enc_lhe.h"
#include "entropic.hpp"

#define IRPT_CTL_DEVID 		XPAR_PS7_SCUGIC_0_DEVICE_ID
#define GPIO_DEVID			XPAR_PS7_GPIO_0_DEVICE_ID
#define GPIO_IRPT_ID			XPAR_PS7_GPIO_0_INTR
#define CAM_I2C_DEVID		XPAR_PS7_I2C_0_DEVICE_ID
#define CAM_I2C_IRPT_ID		XPAR_PS7_I2C_0_INTR
#define VDMA_DEVID			XPAR_AXIVDMA_0_DEVICE_ID
#define VDMA_MM2S_IRPT_ID	XPAR_FABRIC_AXI_VDMA_0_MM2S_INTROUT_INTR
#define VDMA_S2MM_IRPT_ID	XPAR_FABRIC_AXI_VDMA_0_S2MM_INTROUT_INTR
#define CAM_I2C_SCLK_RATE	100000

#define DDR_BASE_ADDR		XPAR_DDR_MEM_BASEADDR
#define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x0A000000)

#define GAMMA_BASE_ADDR     XPAR_AXI_GAMMACORRECTION_0_BASEADDR

#define BUFFER_ADDRESS		1
#define BUFFER_DATA			2
#define FIFO_CONFIG			1
#define FIFO_IN				2

#define HOP_MEM_INFO_SHIFT	16
#define HOP_MEM_HOP_MASK	0xFF
#define HOP_MEM_VAL_MASK	0x0F
#define HOP_MEM_BLK_MASK	0xF0
#define HOP_MEM_LUMA_MASK	0xFF00
#define HOP_MEM_PPPX_MASK	0x30000
#define HOP_MEM_PPPY_MASK	0xC0000
#define HOP_MEM_TILE_MASK	0x100000
#define HOP_MEM_VALID_MASK	0x20000000
#define HOP_MEM_EMPTY_MASK	0x40000000
#define HOP_MEM_FULL_MASK	0x80000000

using namespace digilent;

void pipeline_mode_change(AXI_VDMA<ScuGicInterruptController>& vdma_driver, OV5640& cam, VideoOutput& vid, Resolution res, OV5640_cfg::mode_t mode)
{
	//Bring up input pipeline back-to-front
	{
		vdma_driver.resetWrite();
		MIPI_CSI_2_RX_mWriteReg(XPAR_MIPI_CSI_2_RX_0_S_AXI_LITE_BASEADDR, CR_OFFSET, (CR_RESET_MASK & ~CR_ENABLE_MASK));
		MIPI_D_PHY_RX_mWriteReg(XPAR_MIPI_D_PHY_RX_0_S_AXI_LITE_BASEADDR, CR_OFFSET, (CR_RESET_MASK & ~CR_ENABLE_MASK));
		cam.reset();
	}

	{
		vdma_driver.configureWrite(timing[static_cast<int>(res)].h_active, timing[static_cast<int>(res)].v_active);
		Xil_Out32(GAMMA_BASE_ADDR, 3); // Set Gamma correction factor to 1/1.8
		//TODO CSI-2, D-PHY config here
		cam.init();
	}

	{
		vdma_driver.enableWrite();
		MIPI_CSI_2_RX_mWriteReg(XPAR_MIPI_CSI_2_RX_0_S_AXI_LITE_BASEADDR, CR_OFFSET, CR_ENABLE_MASK);
		MIPI_D_PHY_RX_mWriteReg(XPAR_MIPI_D_PHY_RX_0_S_AXI_LITE_BASEADDR, CR_OFFSET, CR_ENABLE_MASK);
		cam.set_mode(mode);
		cam.set_awb(OV5640_cfg::awb_t::AWB_ADVANCED);
	}

	//Bring up output pipeline back-to-front
	{
		vid.reset();
		vdma_driver.resetRead();
	}

	{
		vid.configure(res);
		vdma_driver.configureRead(timing[static_cast<int>(res)].h_active, timing[static_cast<int>(res)].v_active);
	}

	{
		vid.enable();
		vdma_driver.enableRead();
	}
}


/* GLOBAL*/
//int8_t array_hops[640*480];
/*-------*/

int main()
{
	//uint8_t array_hops[640*40];
	float pppx[GRID_WIDTH][1];
	float pppy[GRID_WIDTH][1];
	uint8_t first_luma[GRID_WIDTH][1];
	uint8_t hops[GRID_WIDTH][1][BLOCK_SIZE];
	int8_t array_hops[640*40];

	int tileIdx[16];
	int currentTile;

	lhe_coding_context lheCtx;

	init_platform();

	ScuGicInterruptController irpt_ctl(IRPT_CTL_DEVID);
	PS_GPIO<ScuGicInterruptController> gpio_driver(GPIO_DEVID, irpt_ctl, GPIO_IRPT_ID);
	PS_IIC<ScuGicInterruptController> iic_driver(CAM_I2C_DEVID, irpt_ctl, CAM_I2C_IRPT_ID, 100000);

	OV5640 cam(iic_driver, gpio_driver);
	AXI_VDMA<ScuGicInterruptController> vdma_driver(VDMA_DEVID, MEM_BASE_ADDR, irpt_ctl,
			VDMA_MM2S_IRPT_ID,
			VDMA_S2MM_IRPT_ID);
	VideoOutput vid(XPAR_VTC_0_DEVICE_ID, XPAR_VIDEO_DYNCLK_DEVICE_ID);

	// Configure GPIO for mem reads
	XGpio_Config *cfg_ptr;
	XGpio buffer_device;
	cfg_ptr = XGpio_LookupConfig(XPAR_AXI_GPIO_0_DEVICE_ID);
	XGpio_CfgInitialize(&buffer_device, cfg_ptr, cfg_ptr->BaseAddress);
	XGpio_SetDataDirection(&buffer_device, BUFFER_ADDRESS, 0x0000);
	//XGpio_SetDataDirection(&buffer_device, BUFFER_DATA, 0xFFFF);

	u32 sw_state_data = 0x6; // off fixed image and conflictive block gen
	XGpio_DiscreteWrite(&buffer_device, BUFFER_ADDRESS, sw_state_data);

	// Configure GPIO for FIFOs
	XGpio_Config *cfg_ptr_1;
	XGpio fifo_device;
	cfg_ptr_1 = XGpio_LookupConfig(XPAR_AXI_GPIO_1_DEVICE_ID);
	XGpio_CfgInitialize(&fifo_device, cfg_ptr_1, cfg_ptr_1->BaseAddress);
	XGpio_SetDataDirection(&fifo_device, FIFO_CONFIG, 0x0000);
	XGpio_SetDataDirection(&fifo_device, FIFO_IN, 0xFFFF);
	XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 0);

	int32_t fifo_count = 0;
	int32_t live_limit = 640*40;
	int32_t fifo_state;
	//int16_t fifo_data[100];

	// Set res
	pipeline_mode_change(vdma_driver, cam, vid, Resolution::R640_480_60_NN, OV5640_cfg::mode_t::MODE_VGA_640_480_60fps); //OV5640_cfg::mode_t::MODE_720P_1280_720_60fps
	//pipeline_mode_change(vdma_driver, cam, vid, Resolution::R1280_720_60_PP, OV5640_cfg::mode_t::MODE_720P_1280_720_60fps); //OV5640_cfg::mode_t::MODE_720P_1280_720_60fps

	xil_printf("Video init done.\r\n");

	sw_state_data = 0x2; // only off fixed image
	XGpio_DiscreteWrite(&buffer_device, BUFFER_ADDRESS, sw_state_data);

	// Liquid lens control
	uint8_t read_char0 = 0;
	uint8_t read_char1 = 0;
	uint8_t read_char2 = 0;
	uint8_t read_char4 = 0;
	uint8_t read_char5 = 0;
	uint16_t reg_addr;
	uint8_t reg_value;

	while (1) {
		xil_printf("\r\n\r\n\r\nPcam 5C MAIN OPTIONS\r\n");
		xil_printf("\r\nPlease press the key corresponding to the desired option:");
		xil_printf("\r\n  a. Change Resolution");
		xil_printf("\r\n  b. Change Liquid Lens Focus");
		xil_printf("\r\n  d. Change Image Format (Raw or RGB)");
		xil_printf("\r\n  e. Write a Register Inside the Image Sensor");
		xil_printf("\r\n  f. Read a Register Inside the Image Sensor");
		xil_printf("\r\n  g. Change Gamma Correction Factor Value");
		xil_printf("\r\n  h. Change AWB Settings");
		//xil_printf("\r\n  i. PRINT DEBUG\r\n\r\n");
		xil_printf("\r\n  i. Set demo switches");
		xil_printf("\r\n  j. Read FIFO");
		xil_printf("\r\n  k. Print FIFO\r\n\r\n");

		read_char0 = getchar();
		getchar();
		xil_printf("Read: %d\r\n", read_char0);

		switch(read_char0) {

		case 'a':
			xil_printf("\r\n  Please press the key corresponding to the desired resolution:");
			xil_printf("\r\n    0.  640 x 480, 60fps");
			xil_printf("\r\n    1. 1280 x 720, 30fps");
			xil_printf("\r\n    2. 1920 x 1080, 15fps");
			xil_printf("\r\n    3. 1920 x 1080, 30fps");
			read_char1 = getchar();
			getchar();
			xil_printf("\r\nRead: %d", read_char1);
			switch(read_char1) {
			case '0':
				pipeline_mode_change(vdma_driver, cam, vid, Resolution::R640_480_60_NN, OV5640_cfg::mode_t::MODE_VGA_640_480_60fps);
				xil_printf("Resolution change done.\r\n");
				break;
			case '1':
				pipeline_mode_change(vdma_driver, cam, vid, Resolution::R1280_720_60_PP, OV5640_cfg::mode_t::MODE_720P_1280_720_60fps);
				xil_printf("Resolution change done.\r\n");
				break;
			case '2':
				pipeline_mode_change(vdma_driver, cam, vid, Resolution::R1920_1080_60_PP, OV5640_cfg::mode_t::MODE_1080P_1920_1080_15fps);
				xil_printf("Resolution change done.\r\n");
				break;
			case '3':
				pipeline_mode_change(vdma_driver, cam, vid, Resolution::R1920_1080_60_PP, OV5640_cfg::mode_t::MODE_1080P_1920_1080_30fps);
				xil_printf("Resolution change done.\r\n");
				break;
			default:
				xil_printf("\r\n  Selection is outside the available options! Please retry...");
			}
			break;

		case 'b':
			xil_printf("\r\n\r\nPlease enter value of liquid lens register, in hex, with small letters: 0x");
			//A, B, C,..., F need to be entered with small letters
			while (read_char1 < 48) {
				read_char1 = getchar();
			}
			while (read_char2 < 48) {
				read_char2 = getchar();
			}
			getchar();
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char1 <= 57) {
				read_char1 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char1 -= 87;
			}
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char2 <= 57) {
				read_char2 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char2 -= 87;
			}
			cam.writeRegLiquid((uint8_t) (16*read_char1 + read_char2));
			xil_printf("\r\nWrote to liquid lens controller: %x", (uint8_t) (16*read_char1 + read_char2));
			break;

		case 'd':
			xil_printf("\r\n  Please press the key corresponding to the desired setting:");
			xil_printf("\r\n    1. Select image format to be RGB, output still Raw");
			xil_printf("\r\n    2. Select image format & output to both be Raw");
			read_char1 = getchar();
			getchar();
			xil_printf("\r\nRead: %d", read_char1);
			switch(read_char1) {
			case '1':
				cam.set_isp_format(OV5640_cfg::isp_format_t::ISP_RGB);
				xil_printf("Settings change done.\r\n");
				break;
			case '2':
				cam.set_isp_format(OV5640_cfg::isp_format_t::ISP_RAW);
				xil_printf("Settings change done.\r\n");
				break;
			default:
				xil_printf("\r\n  Selection is outside the available options! Please retry...");
			}
			break;

		case 'e':
			xil_printf("\r\nPlease enter address of image sensor register, in hex, with small letters: \r\n");
			//A, B, C,..., F need to be entered with small letters
			while (read_char1 < 48) {
				read_char1 = getchar();
			}
			while (read_char2 < 48) {
				read_char2 = getchar();
			}
			while (read_char4 < 48) {
				read_char4 = getchar();
			}
			while (read_char5 < 48) {
				read_char5 = getchar();
			}
			getchar();
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char1 <= 57) {
				read_char1 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char1 -= 87;
			}
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char2 <= 57) {
				read_char2 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char2 -= 87;
			}
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char4 <= 57) {
				read_char4 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char4 -= 87;
			}
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char5 <= 57) {
				read_char5 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char5 -= 87;
			}
			reg_addr = 16*(16*(16*read_char1 + read_char2)+read_char4)+read_char5;
			xil_printf("Desired Register Address: %x\r\n", reg_addr);

			read_char1 = 0;
			read_char2 = 0;
			xil_printf("\r\nPlease enter value of image sensor register, in hex, with small letters: \r\n");
			//A, B, C,..., F need to be entered with small letters
			while (read_char1 < 48) {
				read_char1 = getchar();
			}
			while (read_char2 < 48) {
				read_char2 = getchar();
			}
			getchar();
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char1 <= 57) {
				read_char1 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char1 -= 87;
			}
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char2 <= 57) {
				read_char2 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char2 -= 87;
			}
			reg_value = 16*read_char1 + read_char2;
			xil_printf("Desired Register Value: %x\r\n", reg_value);
			cam.writeReg(reg_addr, reg_value);
			xil_printf("Register write done.\r\n");

			break;

		case 'f':
			xil_printf("Please enter address of image sensor register, in hex, with small letters: \r\n");
			//A, B, C,..., F need to be entered with small letters
			while (read_char1 < 48) {
				read_char1 = getchar();
			}
			while (read_char2 < 48) {
				read_char2 = getchar();
			}
			while (read_char4 < 48) {
				read_char4 = getchar();
			}
			while (read_char5 < 48) {
				read_char5 = getchar();
			}
			getchar();
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char1 <= 57) {
				read_char1 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char1 -= 87;
			}
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char2 <= 57) {
				read_char2 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char2 -= 87;
			}
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char4 <= 57) {
				read_char4 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char4 -= 87;
			}
			// If character is a digit, convert from ASCII code to a digit between 0 and 9
			if (read_char5 <= 57) {
				read_char5 -= 48;
			}
			// If character is a letter, convert ASCII code to a number between 10 and 15
			else {
				read_char5 -= 87;
			}
			reg_addr = 16*(16*(16*read_char1 + read_char2)+read_char4)+read_char5;
			xil_printf("Desired Register Address: %x\r\n", reg_addr);

			cam.readReg(reg_addr, reg_value);
			xil_printf("Value of Desired Register: %x\r\n", reg_value);

			break;

		case 'g':
			xil_printf("  Please press the key corresponding to the desired Gamma factor:\r\n");
			xil_printf("    1. Gamma Factor = 1\r\n");
			xil_printf("    2. Gamma Factor = 1/1.2\r\n");
			xil_printf("    3. Gamma Factor = 1/1.5\r\n");
			xil_printf("    4. Gamma Factor = 1/1.8\r\n");
			xil_printf("    5. Gamma Factor = 1/2.2\r\n");
			read_char1 = getchar();
			getchar();
			xil_printf("Read: %d\r\n", read_char1);
			// Convert from ASCII to numeric
			read_char1 = read_char1 - 48;
			if ((read_char1 > 0) && (read_char1 < 6)) {
				Xil_Out32(GAMMA_BASE_ADDR, read_char1-1);
				xil_printf("Gamma value changed to 1.\r\n");
			}
			else {
				xil_printf("  Selection is outside the available options! Please retry...\r\n");
			}
			break;

		case 'h':
			xil_printf("  Please press the key corresponding to the desired AWB change:\r\n");
			xil_printf("    1. Enable Advanced AWB\r\n");
			xil_printf("    2. Enable Simple AWB\r\n");
			xil_printf("    3. Disable AWB\r\n");
			read_char1 = getchar();
			getchar();
			xil_printf("Read: %d\r\n", read_char1);
			switch(read_char1) {
			case '1':
				cam.set_awb(OV5640_cfg::awb_t::AWB_ADVANCED);
				xil_printf("Enabled Advanced AWB\r\n");
				break;
			case '2':
				cam.set_awb(OV5640_cfg::awb_t::AWB_SIMPLE);
				xil_printf("Enabled Simple AWB\r\n");
				break;
			case '3':
				cam.set_awb(OV5640_cfg::awb_t::AWB_DISABLED);
				xil_printf("Disabled AWB\r\n");
				break;
			default:
				xil_printf("  Selection is outside the available options! Please retry...\r\n");
			}
			break;

		case 'i':
//			u32 buffer_read_data, buffer_high_data, buffer_low_data;
//			xil_printf("ADDR\tNUM\tDEN\r\n");
//			for (u32 ii=0; ii<192; ii++) {
//				XGpio_DiscreteWrite(&buffer_device, BUFFER_ADDRESS, ((ii<<8) + ii));
//				buffer_read_data = XGpio_DiscreteRead(&buffer_device, BUFFER_DATA);
//				buffer_high_data = buffer_read_data >> 16;
//				buffer_low_data = buffer_read_data - (buffer_high_data << 16);
//				xil_printf("%d\t%d\t%d\r\n", ii, buffer_high_data, buffer_low_data);
//			}
			xil_printf("  Please press the key corresponding to the stage:\r\n");
			xil_printf("    1. Switch stage 1 (luminance/image)  [%c]\r\n", ((sw_state_data == 0x3) ? ' ' : (sw_state_data & 0x2) ? 'L' : 'i'));
			xil_printf("    2. Switch stage 2 (block generation) [%c]\r\n", ((sw_state_data & 0x4) ? ' ' : 'o'));
			xil_printf("    3. Switch stage 3 (PR)               [%c]\r\n", ((sw_state_data & 0x8) ? ' ' : 'o'));
			xil_printf("    0. Switch PR (H/V)                   [%c]\r\n", ((sw_state_data & 0x80000000) ? 'V' : 'H'));

			read_char1 = getchar();
			getchar();
			xil_printf("Read: %d\r\n", read_char1);
			switch(read_char1) {
			case '0':
				sw_state_data ^= 0x80;
				XGpio_DiscreteWrite(&buffer_device, BUFFER_ADDRESS, sw_state_data);
				break;
			case '1':
				if ((sw_state_data & 0x1) && (sw_state_data & 0x2)) { // if off
					sw_state_data ^= 0x1;
				}
				else if (sw_state_data & 0x2) { // if 2
					sw_state_data ^= 0x3; // off 2 on 1
				}
				else {
					sw_state_data ^= 0x2; // on 2
				}

				XGpio_DiscreteWrite(&buffer_device, BUFFER_ADDRESS, sw_state_data);
				break;
			/*case '2':
				sw_state_data ^= 0x2;
				XGpio_DiscreteWrite(&buffer_device, BUFFER_ADDRESS, sw_state_data);
				break;*/
			case '2':
				sw_state_data ^= 0x4;
				XGpio_DiscreteWrite(&buffer_device, BUFFER_ADDRESS, sw_state_data);
				break;
			case '3':
				sw_state_data ^= 0x8;
				XGpio_DiscreteWrite(&buffer_device, BUFFER_ADDRESS, sw_state_data);
				break;
			default:
				xil_printf("  Selection is outside the available options! Please retry...\r\n");
			}

			break;

		case 'j':
			initContext(&lheCtx);
				xil_printf("Allocation OK\r\n");
			fifo_count = 0;
			for (int i=0; i<16; i++)
				tileIdx[i] = 0;

			// Reset component
			XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 0x1000000);
			XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 0);
			for (int i=0;i<100;i++); // Remove delay if necessary
			XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 0x800000);
			XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 0);

			// Read in main memory
			fifo_state = XGpio_DiscreteRead(&fifo_device, FIFO_IN);
			while ((fifo_state & HOP_MEM_EMPTY_MASK)!=0) {
				XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, fifo_count);
				fifo_state = XGpio_DiscreteRead(&fifo_device, FIFO_IN);
			}

			while (fifo_count<(640*40) && (fifo_count<live_limit)) {
				//if ((fifo_state & HOP_MEM_TILE_MASK)==0) {
					//array_hops[fifo_count] = (uint8_t) (fifo_state & HOP_MEM_HOP_MASK);
					currentTile = (int) (fifo_state & HOP_MEM_BLK_MASK)>>4;

					if (tileIdx[currentTile]<1600) {
						hops[currentTile][0][tileIdx[currentTile]] = (uint8_t) (fifo_state & HOP_MEM_VAL_MASK);
					}

					if(fifo_count<16) {
						 //If it's 1st occurrence of this tile, update info
						pppx[fifo_count][0] = (float) (1 << ((fifo_state & HOP_MEM_PPPX_MASK)>>16));
						pppy[fifo_count][0] = (float) (1 << ((fifo_state & HOP_MEM_PPPY_MASK)>>18));
						first_luma[fifo_count][0] = (uint8_t) ((fifo_state & HOP_MEM_LUMA_MASK)>>8);

						// Update limit to the size of the PPPs
						//live_limit -= 1600 - ((40/pppx[currentTile][0])*(40/pppy[currentTile][0]));
					}

					tileIdx[currentTile] ++;

					//fifo_count++;
				//} //else {
					//array_hops[fifo_count] = 0xFF;
				//}
				fifo_count++;

				//array_hops[fifo_count] = 0;
				XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, fifo_count);
				fifo_state = XGpio_DiscreteRead(&fifo_device, FIFO_IN);

				while ((fifo_state & HOP_MEM_EMPTY_MASK)!=0) {
					//XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, fifo_count);
					fifo_state = XGpio_DiscreteRead(&fifo_device, FIFO_IN);
				}
			}

			// Update context
			for (int i=0; i<16; i++) {
				xil_printf("%d ",i);
				addToContext(&lheCtx, i, 0, pppx[i][0], pppy[i][0], first_luma[i][0], hops[i][0]);
			}
			break;

		case 'k':

			for (int i=0; i<16; i++) {
				for (int j=0; j<1600; j++) {
					xil_printf("%d,%d: %X\r\n", i, j, hops[i][0][j]);
				}
			}
			xil_printf("FIFO count: %d\r\n", fifo_count);

			break;

		case 'l': // Send context as is
			for (int i=0; i<16; i++) {
				xil_printf("i=%d  - ", i);
				xil_printf("PPPX: %d, ", (int)lheCtx.ppp[i][0][0]);
				xil_printf("PPPY: %d, ", (int)lheCtx.ppp[i][0][1]);
				xil_printf("1LUMA: %d\r\n", lheCtx.first_luma[i][0]);
			}

			for (int i=0; i<16; i++) {
				xil_printf("TILE %d\r\n", i);

				unsigned int hop_size = (BLOCK_SIDE / lheCtx.ppp[i][0][0]) * (BLOCK_SIDE / lheCtx.ppp[i][0][1]);
				for (unsigned int k=0; k<hop_size; k++) {
					xil_printf("%d\r\n", lheCtx.hops[i][0][k]);
				}
			}
			break;

		case 'm': // Send only in binary
			uint16_t ii, jj, hop_size;
			uint8_t temp_send;

			for (ii=0; ii<576; ii++) {
				if (ii<16) {
					fwrite(&ii, 1, sizeof(uint16_t), stdout); //Block
					temp_send = 0;
					fwrite(&temp_send, 1, sizeof(uint8_t), stdout); // Frame
					temp_send = 1;
					fwrite(&temp_send, 1, sizeof(uint8_t), stdout); // BW

					temp_send = (uint8_t) lheCtx.ppp[ii][0][0]; //PPPX
					fwrite(&temp_send, 1, sizeof(uint8_t), stdout);
					temp_send = (uint8_t) lheCtx.ppp[ii][0][1]; //PPPY
					fwrite(&temp_send, 1, sizeof(uint8_t), stdout);
					temp_send = (uint8_t) lheCtx.first_luma[ii][0]; //LUMA
					fwrite(&temp_send, 1, sizeof(uint8_t), stdout);

					hop_size = (BLOCK_SIDE / lheCtx.ppp[ii][0][0]) * (BLOCK_SIDE / lheCtx.ppp[ii][0][1]);
					for (jj=0; jj<hop_size; jj++) {
						temp_send = (uint8_t) lheCtx.hops[ii][0][jj];
						fwrite(&temp_send, 1, sizeof(uint8_t), stdout);
					}
				}

				else {
					fwrite(&ii, 1, sizeof(uint16_t), stdout); //Block
					temp_send = 0;
					fwrite(&temp_send, 1, sizeof(uint8_t), stdout); // Frame
					temp_send = 1;
					fwrite(&temp_send, 1, sizeof(uint8_t), stdout); // BW

					temp_send = (uint8_t) 8; //PPPX
					fwrite(&temp_send, 1, sizeof(uint8_t), stdout);
					temp_send = (uint8_t) 8; //PPPY
					fwrite(&temp_send, 1, sizeof(uint8_t), stdout);
					temp_send = (uint8_t) 0; //LUMA
					fwrite(&temp_send, 1, sizeof(uint8_t), stdout);

					hop_size = (BLOCK_SIDE / 8) * (BLOCK_SIDE / 8);
					for (jj=0; jj<hop_size; jj++) {
						temp_send = (uint8_t) 4;
						fwrite(&temp_send, 1, sizeof(uint8_t), stdout);
					}
				}
			}

			break;


		case '0':
			fifo_count = 0;
			// Reset component
			XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 0x1000000);
			XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 0);
			for (int i=0;i<100;i++); // Remove delay if necessary
			XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 0x800000);
			XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 0);

			// Read in main memory
			fifo_state = XGpio_DiscreteRead(&fifo_device, FIFO_IN);
			while ((fifo_state & HOP_MEM_EMPTY_MASK)!=0) {
				XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, fifo_count);
				fifo_state = XGpio_DiscreteRead(&fifo_device, FIFO_IN);
			}

			for (fifo_count=0; fifo_count<(640*40); fifo_count++) {

				//fifo_state = XGpio_DiscreteRead(&fifo_device, FIFO_IN);
				/*while (fifo_state & 0x20000) {
					//Wait
					XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 2);
					fifo_state = XGpio_DiscreteRead(&fifo_device, FIFO_IN);
				};*/

//				array_hops[fifo_count] = (int8_t) fifo_state & 0xF;
//
//				if(fifo_count<16) {
//					//If it's 1st occurrence of this tile, update info
//					pppx[fifo_count][0] = (float) (1 << ((fifo_state & HOP_MEM_PPPX_MASK)>>16));
//					pppy[fifo_count][0] = (float) (1 << ((fifo_state & HOP_MEM_PPPY_MASK)>>18));
//					first_luma[fifo_count][0] = (uint8_t) ((fifo_state & HOP_MEM_LUMA_MASK)>>8);
//				}

				//				if (fifo_state & 0x10000) {
				//					xil_printf("%d, FULL!!\r\n", i);
				//				}
				//			}
				//
				//			XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, 0);
				//
				//			for (int i=0; i<100; i++) {
				//				xil_printf("%d: %X\r\n", i, fifo_data[i]);
				//			}
				//			xil_printf("FIFO count: %d\r\n", fifo_count);

				XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, fifo_count);
				fifo_state = XGpio_DiscreteRead(&fifo_device, FIFO_IN);

				while ((fifo_state & HOP_MEM_EMPTY_MASK)!=0) {
					//XGpio_DiscreteWrite(&fifo_device, FIFO_CONFIG, fifo_count);
					fifo_state = XGpio_DiscreteRead(&fifo_device, FIFO_IN);
				}
			}

			break;

		default:
			xil_printf("  Selection is outside the available options! Please retry...\r\n");
		}

		read_char1 = 0;
		read_char2 = 0;
		read_char4 = 0;
		read_char5 = 0;
	}


	cleanup_platform();

	return 0;
}
