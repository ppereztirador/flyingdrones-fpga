#include "entropic.hpp"
#include "put_bits.h"

#include <fstream>
#include <iostream>
#include "xil_printf.h"


void initContext(lhe_coding_context *lheCtx) {
	// Copy the data into the context (for 1 frame)

	unsigned int i, j, k;

	lheCtx->width_grid = 40;
	lheCtx->height_grid = 40;
	lheCtx->img_width = 640;
	lheCtx->img_height = 480;
	lheCtx->frame = 0;
	lheCtx->is_black_white = 0;
	for (i=0; i<GRID_WIDTH; i++) {
//		xil_printf("%d\r\n", i);
		for (j=0; j<GRID_HEIGHT; j++) {
//			xil_printf("%d\r\n", j);
			lheCtx->ppp[i][j][0] = 0;
			lheCtx->ppp[i][j][1] = 0;
			lheCtx->first_luma[i][j] = 0;

//			for (k=0; k<BLOCK_SIZE; k++) {
//				xil_printf("%d ", k);
//				lheCtx->hops[i][j][k] = 0;
//			}
		}
	}

}

void newFrame(lhe_coding_context *lheCtx) {
	lheCtx->frame ++;
}

void addToContext(lhe_coding_context *lheCtx, int grid_w, int grid_h, float pppx,
		float pppy, uint8_t first_luma, uint8_t hops[BLOCK_SIZE]) {
	// Copy the data into the context (for 1 frame)

	unsigned int i, j, k;
	unsigned int hop_size;

	lheCtx->is_black_white = 0;
	lheCtx->ppp[grid_w][grid_h][0] = pppx;
	lheCtx->ppp[grid_w][grid_h][1] = pppy;
	lheCtx->first_luma[grid_w][grid_h] = first_luma;

	hop_size = (BLOCK_SIDE / pppx) * (BLOCK_SIDE / pppy);
	for (k=0; k<hop_size; k++) {
		lheCtx->hops[grid_w][grid_h][k] = hops[k];
	}

}

void buildContext(lhe_coding_context *lheCtx, float pppx[GRID_WIDTH][GRID_HEIGHT],
		float pppy[GRID_WIDTH][GRID_HEIGHT], uint8_t first_luma[GRID_WIDTH][GRID_HEIGHT],
		uint8_t hops[GRID_WIDTH][GRID_HEIGHT][BLOCK_SIZE]) {
	// Copy the data into the context (for 1 frame)

	unsigned int i, j, k;
	unsigned int hop_size;

	lheCtx->frame ++;
	lheCtx->is_black_white = 0;
	for (i=0; i<GRID_WIDTH; i++) {
		for (j=0; j<GRID_HEIGHT; j++) {
			lheCtx->ppp[i][j][0] = pppx[i][j];
			lheCtx->ppp[i][j][1] = pppy[i][j];
			lheCtx->first_luma[i][j] = first_luma[i][j];

			hop_size = (BLOCK_SIDE / pppx[i][j]) * (BLOCK_SIDE / pppy[i][j]);
			for (k=0; k<hop_size; k++) {
				lheCtx->hops[i][j][k] = hops[i][j][k];
			}
		}
	}

}

size_t encodeHuffman(lhe_coding_context *lheCtx, unsigned int block_range_start,
                     unsigned int block_range_size, unsigned char *destination,
                     size_t destinationAllocatedSize) {

  const unsigned char ppp_conversion[9] = {0, 0, 1, 0, 2, 0, 0, 0, 3};
  const size_t longHop[9] = {8, 7, 5, 3, 1, 2, 4, 6, 8};
  const size_t valueHop[9] = {1, 1, 1, 1, 1, 1, 1, 1, 0};
  PutBitContext put;
  init_put_bits(&put, destination, destinationAllocatedSize);

  unsigned char frame = lheCtx->frame % FRAME_COUNTER_SIZE;
  unsigned char range;
  unsigned int destIndex = 0;
  if (block_range_size > BLOCKS_SIZE_MULTIPIER * 4) {
    xil_printf("WARNING: Se quiere enviar más bloques de los que se puede indicar. Se quiere enviar %d en su lugar se va a indicar %d\r\n",
               block_range_size,
               BLOCKS_SIZE_MULTIPIER * 4);
    range = 3;
  } else if (block_range_size < BLOCKS_SIZE_MULTIPIER) {
    xil_printf("WARNING: Se quiere enviar tan pocos bloques que no se puede. Se quiere enviar %d en su lugar se va a descartar el paquete\r\n",
               block_range_size);
    return 0;
  }
  if (block_range_size % BLOCKS_SIZE_MULTIPIER != 0) {
    xil_printf("WARNING: Se quiere enviar un número de bloques que no es múltiplo del multiplicador. Se quiere enviar %d en su lugar se va a enviar %d",
              block_range_size,
              (block_range_size / BLOCKS_SIZE_MULTIPIER) * BLOCKS_SIZE_MULTIPIER);
    range = (block_range_size / BLOCKS_SIZE_MULTIPIER) - 1;
  } else {
    range = (block_range_size / BLOCKS_SIZE_MULTIPIER) - 1;
  }
  int block = block_range_start;
  if (block > 1024) {
    xil_printf("WARNING: El bloque de inicio a enviar es más grande que los bits que se tienen para indicar. Se quiere indicar como inicio %d en su lugar se va a enviar %d\r\n",
               block_range_start,
			   1023);
    block = 1023;
  }

  put_bits(&put, 4, frame);
  put_bits(&put, 2, range);
  put_bits(&put, 10, block);

  // Rellenar el buffer intermedio con los datos del contexto
  for (unsigned int block = block_range_start;
       block < block_range_start + block_range_size; block++) {

    unsigned int block_x = block % lheCtx->width_grid;
    unsigned int block_y = block / lheCtx->width_grid;

    // Pongo los PPS convertidos a binario, ambos en un byte
    unsigned int pppx = lheCtx->ppp[block_x][block_y][0];
    unsigned int pppy = lheCtx->ppp[block_x][block_y][1];
    unsigned int is_black_white = lheCtx->is_black_white;
    put_bits(&put, 1, is_black_white);
    put_bits(&put, 1, 0);
    put_bits(&put, 2, ppp_conversion[pppx]);
    put_bits(&put, 2, 0);
    put_bits(&put, 2, ppp_conversion[pppy]);

    // Primera muestra de luminancia
    put_bits(&put, 8, lheCtx->first_luma[block_x][block_y]);

    // Colores
    if (!is_black_white) {
//      for (int y = 0; y < lheCtx->color_downV[block_x][block_y]; y++) {
//        for (int x = 0; x < lheCtx->color_downH[block_x][block_y]; x++) {
//          put_bits(&put, 5,
//                   lheCtx->color_U[block_x][block_y][y * SUBBLOCKS + x] >> 3);
//          put_bits(&put, 5,
//                   lheCtx->color_V[block_x][block_y][y * SUBBLOCKS + x] >> 3);
//        }
//      }

    	xil_printf("ONLY DESIGNED FOR B/W\r\n");
    }
    // Pongo los hops con el tamaño de ppp
    unsigned int hop_size = (BLOCK_SIDE / pppx) * (BLOCK_SIDE / pppy);
    for (unsigned int i = 0; i < hop_size; i++) {
      put_bits(&put, longHop[lheCtx->hops[block_x][block_y][i]],
               valueHop[lheCtx->hops[block_x][block_y][i]]);
    }
  }
  put_bits_flush(&put);
  return (put_bits_count(&put) + 7) / 8;
}
