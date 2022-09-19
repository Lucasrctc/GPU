#from numba import cuda, float64
import numpy as np
#import cupy as cp
import sys
import os
import time

# Usage: basic.py N, filename
# Input matrix files m1/filename, m2/filename

# So as not to truncate the np arrays
np.set_printoptions(threshold=np.inf)

# Start timer
times = {"start":time.perf_counter()}

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

    m1 = []
    f = open(m1file, 'r')
    for line in f.readlines():
        m1.append([float(v) for v in line.split()])
    f.close()
    m1 = np.array(m1)

    print(m1)

    print('Reading m2')

    m2 = []
    f = open(m2file, 'r')
    for line in f.readlines():
        m2.append([float(v) for v in line.split()])
    f.close()
    m2 = np.array(m2)

    print(m2)

    #Allocating result
    res = np.zeros((N, N), dtype = dtype) 

    times["cpu"] = time.perf_counter()

    cpu_res = m1*m2

    times["cpu"] = time.perf_counter() - times["cpu"]

    #print('Transfer variables to GPU')

    times["gpu"] = time.perf_counter()

    d_m1 = cp.array(m1) 
    d_res = cp.array(res) 
    d_m2 = cp.array(m2)

    print('loaded variables to GPU')

# calculations

    d_res = cp.matmul(d_m1, d_m2)
    res = cp.asnumpy(d_res)

    times["gpu"] = time.perf_counter() - times["gpu"]

    if np.isnan(res).any():
        print('BATMAN'*300)

    print('Calculations complete; writing to result file')

    f = open(resfile + '_time', 'w')

    times["end"] = time.perf_counter()
    f.write('Time: '+str(times["end"] - times["start"])+'\n')
    f.write('CPU Time: '+str(times["cpu"])+'\n')
    f.write('GPU Time: '+str(times["gpu"])+'\n')
    f.close()
    np.savetxt("GPU_"+resfile, res)
    np.savetxt("CPU_"+resfile, cpu_res)
    print('Done')
