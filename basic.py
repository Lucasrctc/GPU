from numba import cuda, float64
import numpy as np
import cupy as cp
import sys
import os
import time

# Usage: basic.py N, filename
# Input matrix files m1/filename, m2/filename

# So as not to truncate the np arrays
np.set_printoptions(threshold=np.inf)

# Start timer
t_s = time.perf_counter()

N = int(sys.argv[1])
filename = sys.argv[2]

dtype = 'float64'

if __name__ == '__main__':

    print('Beginning ' + str(filename))

    Dirs = ['m1/', 'm2/', 'results/']

    m1file = Dirs[0] + filename 
    m2file = Dirs[1] + filename 
    resfile = Dirs[2] + filename 

    print('Reading m1')

    m1 = np.zeros((N, N), dtype = dtype)
    f = open(m1file, 'r')
    for line in f.readlines():
        x, y, val = [i for i in line.split()]
        x = int(x) - 1
        y = int(y) - 1
        m1[y][x] = float(val)
    f.close()

    print(m1)

    print('Reading m2')

    m2 = np.zeros((N, N), dtype = dtype) 
    f = open(m2file, 'r')
    for line in f.readlines():
        x, y, val = [i for i in line.split()]
        x = int(x) - 1
        y = int(y) - 1
        m2[y][x] = float(val)
    f.close()

    print(m2)

    #Allocating result
    res = np.zeros((N, N), dtype = dtype) 

    print('Transfer variables to GPU')

    d_m1 = cp.array(m1) 
    d_res = cp.array(res) 
    d_m2 = cp.array(m2)

    print('loaded variables to GPU')

# calculations

    d_res = cp.matmul(d_m1, d_m2)
    res = cp.asnumpy(d_res)

    if np.isnan(res).any():
        print('BATMAN'*300)

    print('Calculations complete; writing to result file')

    f = open(resfile + '_time', 'w')

    t_f = time.perf_counter()
    f.write('Time: '+str(t_f - t_s)+'\n')
    f.close()
    np.savetxt(resfile, res)
    print('Done')
