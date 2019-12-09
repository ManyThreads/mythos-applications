#!/bin/bash

cd HiPSmixer
#make purge && make -j `nproc` aN=X tN=X pN=ODT* NTHREADS=2 openmp
make -f ../makefile.linux purge
make -f ../makefile.linux -j `nproc` aN=X tN=X pN=ODT*
run/ODTLES-IMEX-3R-Serial-Channel.x
cd -
