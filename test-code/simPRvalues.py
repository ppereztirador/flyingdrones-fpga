import numpy as np

def divideInt(num, den):
    if den==0:
        retValue = 1
    else:
        retValue = (num//den)
    return retValue

def toFractional(num, numDecimals):
    intPart = num >> numDecimals
    fracPart = num - (intPart << numDecimals)

    fracTotal = 0
    retFrac = []
    for dec in range(numDecimals-1,-1,-1):
        fracDec = fracPart >> dec
        power2 = 2**(dec-numDecimals)
        fracPart -= fracDec << dec
        fracTotal += fracDec * power2
        retFrac.append(fracDec)
    
    retValue = intPart + fracTotal
    return retValue, retFrac

blockH = 40
blockV = 40

numBits = 10
numDecimals = 8

maxDiffH = (blockH-1)*blockV
maxDiffV = (blockV-1)*blockH

maxValueNumH = 4 * maxDiffH
maxValueDenH = maxDiffH

maxValueNumV = 4 * maxDiffH
maxValueDenV = maxDiffV

bitsNumH = np.ceil(np.log2(maxValueNumH))
bitsDenH = np.ceil(np.log2(maxValueDenH))

bitsNumV = np.ceil(np.log2(maxValueNumV))
bitsDenV = np.ceil(np.log2(maxValueDenV))

div_total = []
#div_top_total = []
#div_range_total = []
pr_total = []
div_int_total = []
for num in range(maxValueNumH):
    div = []
    #div_top = []
    #div_range = []
    pr = []
    div_int = []
    for den in range(maxValueDenH):
        num_den = num/(den*4+0.01)
        num_den_int = divideInt(num<<numDecimals, den)
        div.append(num_den)
        div_int.append(num_den_int)
        if num_den > 0.5:
            num_den = 0.5
        #div_top.append(num_den)
        num_den = (num_den - 0.125)/(0.5 - 0.125)
        #div_range.append(num_den)
        if num_den<0.125:
            pr.append(0)
        elif num_den<0.25:
            pr.append(0.125)
        elif num_den<0.5:
            pr.append(0.25)
        elif num_den<0.75:
            pr.append(0.5)
        else:
            pr.append(1)
    div_total.append(div)
    #div_top_total.append(div_top)
    #div_range_total.append(div_range)
    pr_total.append(pr)
    div_int_total.append(div_int)
    
pr_ravel = np.ravel(np.array(pr_total))
div_ravel = np.ravel(np.array(div_total))
div_int_ravel = np.ravel(np.array(div_int_total))

# Sort
sortIdx = np.argsort(div_ravel)
pr_ravel_sort = pr_ravel[sortIdx]
div_ravel_sort = div_ravel[sortIdx]
div_int_ravel_sort = div_int_ravel[sortIdx]

for prIdx in [0, 0.125, 0.25, 0.5, 1]:
    div_ravel_with_this_pr = div_ravel_sort[pr_ravel_sort==prIdx]
    div_int_ravel_with_this_pr = div_int_ravel_sort[pr_ravel_sort==prIdx]
    print(prIdx, min(div_ravel_with_this_pr), np.max(div_ravel_with_this_pr), toFractional(np.min(div_int_ravel_with_this_pr),numDecimals)[0], toFractional(np.max(div_int_ravel_with_this_pr),numDecimals)[0])
    print("     ", toFractional(np.min(div_int_ravel_with_this_pr),numDecimals)[1], toFractional(np.max(div_int_ravel_with_this_pr),numDecimals)[1])
