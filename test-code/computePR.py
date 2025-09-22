import numpy as np

def init_compression_factor():
    pr_min = 0.125
    pr_max = 1
    ppp_max_images = 64

    cf_vieja = np.zeros([ppp_max_images, 100])
    cf_nueva = np.zeros([ppp_max_images, 100])

    for ppp_max in range(1, ppp_max_images):
        cf_min = (1.0 + (ppp_max - 1.0) * pr_min) / ppp_max
        cf_max = 1.0 + (ppp_max - 1.0) * pr_max
        r = pow(cf_max / cf_min, (1.0 / 99.0))

        for ql in range(0,100):
            cf_vieja[ppp_max, ql] = (1.0 / ppp_max) * pow(r, (99.0 - ql))
            cf_nueva[ppp_max, ql] = cf_min * pow(r, (99.0 - ql))

    return cf_vieja, cf_nueva

def computePR_block(block_width, image_block_scanline, QUANT_LUM0, QUANT_LUM1, QUANT_LUM2, QUANT_LUM3, printDebug):
    a = 0
    b = 0
    counter = 0
    accum = 0
    
    listDiff = []

    for i in range(block_width):
        #print(i)
        b = a
        a = image_block_scanline[i]
        if (i==0):
            b = a

        diff = a - b
        #print("  Diff={}".format(diff))
        if (diff<0): diff = -diff
        if (diff < QUANT_LUM0): diff = 0
        elif (diff < QUANT_LUM1): diff = 1
        elif (diff < QUANT_LUM2): diff = 2
        elif (diff < QUANT_LUM3): diff = 3
        else: diff = 4
        #print("  DiffQuant={}".format(diff))
        
        if printDebug:
            listDiff.append(diff)

        if (diff >= 1):
            counter += 1
            accum += diff
        #print("   Counter & diff: {}    {}".format(counter, accum))

    return counter*4, accum, listDiff

def adjustPR(value):
    # Saturate to 0.5
    tope = 0.5

    if (value>tope): value = tope

    # We expand the histogram [0.2 <---> 0.5] -> [0.0 <---> 1.0]
    # The result is negative but it doesn't matter because those values
    # are going to 0 later
    pr_final = (value - 0.125) / (0.5 - 0.125)

    # Quantize the PR
    if (pr_final < 0.125): pr_final = 0
    elif (pr_final < 0.25): pr_final = 0.125
    elif (pr_final < 0.5): pr_final = 0.25
    elif (pr_final < 0.75): pr_final = 0.5
    else: pr_final = 1.0

    return pr_final

def computePR_image(block_width, image, QUANT_LUM0, QUANT_LUM1, QUANT_LUM2, QUANT_LUM3):
    num_blocks_h = int(image.shape[1]/block_width)
    num_blocks_v = int(image.shape[0]/block_width)
    
    counterH = np.zeros([num_blocks_v,num_blocks_h])
    accumH = np.zeros([num_blocks_v,num_blocks_h])
    counterV = np.zeros([num_blocks_v,num_blocks_h])
    accumV = np.zeros([num_blocks_v,num_blocks_h])

    # Build blocks for H and V PR on the go, then pass
    # them to the computePR_block subfunction
    lD = []
    for i in range(num_blocks_v):
        for j in range(num_blocks_h):
            ox = j*block_width
            oy = i*block_width
            printDebug = False
            
            for x in range(block_width):
                cc, aa, listDiff = computePR_block(block_width, image[oy:oy+block_width,ox+x], QUANT_LUM0, QUANT_LUM1, QUANT_LUM2, QUANT_LUM3, printDebug)
                counterV[i,j] += cc
                accumV[i,j] += aa
                if len(listDiff)!=0: lD.append(listDiff)

            for y in range(block_width):
                if i==0 and j==0: printDebug=True
                else: printDebug=False
                
                cc, aa, listDiff = computePR_block(block_width, image[oy+y,ox:ox+block_width], QUANT_LUM0, QUANT_LUM1, QUANT_LUM2, QUANT_LUM3, printDebug)
                counterH[i,j] += cc
                accumH[i,j] += aa
                if len(listDiff)!=0: lD.append(listDiff)
                
    print(counterV[0,]//4)
    print(accumV[0,])
                
    #print('V\tH\taccum\tcount')
    #for i in range(num_blocks_v):
    #    for j in range(num_blocks_h):
    #        print('{}\t{}\t{}\t{}'.format(i,j,accumH[i,j], counterH[i,j]))
    
    prValueH = accumH / (0.1 + counterH)
    prValueV = accumV / (0.1 + counterV)

    adjust_vectorize = np.vectorize(adjustPR)
    prValueH = adjust_vectorize(prValueH)
    prValueV = adjust_vectorize(prValueV)

    return prValueH, prValueV, lD


def computePPP(pr, cf, ql, block_width):
    # Voy paso a paso haciendo lo mismo que la función subkernel_perceptual_relevance_to_ppp

    SIDE_MIN = 2 # De lhecodec.comp
    PPP_MAX = 8
    PPP_MIN = 1

    ppp_max_theoric = block_width / SIDE_MIN # Esto es 20

    if (ppp_max_theoric > PPP_MAX): ppp_max_theoric = PPP_MAX # Esto no pasa, lo dejo por documentar

    ppp = np.zeros(pr.shape)
    downsample_width = np.zeros(pr.shape)

    compression_factor = cf[ppp_max_theoric][ql]

    const1 = ppp_max_theoric - 1.0 # 29
    const2 = ppp_max_theoric * compression_factor

    for i in range(pr.shape[0]):
        for j in range(pr.shape[1]):
            pr_temp = pr[i,j]
            
            ppp_temp = ppp_max_theoric if (pr_temp==0) else const2/(1.0+const1 * pr_temp)
            ppp_temp = PPP_MIN if (ppp_temp<PPP_MIN) else ppp_temp
            
            # Ahora vienen los thresholds de los que hablo
            if (ppp_temp > 6): ppp_return = 8
            elif (ppp_temp >= 4): ppp_return = 4
            elif(ppp_temp >= 1.1): ppp_return = 2
            else: ppp_return = 1

            downsample_width_return = block_width / ppp_return
            ppp[i,j] = ppp_return
            downsample_width[i,j] = downsample_width_return

    return ppp, downsample_width
