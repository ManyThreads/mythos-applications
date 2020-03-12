#! /bin/bash


### change to basedir
cd `dirname $0`
BASEDIR=`pwd`

TBB_LIB_DIR="${BASEDIR}/../../libraries/tbb/build/my_tbb_release"
TBB_INC_DIR="${BASEDIR}/../../libraries/tbb/include"
APPDIR="${BASEDIR}/parsec/pkgs/apps"
APPS="blackscholes bodytrack fluidanimate swaptions"

MGMT=${BASEDIR}/parsec/bin/parsecmgmt

NTHREADS=`nproc`

#export PARSECDIR="${BASEDIR}/parsec"
#export PARSECPLAT="linux"

#source ${BASEDIR}/parsec/config/linux.sysconf
#source ${BASEDIR}/parsec/config/gcc-tbb.bldconf
#source ${BASEDIR}/parsec/config/native.runconf

#cd ${APPDIR}/${APP}/src
#make clean

#export TBB_LDFLAGS="-I${TBB_LIB_DIR}"
#export TBB_CFLAGS="-I${TBB_INC_DIR}"

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${TBB_LIB_DIR}" 

for app in ${APPS}; do
	${MGMT} -a clean -p ${app} -c gcc-tbb
	${MGMT} -a build -p ${app} -c gcc-tbb
done

for app in ${APPS}; do
	${MGMT} -a run -p ${app} -c gcc-tbb -i native -n ${NTHREADS} | tee ${BASEDIR}/${app}.out
	echo "#NAME ${app}"> ${BASEDIR}/${app}_tbb.csv
	grep "#TBB_" ${BASEDIR}/${app}.out >> ${BASEDIR}/${app}_tbb.csv
	python3 plot.py ${BASEDIR}/${app}_tbb.csv
	montage -geometry +0+0  ${BASEDIR}/parallelism_profile_${app}.png ${BASEDIR}/reconf_rate_${app}.png ${BASEDIR}/thread_profile_${app}.png ${BASEDIR}/thread_grade_${app}.png ${BASEDIR}/${app}.png
done

cd ${BASEDIR}
hostname=`hostname`
time=`date +%y-%m-%d_%H:%M`
outdir="bench_${hostname}_${time}"
echo ${outdir}
mkdir ${outdir}
mv *.out *.png ${outdir}
cd -
