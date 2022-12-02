import numpy as np
import sys

# Usage: basic.py N, filename
# Input matrix files m1/filename, m2/filename

# So as not to truncate the np arrays
np.set_printoptions(threshold=np.inf)

filename = sys.argv[1]

if __name__ == '__main__':

    print('Beginning ' + str(filename))

    PATH = 'results/'

    CPU_resfile = PATH + "CPU_" + filename 
    GPU_resfile = PATH + "GPU_" + filename 

    print('Reading CPU file')

    m1 = []
    f = open(CPU_resfile, 'r')
    for line in f.readlines():
        m1.append([float(v) for v in line.split()])
    f.close()
    m1 = np.array(m1)

    #print(m1)

    print('Reading GPU file')

    m2 = []
    f = open(GPU_resfile, 'r')
    for line in f.readlines():
        m2.append([float(v) for v in line.split()])
    f.close()
    m2 = np.array(m2)

    #print(m2)

    res = m1 - m2

    differences = 0
    for i in range(len(res)):
        for j in range(len(res[i])):
            if res[i][j] != 0:
                #print("Difference in position",i, j,"\nvalue of difference:", res[i][j])
                differences += 1
    print("differences:", differences)
    print('Done')
