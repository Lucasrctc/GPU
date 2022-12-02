#!/bin/bash
##SBATCH --chdir=~/GPU
#SBATCH --job-name=GPU_Matmul
#SBATCH --mail-user=lucas.cortez@ttu.edu
#SBATCH --mail-type=ALL
#SBATCH --output=%x.o%j
#SBATCB --error=%x.e%j
#SBATCH --partition matador
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=9G
#SBATCH --gpus-per-node=1

. $HOME/conda/etc/profile.d/conda.sh
conda activate numba
cd ~/GPU
python3 basic.py 100000 100000
