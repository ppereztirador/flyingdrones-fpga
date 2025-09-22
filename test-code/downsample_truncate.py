import numpy as np

def downsampleH_truncate(image, block_width, ppp, downsample_width):
    imageDown = np.zeros(image.shape)
    numBlocksV = int(image.shape[0]/block_width)
    numBlocksH = int(image.shape[1]/block_width)
    
    for blockV in range(numBlocksV):
        for blockH in range(numBlocksH):
            dsw_block = int(downsample_width[blockV,blockH])
            ppp_block = int(ppp[blockV,blockH])
            
            for j in range(block_width):
                vIdx = blockV*block_width+j
                for i in range(dsw_block):
                    imageDown[vIdx, blockH*block_width + i] = int(np.sum(image[vIdx, blockH*block_width+ppp_block*i:blockH*block_width+ppp_block*i+ppp_block]) / ppp_block)
    
    return imageDown

def downsampleV_truncate(image, block_width, ppp, downsample_width):
    imageDown = np.zeros(image.shape)
    numBlocksV = int(image.shape[0]/block_width)
    numBlocksH = int(image.shape[1]/block_width)
    
    for blockV in range(numBlocksV):
        for blockH in range(numBlocksH):
            dsw_block = int(downsample_width[blockV,blockH])
            ppp_block = int(ppp[blockV,blockH])
            
            for j in range(block_width):
                hIdx = blockH*block_width+j
                for i in range(dsw_block):
                    #imageDown[blockV*block_width+i, hIdx] = np.sum(image[(i*ppp_block)*block_width+blockV:(i*ppp_block+ppp_block)*block_width+blockV, hIdx]) / ppp_block
                    imageDown[blockV*block_width+i, hIdx] = int(np.sum(image[block_width*blockV+ppp_block*i:block_width*blockV+ppp_block*i+ppp_block, hIdx]) / ppp_block)
                    
    return imageDown

def downsampleHfill_truncate(image, block_width, ppp, downsample_width):
    imageDown = np.zeros(image.shape)
    numBlocksV = int(image.shape[0]/block_width)
    numBlocksH = int(image.shape[1]/block_width)
    
    for blockV in range(numBlocksV):
        for blockH in range(numBlocksH):
            dsw_block = int(downsample_width[blockV,blockH])
            ppp_block = int(ppp[blockV,blockH])
            
            for j in range(block_width):
                vIdx = blockV*block_width+j
                for i in range(dsw_block):
                    imageDown[vIdx, blockH*block_width+ppp_block*i:blockH*block_width+ppp_block*i+ppp_block] = int(np.sum(image[vIdx, blockH*block_width+ppp_block*i:blockH*block_width+ppp_block*i+ppp_block]) / ppp_block)
    
    return imageDown

def downsampleVfill_truncate(image, block_width, ppp, downsample_width):
    imageDown = np.zeros(image.shape)
    numBlocksV = int(image.shape[0]/block_width)
    numBlocksH = int(image.shape[1]/block_width)
    
    for blockV in range(numBlocksV):
        for blockH in range(numBlocksH):
            dsw_block = int(downsample_width[blockV,blockH])
            ppp_block = int(ppp[blockV,blockH])
            
            for j in range(block_width):
                hIdx = blockH*block_width+j
                for i in range(dsw_block):
                    imageDown[blockV*block_width+i*ppp_block:blockV*block_width+i*ppp_block+ppp_block, hIdx] = int(np.sum(image[blockV*block_width+i*ppp_block:blockV*block_width+i*ppp_block+ppp_block, hIdx]) / ppp_block)
                    
    return imageDown
