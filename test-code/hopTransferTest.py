import numpy as np
import matplotlib.pyplot as plt

import imageFuncs
import computePR
import downsample_truncate
import hopCache
import calculateHops

image = plt.imread('/home/pperez/Imágenes/hojas1.bmp')
fileName = '/home/pperez/lheAlgorithm/synth_hojas_hop4.hop'

#Y_image = imageFuncs.luminanceInt(image)
Y_image = imageFuncs.generateMockupImage(640,480)
#Y_image = np.zeros((480,640))
# Add a 1 px missalignment in 1st row (emulate HW)
#Y_image[0,0:-1] = Y_image[0,1:]
#Y_image[0,-1] = 0


QUANT_LUM0 = 8
QUANT_LUM1 = 16
QUANT_LUM2 = 24
QUANT_LUM3 = 32

# Compression factor
cf_vieja, cf_nueva = computePR.init_compression_factor()

# Compute PR
PRh, PRv, listDiff = computePR.computePR_image(40, Y_image, QUANT_LUM0, QUANT_LUM1,
                                               QUANT_LUM2, QUANT_LUM3)

# Compute PPP
PPPh, DSWh = computePR.computePPP(PRh, cf_nueva, 30, 40)
PPPv, DSWv = computePR.computePPP(PRv, cf_nueva, 30, 40)
DSWh_alt = np.copy(DSWh)
DSWv_alt = np.copy(DSWv)
PPPh_alt = np.copy(PPPh)
PPPv_alt = np.copy(PPPv)

PPPh_alt[0,0:15] = 8
PPPh_alt[0,1] = 2
PPPh_alt[0,3] = 2
PPPv_alt[0,0:15] = 2

DSWh_alt[0,0:15] = 5
DSWh_alt[0,1] = 20
DSWh_alt[0,3] = 20
DSWv_alt[0,0:15] = 20

# Downsample
Y_image_downH = downsample_truncate.downsampleH_truncate(Y_image, 40, PPPh, DSWh)
Y_image_downV = downsample_truncate.downsampleV_truncate(Y_image_downH, 40, PPPv, DSWv)

# Get hops
hc = hopCache.generateCacheHops(cacheType="c")
#hc = hopCache.readCacheCoe("cache_gen_c.coe")

hops, firstLuma = calculateHops.lheImage(Y_image_downV, 40, DSWh, DSWv, hc, "h1")

# Test - recover image
hc_inverse = hopCache.generateCacheDecoder()
imgListRecovered = calculateHops.unLheImage_h1_immediate(hops, firstLuma, 40, DSWh, DSWv, (480,640), hc_inverse)


# Print hops to binary file
#with open(fileName, 'wb') as fh:
    #Do 100 equal frames
    #for frame in range(100):
        #frameMod = frame % 15
        #for i in range(576):
            #numTileV = i//32
            #numTileH = i%32
            
            #ib = i.to_bytes(2, 'big') # tile no.
            #fh.write(ib)
            #fh.flush()
            #ib = frameMod.to_bytes(1, 'little') # frame
            #fh.write(ib)
            #fh.flush()
            #ib = (1).to_bytes(1, 'little') # bw
            #fh.write(ib)
            #fh.flush()
            
            #if numTileH<16 and numTileV<12:
                #pppx = int(PPPh[numTileV][numTileH])
                #pppy = int(PPPv[numTileV][numTileH])
                #fl = int(firstLuma[numTileV][numTileH])
                
                #ib = pppx.to_bytes(1, 'little') # pppx
                #fh.write(ib)
                #fh.flush()
                #ib = pppy.to_bytes(1, 'little') # pppy
                #fh.write(ib)
                #fh.flush()
                #ib = fl.to_bytes(1, 'little') # luma
                #fh.write(ib)
                #fh.flush()
                #for y in range(40//pppy):
                    #for x in range(40//pppx):
                        #hp = int(hops[numTileV][numTileH][y][x])
                        #ib = hp.to_bytes(1, 'little') # hop
                        #fh.write(ib)
                        #fh.flush()
            #else:
                #ib = (8).to_bytes(1, 'little') # pppx
                #fh.write(ib)
                #fh.flush()
                #ib = (8).to_bytes(1, 'little') # pppy
                #fh.write(ib)
                #fh.flush()
                #ib = (0).to_bytes(1, 'little') # luma
                #fh.write(ib)
                #fh.flush()
                #for y in range(25):
                    #ib = (4).to_bytes(1, 'little') # hop
                    #fh.write(ib)
                    #fh.flush()
