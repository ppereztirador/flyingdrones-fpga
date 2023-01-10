#ifndef ENTROPIC_HPP
#define ENTROPIC_HPP

#include <cstring>
#include <string>
#include <vector>


#define FRAME_COUNTER_SIZE 16
#define BLOCKS_SIZE_MULTIPIER 8

#include "enc_lhe.h"

/**
 * @brief Serializes the lhe context into a buffer to be encoded by the
 * entropic. Suply the range of blocks that you want to encode.
 * @param inputBuilder The buffer that is going to be filled with the serialized
 * coding context.
 * @param lheCtx The context of the encoding must be supplied with a complete
 * frame.
 * @param block_range_start The first block that you want to serialize.
 * @param block_range_size how many blocks you want to encode.
 */
//void lheContextIntoBuffer(std::vector<char> &inputBuilder,
//                          lhe_coding_context &lheCtx,
//                          unsigned int block_range_start,
//                          unsigned int block_range_size);

/**
 * @brief Extracts from a given named pipe the stream and process it into a
 * buffer to be consumed by the entropic encoder
 * @param inputBuilder The buffer that is going to be filled with the serialized
 * coding context.
 * @param file Opened handler to the file that is being used as interface for
 * the fpga
 * @param block_size Number of blocks to be processed from the file
 */
//void fpgaFormatIntoBuffer(std::vector<char> &inputBuilder, std::ifstream &file,
//                          unsigned int block_size);

/**
 * @brief Retrive the size of the encoded as it were Huffman
 * @param lheCtx Coding context to be tranformed into binary
 * @param block_range_start The first block that you want to serialize.
 * @param block_range_size how many blocks you want to encode.
 * @return The size of the data if it huffman were used
 */
//size_t getHuffmanSize(lhe_coding_context &lheCtx,
//                      unsigned int block_range_start,
//                      unsigned int block_range_size);


size_t encodeHuffman(lhe_coding_context *lheCtx, unsigned int block_range_start,
                     unsigned int block_range_size, unsigned char *destination,
                     size_t destinationAllocatedSize);

size_t fpgaFormatIntoHuffman(char* file, void *destination,
                                   size_t destinationAllocatedSize);

void initContext(lhe_coding_context *lheCtx);
void newFrame(lhe_coding_context *lheCtx);
void addToContext(lhe_coding_context *lheCtx, int grid_w, int grid_h, float pppx,
		float pppy, uint8_t first_luma, uint8_t hops[BLOCK_SIZE]);
void buildContext(lhe_coding_context *lheCtx, float pppx[GRID_WIDTH][GRID_HEIGHT],
		float pppy[GRID_WIDTH][GRID_HEIGHT], uint8_t first_luma[GRID_WIDTH][GRID_HEIGHT],
		uint8_t hops[GRID_WIDTH][GRID_HEIGHT][BLOCK_SIZE]);

size_t encodeHuffman(lhe_coding_context *lheCtx, unsigned int block_range_start,
                     unsigned int block_range_size, unsigned char *destination,
                     size_t destinationAllocatedSize);

#endif /* ENTROPIC_HPP */
