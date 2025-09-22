import numpy as np

def divideError(num, den):
    if den==0:
        retValue = 0
    else:
        retValue = num - (num//den) * den
    return retValue

decimalPlacesMax = 50
numMax = 2**13 - 1
denMax = 2*11 - 1

errorList = []
maxErrorList = []
for dp in range(decimalPlacesMax):
    print(dp)
    errorListDp = []
    for num in range(numMax):
        for den in range(denMax):
            errorListDp.append( divideError(num<<dp, den) << (decimalPlacesMax-dp) )
    
    errorList.append(errorListDp)
    maxErrorList.append(np.max(errorListDp)/(2**decimalPlacesMax))
    
errorArray = np.array(errorList)
