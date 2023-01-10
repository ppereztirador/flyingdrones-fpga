#ifndef ENC_LHE_H
#define ENC_LHE_H

#define PPP_MAX_IMAGES 64 //this value allows to compress images up to 4096 px widthwise
#define PR_QUANT_1 0.125
#define PR_QUANT_5 1

#define BLOCK_SIDE 40
#define SIDE_MIN 2
#define PPP_MAX_IMAGES 64 //this value allows to compress images up to 4096 px widthwise
#define PPP_MIN 1
#define PPP_MAX 8
#define QUANT_LUM0 8
#define QUANT_LUM1 16
#define QUANT_LUM2 24
#define QUANT_LUM3 32

#define SUBBLOCKS 4 //numer of subblocks per block side. 2 means 2x2=4 subblocks. Maximum is 4->16 subblocks
#define COLOR_SAMPLES 2//samples of color per subblock.  2=2x2 samples  3 = 3x3 samples. For example 2x2 samples at 4x4 subblocks-> 64 samples

//Este define para sacar a fichero binario los datos del encoder.
#define DEBUG
//#define OUTPUT_IMAGES
#ifdef OUTPUT_IMAGES
#define UPSAMPLING
#endif

#define BLOCK_SIDE 40
#define BLOCK_SIZE (BLOCK_SIDE * BLOCK_SIDE)

#define MAX_RESOLUTION_WIDTH 640
#define MAX_RESOLUTION_HEIGHT 480

#define GRID_WIDTH (MAX_RESOLUTION_WIDTH/BLOCK_SIDE)
#define GRID_HEIGHT (MAX_RESOLUTION_HEIGHT/BLOCK_SIDE)

#define TH_LIGHT2  512*1280*720*4/3*4/3
#define TH_LIGHT1  512*1280*720*4/3*3/4

#define HANDLE_ERROR( err ) (HandleError( err, __FILE__, __LINE__ ))

typedef struct sharedData {

	//datos originales
	uint8_t orig_Y[BLOCK_SIZE]; //imagen luminancia original y down final
	uint8_t hops[200]; //down horizontal y cuantizada
	uint8_t block_width, block_height;
	uint8_t downsampled_width_Y, downsampled_height_Y;
	//uint8_t max_hop;
	//int suma_difs;

	//array que usan computeTTL() y quantizer ()
	//cada funcion lo usa para una cosa distinta
	//uint8_t scanline_array[BLOCK_SIDE];
	//uint8_t scanline_array2[BLOCK_SIDE];

}shared_data;

typedef struct lhe_coding_context {

	uint8_t width_grid; //Ancho del grid de bloques (40 px de ancho por bloque)
	uint8_t height_grid; //Alto del grid de bloques
	int img_width;
	int img_height;

//	float compressionFactor[PPP_MAX_IMAGES][100];
	int ql;
	int frame;
	int is_black_white;
	int output_images;

//	float PR[GRID_WIDTH][GRID_HEIGHT][2];
//	uint16_t cache[128 * 256 * 7];
	float ppp[GRID_WIDTH][GRID_HEIGHT][2];
//	uint8_t cache_decoding[256 * 7 * 3];

	uint8_t hops[GRID_WIDTH][GRID_HEIGHT][BLOCK_SIZE]; //down horizontal y cuantizada
	uint8_t first_luma[GRID_WIDTH][GRID_HEIGHT];

	//el color se almacena hipersubmuestreado y ademas downsampleado segun los ppp

//	uint8_t color_YUV_U[GRID_WIDTH][GRID_HEIGHT][BLOCK_SIZE];//colorU en YUV444
//	uint8_t color_YUV_V[GRID_WIDTH][GRID_HEIGHT][BLOCK_SIZE];//colorV en YUV444
//	uint8_t color_U[GRID_WIDTH][GRID_HEIGHT][SUBBLOCKS*SUBBLOCKS];//colorU hiper submuestreado
//	uint8_t color_V[GRID_WIDTH][GRID_HEIGHT][SUBBLOCKS*SUBBLOCKS];//colorV hiper submuestreado
//	uint8_t color_downH[GRID_WIDTH][GRID_HEIGHT];//referido a color_U, color_V
//	uint8_t color_downV[GRID_WIDTH][GRID_HEIGHT];//referido a color_U, color_V

//	unsigned int is_lost_block[GRID_WIDTH * GRID_HEIGHT / 32];

} lhe_coding_context;

#endif
