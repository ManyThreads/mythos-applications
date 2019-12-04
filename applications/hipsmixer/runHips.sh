#!/bin/bash

cd HiPSmixer
#make purge && make -j `nproc` aN=X tN=X pN=ODT* NTHREADS=2 openmp
make purge && make -j `nproc` aN=X tN=X pN=ODT*
numactl -C 1 run/ODTLES-IMEX-3R-Serial-Channel.x
cd -
