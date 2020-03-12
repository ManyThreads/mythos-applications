#! /bin/bash

### change to basedir
cd `dirname $0`
BASEDIR=`pwd`
echo installing in $BASEDIR

if test ! -e parsec-3.0.tar.gz ; then  
  wget http://parsec.cs.princeton.edu/download/3.0/parsec-3.0.tar.gz || fail
fi
rm -rf parsec
tar -xf parsec-3.0.tar.gz && mv parsec-3.0 parsec || fail

patch  parsec/config/gcc-tbb.bldconf gcc-tbb.patch
patch  parsec/pkgs/apps/blackscholes/parsec/gcc-tbb.bldconf bs_gcc-tbb.patch
