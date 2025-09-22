import numpy as np
import matplotlib.pyplot as plt
import imageFuncs

image = plt.imread('/home/pperez/Imágenes/hojas1.bmp')
Y_image = imageFuncs.luminanceInt(image)
fileName = ('/home/pperez/Imágenes/hojas1.coe')

hexList = []

for ii in range(Y_image.shape[0]):
    for jj in range(Y_image.shape[1]):
        pixelVal_hex = '{:0>2x}'.format(Y_image[ii,jj])
        hexList.append(pixelVal_hex)

with open(fileName, 'w') as fh:
    fh.write('memory_initialization_radix = 16;\n')
    fh.write('memory_initialization_vector = \n')
    for ii in range(len(hexList)-1):
        fh.write('{},\n'.format(hexList[ii]))
        
    fh.write('{};'.format(hexList[-1]))
