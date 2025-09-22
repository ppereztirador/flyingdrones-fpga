import numpy as np
import matplotlib.pyplot as plt
import imageFuncs
import computePR
import downsample

image = plt.imread('/home/pperez/Imágenes/hojas1.bmp')
Y_image = imageFuncs.luminanceInt(image)
QUANT_LUM0 = 8
QUANT_LUM1 = 16
QUANT_LUM2 = 24
QUANT_LUM3 = 32

# Compression factor
cf_vieja, cf_nueva = computePR.init_compression_factor()

# Compute PR
PRh, PRv, listDiff = computePR.computePR_image(40, Y_image, QUANT_LUM0, QUANT_LUM1, QUANT_LUM2, QUANT_LUM3)

# Compute PPP
PPPh, DSWh = computePR.computePPP(PRh, cf_nueva, 30, 40)
PPPv, DSWv = computePR.computePPP(PRv, cf_nueva, 30, 40)

# Downsample
Y_image_downH = downsample.downsampleHfill(Y_image, 40, PPPh, DSWh)
Y_image_downV = downsample.downsampleVfill(Y_image_downH, 40, PPPv, DSWv)
