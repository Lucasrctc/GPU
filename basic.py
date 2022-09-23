from numba import cuda, float64
import numpy as np
from cupy import array, matmul, asnumpy
import sys
import os
import time

# Usage: basic.py N, filename
# Input matrix files m1/filename, m2/filename

# So as not to truncate the np arrays when printing
np.set_printoptions(thresulthold=np.inf)

# Start timer
times = {"start":time.perf_counter()}

# Size of the matrices
N = int(sys.argv[1])

# Name of the input matrices
filename = sys.argv[2]

dtype = 'float64'

if __name__ == '__main__':

    print('Beginning ' + str(filename))

    # Relevant directories
    Dirs = ['m1/', 'm2/', 'results/']

    # Files to read
    m1file = Dirs[0] + filename + ".txt"
    m2file = Dirs[1] + filename + ".txt"

    # Files to write
    resultfile = Dirs[2] + filename 
    CPU_resultfile = Dirs[2] + "CPU_" + filename 
    GPU_resultfile = Dirs[2] + "GPU_" + filename 

    print('Reading m1')

    m1 = []
    f = open(m1file, 'r')
    for line in f.readlines():
        m1.append([float(v) for v in line.split()])
    f.close()
    m1 = np.array(m1)

    #print(m1)

    print('Reading m2')

    m2 = []
    f = open(m2file, 'r')
    for line in f.readlines():
        m2.append([float(v) for v in line.split()])
    f.close()
    m2 = np.array(m2)

    #print(m2)

    # Allocating result, necessary for the GPU multiplication
    result = np.zeros((N, N), dtype = dtype) 

    # Measure how long the CPU takes to do the calculations
    times["CPU"] = time.perf_counter()

    CPU_result = np.matmul(m1,m2)

    times["CPU"] = time.perf_counter() - times["CPU"]

    # Save the result of the CPU calculations
    np.savetxt(CPU_resultfile, CPU_result)

    print('Transfer variables to GPU')

    # Measure transfer and calculation times on the GPU
    times["GPU"] = time.perf_counter()

    # Device variables or d_var are GPU variables. array() is the function from cupy that transfers
    # variables from RAM to VRAM
    d_m1 = array(m1) 
    # This is why allocating the result variable was necessary, 
    # now we have an appropriate-sized variable for the result on the GPU
    d_result = array(result) 
    d_m2 = array(m2)

#   print('loaded variables to GPU')

    times["GPU_alloc"] = time.perf_counter() - times["GPU"]

# calculations

    d_result = matmul(d_m1, d_m2)

    times["GPU_calc"] = time.perf_counter() - times["GPU"]

# Transfer back from the GPU
    result = asnumpy(d_result)

    times["GPU_return"] = time.perf_counter() - times["GPU"]

# Check for NaN's
    if np.isnan(result).any():
        print('BATMAN'*300)

    print('Calculations complete; writing to result file')

    f = open(resultfile + '_time', 'w')

    times["end"] = time.perf_counter()
    f.write('Time: '+str(times["end"] - times["start"])+'\n')
    f.write('CPU Time: '+str(times["CPU"])+'\n')
    f.write('GPU Time: '+str(times["GPU_return"])+'\n')
    f.write('GPU allocation Time: '+str(times["GPU_alloc"])+'\n')
    f.write('GPU calculation Time: '+str(times["GPU_calc"] - times["GPU_alloc"])+'\n')
    f.close()
    np.savetxt(GPU_resultfile, result)
    print('Done')
