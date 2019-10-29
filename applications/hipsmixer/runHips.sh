#!/bin/bash

cd HiPSmixer
make purge && make aN=X tN=X pN=ODT*
run/ODTLES-IMEX-3R-Serial-Channel.x
cd -
