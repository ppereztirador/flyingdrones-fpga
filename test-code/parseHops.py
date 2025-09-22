import sys
import numpy as np

def print_help():
    print("parseHops.py {-h | fileName}")
    print("  -h - print this help")
    print("  fileName - name of the hops text-file.")

if __name__ == "__main__":   
    if (len(sys.argv)>1 and sys.argv[1]=="-h"):
        print_help()
        sys.exit(0)
    if len(sys.argv)>1:
        fileName = sys.argv[1]
        print(fileName)
    else:
        print_help()

    hopList = np.ones((16,40*40))*(-1)

    with open(fileName) as fh:
        lastIsNote = False
        for line in fh:
            ls = line.split(":")
            if ls[0]=="Note":
                lss = ls[1].split(",")
                hopIdx = int(lss[0])-1
                hopValue = int(lss[1])
                lastIsNote = True
            elif lastIsNote==True:
                lastIsNote = False
                hopIdy = int( line.split("(")[1].split(")")[0] )
                print(hopIdx)
                hopList[hopIdy, hopIdx] = hopValue
