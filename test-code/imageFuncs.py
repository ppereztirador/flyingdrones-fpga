import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, LinearSegmentedColormap

def luminance(rgbImage):
    return 0.2989*rgbImage[:,:,0] + 0.587 * rgbImage[:,:,1] + 0.114*rgbImage[:,:,2]

def luminanceInt(rgbImage):
    luminanceMat = 0.2989*rgbImage[:,:,0] + 0.587 * rgbImage[:,:,1] + 0.114*rgbImage[:,:,2]
    luminanceMatInt = []
    for ii in range(luminanceMat.shape[0]):
        ll = []
        for jj in range(luminanceMat.shape[1]):
            ll.append( int(luminanceMat[ii,jj]) )
        
        luminanceMatInt.append(ll)
    
    return np.array(luminanceMatInt)

def overimposePR(block_width, image_shape, pr):
    num_blocks_h = int(image_shape[1]/block_width)
    num_blocks_v = int(image_shape[0]/block_width)

    pr_big = np.zeros(image_shape)

    for i in range(num_blocks_v):
        for j in range(num_blocks_h):
            ox = j*block_width
            oy = i*block_width
            for x in range(block_width):
                for y in range(block_width):
                    pr_big[oy+y, ox+x] = pr[i,j]

    return pr_big

def showImageOverlay(image, overlayFactor, block_width):
    #colors = ["r", "g", "y", "b", "m"]
    colors = ["r", "m", "g", "b", "y"]
    cmap1 = LinearSegmentedColormap.from_list('prmap', colors)

    plt.figure()
    plt.imshow(image, cmap='gray')
    plt.imshow(overimposePR(block_width, image.shape, overlayFactor), cmap=cmap1, alpha=0.5)
    plt.colorbar()
    
def generateMockupImage(sizeH, sizeV):
    retImage = np.zeros((sizeV, sizeH))
    for y in range(480): 
        for x in range(640): 
            im_address_cont = int(640*y + x)
            im_val = (im_address_cont>>6) + (im_address_cont>>7)
            
            if (x>100 and x<150 and y>80 and y<197):
                if (x%4==0):
                    retImage[y,x] = 255
                else:
                    retImage[y,x] = 0
            else:
                retImage[y,x] = im_val%256
    
    print(im_address_cont, im_val, im_val%256)
    return retImage

def generateMockupPlain(sizeH, sizeV):
    retImage = np.zeros((sizeV, sizeH)) + 255
    return retImage

def generateMockupCheckered(sizeH, sizeV):
    retImage = np.zeros((sizeV, sizeH))
    for y in range(sizeV): 
        for x in range(sizeH): 
            if (x%2==0) and (y%4<2):
                retImage[y,x] = 255
            elif (x%2==1) and (y%4>=2):
                retImage[y,x] = 255
            else:
                retImage[y,x] = 0
    return retImage

def imageFromTiles(hops, first_luma, block_width, PPPh, PPPv, imshape):
    vRange = len(hops)
    hRange = len(hops[0])
    
    img = np.zeros(imshape)
    
    for vv in range(vRange):
        for hh in range(hRange):
            for i in range(hops[vv][hh].shape[0]):
                for j in range(hops[vv][hh].shape[1]):
                    pv = PPPv[vv][hh]
                    ph = PPPv[vv][hh]
                    ov = int(vv*block_width+i*pv)
                    oh = int(hh*block_width+j*ph)
                    img[ov:ov+pv,oh:oh+ph] = hops[vv][hh][i,j]
                    
    return img
