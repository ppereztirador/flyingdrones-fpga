import numpy as np
import sys

def print_help():
    print("convertHopsToHoplist.py {-h | fileName}")
    print("  -h - print this help")
    print("  fileName - name of the hops text-file")

if __name__ == "__main__":   
    if (len(sys.argv)>1 and sys.argv[1]=="-h"):
        print_help()
        sys.exit(0)
    if len(sys.argv)>1:
        fileName = sys.argv[1]
    else:
        print_help()
        
    tileN = []
    pppx = []
    pppy = []
    first_luma = []
    hops = []

    with open(fileName) as fh:
        ln = 0
        currentTile = 0
        for line in fh:
            broken_line = line.split(" ")
            if (ln<16):
                tileN.append(int(broken_line[0]))
                pppy.append(int(broken_line[1]))
                pppx.append(int(broken_line[2]))
                first_luma.append(int(broken_line[3]))
            else:
                if broken_line[0]=="TILE":
                    currentTile = int(broken_line[1])
                    if currentTile>0:
                        hops.append(hopsIntermediate)
                    hopsIntermediate = []
                else:
                    hh = int(broken_line[0])
                    if hh>=0 and hh<=8:
                        hopsIntermediate.append(hh)
                    else:
                        hopsIntermediate.append(4)

            ln+=1
            
    #last one
    hops.append(hopsIntermediate)
    
    # Format hops into array
    hopsFormat = []
    for i in range(len(hops)):
        sizeX = 40//pppx[i]
        sizeY = 40//pppy[i]
        
        hopsArray = np.zeros((sizeX,sizeY))
        for y in range(sizeY):
            for x in range(sizeX):
                hopsArray[x,y] = hops[i][sizeX*y + x]
        
        hopsFormat.append(hopsArray.T)
