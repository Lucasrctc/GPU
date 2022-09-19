import numpy as np
import sys
import os

# Usage: genmatrices.py N M

N = int(sys.argv[1])
if len(sys.argv) > 2:
    M = int(sys.argv[1])
else:
    M = -1

def writeFile(N, filename):
    if 'm1' in filename:
        with open(filename, 'w') as f:
            for j in range(N):
                f.write(' '.join(str(i+j-N+1) for i in range(N)))
                f.write("\n")
    elif 'm2' in filename:
        with open(filename, 'w') as f:
            for j in range(N):
                f.write(' '.join(str(N-j+i-1) for i in range(N)))
                f.write("\n")

if __name__ == '__main__':

    Dirs = ['m1/', 'm2/']

    m1file = Dirs[0] + str(N) + ".txt"
    m2file = Dirs[1] + str(N) + ".txt"

    print('Writing m1')

    writeFile(N, m1file)
    for i in range(-1, M - N - 1):
        writeFile(N + i + 2, m1file)

    print('Writing m2')

    writeFile(N, m2file)
    for i in range(-1, M - N - 1):
        writeFile(N + i + 2, m2file)
