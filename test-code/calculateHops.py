import numpy as np
import hopCache
import sys

# Int defines
MIN_H1 = 4
MAX_H1 = 10
INIT_H1 = 5

HOPN4 = 0
HOPN3 = 1
HOPN2 = 2
HOPN1 = 3
HOP0 = 4
HOPP1 = 5
HOPP2 = 6
HOPP3 = 7
HOPP4 = 8

def get_hop(hopCache, orig, pred, h1):
    global HOPP4
    
    # Esta distinción se hace debido al uso de cache simétrica.
    try:
        if (orig < 128):
            value = hopCache[0,int(7 * 256 * orig + 7 * pred + (h1 - 4))]
            result = value % 256;
            hop = value // 256;
        else:
            value = hopCache[0,int(7 * 256 * (255 - orig) + 7 * (255 - pred) + (h1 - 4))];
            result = 255 - (value % 256);
            hop = HOPP4 - (value//256);
    except:
        print("ERROR!")
        print(orig)
        print(pred)
        if (orig<128):
            print(int(7 * 256 * orig + 7 * pred + (h1 - 4)))
        else:
            print(int(7 * 256 * (255 - orig) + 7 * (255 - pred) + (h1 - 4)))
            
        raise SystemExit
        hop = 4
        result = orig
        
    return hop, result;
 
def quantizer(lheBlock, hopCache, blockWidth, downsampledHeight, downsampledWidth, debug=False):
    global MIN_H1, MAX_H1, INIT_H1, HOP0
    global HOPN4, HOPN3, HOPN3, HOPN1
    global HOPP4, HOPP3, HOPP3, HOPP1
    
    # Inicializar
    blockData = np.copy(lheBlock)
    y = 0
    grad = 0
    h1 = INIT_H1
    pred = 0
    result = 0
    hop = 4#0
    lastSmallHop = True
    smallHop = False

    width = downsampledWidth
    height = downsampledHeight
    stride = blockWidth
    hops = np.zeros((height, width))
    
    if debug:
        fh = open('log.txt','w')
    
    # LHE
    for y in range(height):
        for x in range(width):
            if (y < height and x >= 0 and x < width):
                if (y == 0 and x == 0): # Pixel inicial, no tiene referencias para predecir
                    pred = blockData[y, x]
                    first_luma = pred
                elif (y == 0): # y superior
                    pred = blockData[y, x - 1];
                elif (x == 0): # x inicial
                    pred = blockData[(y-1), x ];
                elif (x == width - 1): # x final
                    pred = (blockData[y, x -1 ] + blockData[(y-1), x ]) // 2;
                else: # El centro de la imagen.
                    pred = (blockData[y, x -1 ] + blockData[(y-1), x + 1 ]) // 2;
                
                if (pred+grad > 255):
                    pred = 255
                elif (pred+grad < 0):
                    pred = 0
                else:
                    pred = pred+grad
                

                hop, result = get_hop(hopCache, int(blockData[y, x]), pred, h1)
                
                if debug:
                    memval = (hop*256+result) if (int(blockData[y, x])<128) else ((HOPP4-hop)*256+(255-result))
                    
                    fh.write("x = {}, y = {}, orig = {}\n".format(x, y, int(blockData[y, x])))
                    fh.write("pred = {}, grad = {}\n".format(pred, grad))
                    fh.write("mem = {}, hop = {}, result = {}\n".format(memval, hop, result))

                hops[y, x] = hop
                blockData[y, x] = result


                if (hop <= HOPP1 and hop >= HOPN1):
                    smallHop = True
                else:
                    smallHop = False
                    
                if (smallHop == True and lastSmallHop == True and h1 > MIN_H1):
                    h1 = h1 - 1;
                elif (hop >= HOPP3 or hop <= HOPN3):
                    h1 = MAX_H1;

                if (hop == HOPP1):
                    grad = 1
                elif (hop == HOPN1):
                    grad = -1
                elif (smallHop == False):
                    grad = 0

                lastSmallHop = smallHop;
                
                if debug:
                    fh.write("After conditions\n")
                    fh.write("smallHop = {}\n".format(smallHop))
                    fh.write("h1 = {}, grad (new) = {}\n".format(h1, grad))
                    fh.write("****************\n")
                    
                
                
    return hops, first_luma

def quantizer_immediate_h1(lheBlock, hopCache, blockWidth, downsampledHeight, downsampledWidth, debug=False):
    global MIN_H1, MAX_H1, INIT_H1, HOP0
    global HOPN4, HOPN3, HOPN3, HOPN1
    global HOPP4, HOPP3, HOPP3, HOPP1
    
    # Inicializar
    blockData = np.copy(lheBlock)
    y = 0
    grad = 0
    h1 = INIT_H1
    pred = 0
    result = 0
    hop = 4#0
    diff = 20

    width = downsampledWidth
    height = downsampledHeight
    stride = blockWidth
    hops = np.zeros((height, width))
    
    if debug:
        fh = open('log.txt','w')
    
    # LHE
    for y in range(height):
        hop = 4
        
        for x in range(width):
            if (y < height and x >= 0 and x < width):
                if (y == 0 and x == 0): # Pixel inicial, no tiene referencias para predecir
                    pred = blockData[y, x]
                    first_luma = pred
                elif (y == 0): # y superior
                    pred = blockData[y, x - 1];
                    if (x > 2):
                        diff = abs(blockData[y, x-1] - blockData[y, x-2])
                elif (x == 0): # x inicial
                    pred = blockData[(y-1), x+1 ];
                    diff = abs(blockData[y-1, x] - blockData[y-1, x+1])
                elif (x == width - 1): # x final
                    pred = (blockData[y, x -1 ] + blockData[(y-1), x ]) // 2;
                    diff = abs(blockData[y, x-1] - blockData[y-1, x])
                else: # El centro de la imagen.
                    pred = (blockData[y, x -1 ] + blockData[(y-1), x + 1 ]) // 2;
                    diff = abs(blockData[y, x-1] - blockData[y-1, x])
                
                if (diff < 8):
                    h1 = 4
                elif (diff < 24):
                    h1 = 6
                else:
                    h1 = 10
                
                if (hop == 4):
                    grad = 0
                elif (diff > 48):
                    grad = 6
                elif (diff > 32):
                    grad = 4
                elif (diff > 24):
                    grad = 1
                else:
                    grad = 0
                    
                if (hop <= HOPN1):
                    grad = -grad
                
                if (pred+grad > 255):
                    pred = 255
                elif (pred+grad < 0):
                    pred = 0
                else:
                    pred = pred+grad
                
                hop, result = get_hop(hopCache, int(blockData[y, x]), pred, h1)
                
                if debug:
                    memval = (hop*256+result) if (int(blockData[y, x])<128) else ((HOPP4-hop)*256+(255-result))
                    
                    fh.write("x = {}, y = {}, orig = {}\n".format(x, y, int(blockData[y, x])))
                    fh.write("diff = {}, pred = {}\n".format(diff, pred))
                    fh.write("h1 = {}, grad = {}\n".format(h1, grad))
                    fh.write("mem = {}, hop = {}, result = {}\n".format(memval, hop, result))
                    fh.write("****************\n")

                hops[y, x] = hop
                blockData[y, x] = result
                
                
    if debug:
        fh.close()
        
    return hops, first_luma

def lheImage(image, block_width, DSWh, DSWv, hopCache, quantType=""):
    numBlocksV = int(image.shape[0]/block_width)
    numBlocksH = int(image.shape[1]/block_width)
    
    hopsList = []
    lumaList = []
    for blockV in range(numBlocksV):
        hlH = []
        flH = []
        for blockH in range(numBlocksH):
            DSWhBlock = int(DSWh[blockV, blockH])
            DSWvBlock = int(DSWv[blockV, blockH])
            
            blockData = image[blockV*block_width:blockV*block_width+DSWvBlock,
                              blockH*block_width:blockH*block_width+DSWhBlock]
            
            if (blockV==0 and blockH==1):
                debug = True
            else:
                debug = False
            
            if (quantType=="h1"):
                hopsBlock, first_lumaBlock = quantizer_immediate_h1(blockData,
                                                hopCache, block_width,
                                                DSWvBlock, DSWhBlock, debug)
            else:
                hopsBlock, first_lumaBlock = quantizer(blockData, hopCache, block_width,
                                                   DSWvBlock, DSWhBlock, debug)
            hlH.append(hopsBlock)
            flH.append(first_lumaBlock)
            
        hopsList.append(hlH)
        lumaList.append(flH)
        
    return hopsList, lumaList


def get_quant(hopCache, pred, hop, h1):
    global HOPN4, HOPN3, HOPN3, HOPN1
    global HOPP4, HOPP3, HOPP3, HOPP1
    
    minimum_value = 1;
    maximum_value = 255 - 1;
    
    if (hop==HOPN4):
        quant = hopCache[0, pred * 7 * 3 + (h1 - 4) * 3]
    elif (hop==HOPN3):
        quant = hopCache[0, pred * 7 * 3 + (h1 - 4) * 3 + 1]
    elif (hop==HOPN2):
        quant = hopCache[0, pred * 7 * 3 + (h1 - 4) * 3 + 2]
    elif (hop==HOPN1):
        quant = pred - h1
    elif (hop==HOP0):
        quant = pred
    elif (hop==HOPP1):
        quant = pred + h1
    elif (hop==HOPP2):
        quant = 255 - hopCache[0, (255 - pred) * 7 * 3 + (h1 - 4) * 3 + 2]
    elif (hop==HOPP3):
        quant = 255 - hopCache[0, (255 - pred) * 7 * 3 + (h1 - 4) * 3 + 1]
    elif (hop==HOPP4):
        quant = 255 - hopCache[0, (255 - pred) * 7 * 3 + (h1 - 4) * 3]
        
    if (quant > maximum_value):
        quant = maximum_value
    elif (quant < minimum_value):
        quant = minimum_value
        
    return int(quant)

def dequantizer(hopBlock, hopCache, first_luma, blockWidth, downsampledHeight, downsampledWidth):
    global MIN_H1, MAX_H1, INIT_H1, HOP0
    global HOPN4, HOPN3, HOPN3, HOPN1
    global HOPP4, HOPP3, HOPP3, HOPP1
    
    # Inicializar
    grad = 0
    h1 = INIT_H1
    pred = 0
    result = 0
    hop = 0
    lastSmallHop = True
    smallHop = False

    width = downsampledWidth
    height = downsampledHeight
    img = np.zeros((height, width))
    
    # LHE
    for y in range(height):
        hop = 4
        for x in range(width):
            if (y < height and x >= 0 and x < width):
                if (y == 0 and x == 0): # Pixel inicial, no tiene referencias para predecir
                    pred = int(first_luma)
                elif (y == 0): # y superior
                    pred = img[y, x - 1];
                elif (x == 0): # x inicial
                    pred = img[(y-1), x ];
                elif (x == width - 1): # x final
                    pred = (img[y, x -1 ] + img[(y-1), x ]) // 2;
                else: # El centro de la imagen.
                    pred = (img[y, x -1 ] + img[(y-1), x + 1 ]) // 2;
                
                if (pred+grad > 255):
                    pred = 255
                elif (pred+grad < 0):
                    pred = 0
                else:
                    pred = pred+grad
                

                hop = hopBlock[y][x]
                result = get_quant(hopCache, int(pred), hop, h1)
                img[y][x] = result

                if (hop <= HOPP1 and hop >= HOPN1):
                    smallHop = True
                else:
                    smallHop = False
                    
                if (smallHop == True and lastSmallHop == True and h1 > MIN_H1):
                    h1 = h1 - 1;
                elif (hop >= HOPP3 or hop <= HOPN3):
                    h1 = MAX_H1;

                if (hop == HOPP1):
                    grad = 1
                elif (hop == HOPN1):
                    grad = -1
                elif (smallHop == False):
                    grad = 0

                lastSmallHop = smallHop;
                
    return img

def dequantizer_h1_immediate(hops, hopCache, first_luma, blockWidth, downsampledHeight, downsampledWidth):
    global MIN_H1, MAX_H1, INIT_H1, HOP0
    global HOPN4, HOPN3, HOPN3, HOPN1
    global HOPP4, HOPP3, HOPP3, HOPP1
    
    minimum_value = 1;
    maximum_value = 255;
    
    # Inicializar
    grad = 0
    h1 = INIT_H1
    pred = 0
    result = 0
    hop = 4
    orig_color = first_luma
    diff = 20
    
    width = downsampledWidth
    height = downsampledHeight
    img = np.zeros((40, 40))
    numPxV = 40//downsampledHeight
    numPxH = 40//downsampledWidth
    
    
    # LHE
    for y in range(height):
        hop = 4
        for x in range(width):
            if (y == 0 and x == 0):
                pred = orig_color;
            elif (y == 0): # superior, igual que sin h1 inmediate
                pred = img[y, x - 1]
                if (x > 2):
                    diff = abs(img[y, x - 1] - img[y, x - 2])
                    #mejora pixeles sucios
                    #mezclo con pix derecho solo si el derecho no tiene hop alto inverso
                    if ((hops[y,x - 2] == 8 and hops[y, x - 1] > 0) or
                        (hops[y, x - 2] == 0 and hops[y, x - 1] < 8)) :
                        #queda mucho mejor cogiendo derecho directamente
                        img[y, x - 2] = img[y, x - 1];

            elif (x == 0):
                #pred = result[(y - 1) * BLOCK_WIDTH + x];
                pred = img[(y - 1), x+1];
                diff = abs(img[(y - 1), x] - img[y - 1, x + 1]);
        
            elif (x == width-1):
                pred = (img[(y - 1), x] + img[y, x - 1]) //2;
                diff = abs(img[y, x - 1] - img[(y - 1), x]);
            
            
            else: #interior del bloque
                pred = (img[(y - 1), x + 1] + img[y, x - 1]) // 2;
                diff = abs(img[y, x - 1] - img[(y - 1), x]);

            if (diff < 8): h1 = 4
            elif (diff < 24): h1 = 6
            else: h1 =  10;
            

            if (hop == 4): grad = 0;
            elif (diff > 48): grad = 6;
            elif (diff > 32): grad = 4;
            elif (diff > 24): grad = 1;
            else: grad = 0;

            if (hop <= HOPN1):
                grad = -grad;
            
            if (pred + grad > maximum_value):
                pred = maximum_value
            elif (pred + grad < minimum_value):
                pred = minimum_value
            else:
                pred = pred + grad;
                
            hop = hops[y, x];
            result = get_quant(hopCache, int(pred), hop, h1);
            img[y*numPxV:y*numPxV+numPxV, x*numPxH:x*numPxH+numPxH] = result
            
    return img

def unLheImage(hops, first_luma, block_width, DSWh, DSWv, imshape, hopCache):
    numBlocksV = int(imshape[0]/block_width)
    numBlocksH = int(imshape[1]/block_width)
    
    img = []
    
    for blockV in range(numBlocksV):
        imgH = []
        for blockH in range(numBlocksH):
            DSWhBlock = int(DSWh[blockV][blockH])
            DSWvBlock = int(DSWv[blockV][blockH])
            
            hopData = hops[blockV][blockH]
            first_lumaBlock = first_luma[blockV][blockH]
            
            if (blockV==0 and blockH==0):
                debug = True
            else:
                debug = False
            
            imgBlock = dequantizer(hopData, hopCache, first_lumaBlock,
                                   block_width, DSWvBlock, DSWhBlock)
            imgH.append(imgBlock)
            
        img.append(imgH)
        
    return img

def unLheImage_h1_immediate(hops, first_luma, block_width, DSWh, DSWv, imshape, hopCache):
    numBlocksV = int(imshape[0]/block_width)
    numBlocksH = int(imshape[1]/block_width)
    
    img = np.zeros((480, 640))
    
    for blockV in range(numBlocksV):
        for blockH in range(numBlocksH):
            DSWhBlock = int(DSWh[blockV][blockH])
            DSWvBlock = int(DSWv[blockV][blockH])
            
            hopData = hops[blockV][blockH]
            first_lumaBlock = first_luma[blockV][blockH]
            
            imgBlock = dequantizer_h1_immediate(hopData, hopCache, first_lumaBlock,
                                   block_width, DSWvBlock, DSWhBlock)
                        
            img[blockV*40:blockV*40+40, blockH*40:blockH*40+40] = imgBlock
        
    return img
