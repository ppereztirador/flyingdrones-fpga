import numpy as np

def generateCacheHops(cacheType="c"):
    cache = np.zeros((1, 7*256*127+7*255+10-4 + 1), dtype=int)
    
    min_error = 0
    next_error = 0
    quantum = 0
    hop_increment = 0
    
    if cacheType=="c":
        maxr = 4.0 # LHE_c= 4.0  LHE_Pi = 2.7
        minr = 1.0 # LHE_c= 1.0  LHE_Pi = 1.0
        hop_range = 0.8 # LHE_c= 0.8  LHE_Pi = 0.70
    elif cacheType=="pi":
        maxr = 2.7
        minr = 1.0
        hop_range = 0.7
    else:
        raise Exception("Invalid cache type")

    hopn4 = 0
    hopn3 = 1
    hopn2 = 2
    hopn1 = 3
    hop0 = 4
    hopp1 = 5
    hopp2 = 6
    hopp3 = 7
    hopp4 = 8

    minimum_value = 1;
    maximum_value = 255 - minimum_value;

    for orig in range(0, 128): # Orig va hasta 128 por que la cache es simetrica.
        for pred in range(0, 256):
            for h1 in range(4, 11):
                #Por defecto el hop es hop0
                hop = hop0;
                quantum = pred;
                min_error = abs(orig - pred);

                if (hop_range * ((maximum_value - pred) / h1))<0:
                    rpos = -pow(abs(hop_range * ((maximum_value - pred) / h1)), 1.0 / 3.0);
                else:
                    rpos = pow(hop_range * ((maximum_value - pred) / h1), 1.0 / 3.0);
                    
                if rpos>maxr:
                    rpos=maxr
                elif rpos<minr:
                    rpos=minr
                
                if (hop_range * ((pred - minimum_value) / h1))<0:
                    rneg = -pow(abs(hop_range * ((pred - minimum_value) / h1)), 1.0 / 3.0);
                else:
                    rneg = pow(hop_range * ((pred - minimum_value) / h1), 1.0 / 3.0);
                
                if rneg>maxr:
                    rneg=maxr
                elif rneg<minr:
                    rneg=minr

                if (min_error > h1 / 2):
                    if (orig >= pred): # Hops positivos
                        if (pred + h1 <= 255):
                            hop_increment = h1
                            next_error = abs(orig - (pred + hop_increment))
                            if (next_error < min_error):
                                hop = hopp1
                                quantum = pred + hop_increment
                                min_error = next_error
                                hop_increment = round(h1 * rpos)
                                next_error = abs(orig - (pred + hop_increment))

                                if (next_error < min_error):
                                    hop = hopp2
                                    quantum = pred + hop_increment
                                    min_error = next_error
                                    hop_increment = round(h1 * rpos * rpos)
                                    next_error = abs(orig - (pred + hop_increment))

                                    if (next_error < min_error):
                                        hop = hopp3
                                        quantum = pred + hop_increment
                                        min_error = next_error
                                        hop_increment = round(h1 * rpos * rpos * rpos)
                                        next_error = abs(orig - (pred + hop_increment))

                                        if (next_error < min_error):
                                            hop = hopp4
                                            quantum = pred + hop_increment
                                            min_error = next_error

                                        
                    elif (orig < pred): # Hops negativos
                        if (pred - h1 >= 0):
                            hop_increment = h1;
                            next_error = abs(orig - (pred - hop_increment))
                            if (next_error < min_error):
                                hop = hopn1
                                quantum = pred - hop_increment
                                min_error = next_error
                                hop_increment = round(h1 * rneg)
                                next_error = abs(orig - (pred - hop_increment))

                                if (next_error < min_error):
                                    hop = hopn2
                                    quantum = pred - hop_increment
                                    min_error = next_error
                                    hop_increment = round(h1 * rneg * rneg)
                                    next_error = abs(orig - (pred - hop_increment))

                                    if (next_error < min_error):
                                        hop = hopn3
                                        quantum = pred - hop_increment
                                        min_error = next_error
                                        hop_increment = round(h1 * rneg * rneg * rneg)
                                        next_error = abs(orig - (pred - hop_increment))

                                        if (next_error < min_error):
                                            hop = hopn4
                                            quantum = pred - hop_increment
                                            min_error = next_error

                if quantum>maximum_value:
                    quantum = maximum_value
                elif quantum<minimum_value:
                    quantum = minimum_value
                
                cache[0,7 * 256 * orig + 7 * pred + (h1 - 4)] = int(quantum + (hop << 8))
                
    return cache

def generateCacheDecoder(cacheType="c"):
    cache = np.zeros((1, 7*255*3+(10-4)*3 + 2 + 1), dtype=int)
    
    if cacheType=="c":
        maxr = 4.0 # LHE_c= 4.0  LHE_Pi = 2.7
        minr = 1.0 # LHE_c= 1.0  LHE_Pi = 1.0
        hop_range = 0.8 # LHE_c= 0.8  LHE_Pi = 0.70
    elif cacheType=="pi":
        maxr = 2.7
        minr = 1.0
        hop_range = 0.7
    else:
        raise Exception("Invalid cache type")

    hopn4 = 0
    hopn3 = 1
    hopn2 = 2
    hopn1 = 3
    hop0 = 4
    hopp1 = 5
    hopp2 = 6
    hopp3 = 7
    hopp4 = 8
    
    minimum_value = 1;
    maximum_value = 255 - minimum_value;
    
    for pred in range(0, 256):
        for h1 in range(4, 11):
            if ((hop_range * ((maximum_value - pred) / h1)) <0):
                rpos = -pow(abs(hop_range * ((maximum_value - pred) / h1)), 1.0 / 3.0)
            else:
                rpos = pow(hop_range * ((maximum_value - pred) / h1), 1.0 / 3.0)
            if (rpos>maxr):
                rpos = maxr
            elif (rpos<minr):
                rpos = minr
                
            if (hop_range * ((pred - minimum_value) / h1) < 0):
                rneg = -pow(abs(hop_range * ((pred - minimum_value) / h1)), 1.0 / 3.0)
            else:
                rneg = pow(hop_range * ((pred - minimum_value) / h1), 1.0 / 3.0)
            if (rneg>maxr):
                rneg = maxr
            elif (rneg<minr):
                rneg = minr
                
            quant = pred - int(round(h1 * rneg * rneg * rneg))
            if (quant>maximum_value):
                quant = maximum_value
            elif (quant<minimum_value):
                quant = minimum_value
            cache[0, pred * 7 * 3 + (h1 - 4) * 3] = quant
            
            quant = pred - int(round(h1 * rneg * rneg))
            if (quant>maximum_value):
                quant = maximum_value
            elif (quant<minimum_value):
                quant = minimum_value
            cache[0, pred * 7 * 3 + (h1 - 4) * 3 + 1] = quant
            
            quant = pred - int(round(h1 * rneg))
            if (quant>maximum_value):
                quant = maximum_value
            elif (quant<minimum_value):
                quant = minimum_value
            cache[0, pred * 7 * 3 + (h1 - 4) * 3 + 2] = quant
            
    return cache
    

def writeCacheCoe(fileName, cache):
    hexList = []

    for ii in range(cache.shape[0]):
        for jj in range(cache.shape[1]):
            pixelVal_hex = '{:0>3x}'.format(cache[ii,jj])
            hexList.append(pixelVal_hex)

    with open(fileName, 'w') as fh:
        fh.write('memory_initialization_radix = 16;\n')
        fh.write('memory_initialization_vector = \n')
        for ii in range(len(hexList)-1):
            fh.write('{},\n'.format(hexList[ii]))
            
        fh.write('{};'.format(hexList[-1]))

def readCacheCoe(fileName):
    cache = []
    
    with open(fileName, 'r') as fh:
        fh.readline()
        fh.readline() # Skip header
        for line in fh:
            lineClean = line.split(";")[0].split(",")[0]
            cache.append(int(lineClean, 16))
            
    cache = np.array([cache])
    return cache
