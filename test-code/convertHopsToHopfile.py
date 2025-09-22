import numpy as np
import sys

def print_help():
    print("convertHopsToHopfile.py {-h | fileName}")
    print("  -h - print this help")
    print("  fileName - name of the hops text-file. Results will be saved at fileName+.hops")

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
                pppx.append(int(broken_line[1]))
                pppy.append(int(broken_line[2]))
                first_luma.append(int(broken_line[3]))
            else:
                if broken_line[0]=="TILE":
                    currentTile = int(broken_line[1])
                    if currentTile>0:
                        if (currentTile==1): print(broken_line, hopsIntermediate)
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
            
    # Generate binary
    with open(fileName+".hops", "wb") as fh:
        for frame in range(100):
            frameMod = frame % 15
            for i in range(576):
                ib = i.to_bytes(2, 'big')
                fh.write(ib)
                fh.flush()
                ib = frameMod.to_bytes(1, 'little') # frame
                fh.write(ib)
                fh.flush()
                ib = (1).to_bytes(1, 'little') # bw
                fh.write(ib)
                fh.flush()
                if i in tileN:
                    ib = pppx[i].to_bytes(1, 'little') # pppx
                    fh.write(ib)
                    fh.flush()
                    ib = pppy[i].to_bytes(1, 'little') # pppy
                    fh.write(ib)
                    fh.flush()
                    ib = first_luma[i].to_bytes(1, 'little') # luma
                    fh.write(ib)
                    fh.flush()
                    for j in range(len(hops[i])):
                       ib = hops[i][j].to_bytes(1, 'little') # hop
                       fh.write(ib)
                       fh.flush()
                    #for y in range(40//pppy[i]):
                        #for x in range(40//pppx[i]):
                            #ib = hops[i][40//pppx[i]*y + x].to_bytes(1, 'little') # hop
                            #fh.write(ib)
                            #fh.flush()
                        
                else:
                    ib = (8).to_bytes(1, 'little') # pppx
                    fh.write(ib)
                    fh.flush()
                    ib = (8).to_bytes(1, 'little') # pppy
                    fh.write(ib)
                    fh.flush()
                    ib = (0).to_bytes(1, 'little') # luma
                    fh.write(ib)
                    fh.flush()
                    for j in range(25):
                        ib = (4).to_bytes(1, 'little') # hop
                        fh.write(ib)
                        fh.flush()
