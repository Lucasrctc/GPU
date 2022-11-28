nvfortran -cuda -mp=gpu -cudalib=cublas -Mmkl driver.f90  gpu.f90 timing.o mywrapper.o -o markus.out
