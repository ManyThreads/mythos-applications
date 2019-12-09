#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#config
ITERATIONS=3
NUMTHREADS="1 2"
SUMMARYFILE="bench_summary.out"


echo "Benchmarking ODT Linux vs Mythos and Sequential heap vs musl heap"
echo "==================================================================="
echo ""

rm -f ${SCRIPTDIR}/*.out
touch ${SCRIPTDIR}/${SUMMARYFILE}

echo "Setup:"
cd ${SCRIPTDIR}/..
make --silent clean setup all > /dev/null
cd - 

########################################
echo "Mythos IHK sequential heap:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}
cd ${SCRIPTDIR}/../kernel-ihk

echo ">> build mythos"
make --silent clean sequentialHeap all HIPSARGS="BENCH_ITERATIONS=${ITERATIONS}"> /dev/null

echo ">> run mythos"
make run | tee ${SCRIPTDIR}/run.out 
grep "Duration" ${SCRIPTDIR}/run.out | tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/ODTMythosSeqHeap.out
cd -
rm ${SCRIPTDIR}/run.out

########################################
echo "Mythos IHK musl heap:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}
cd ${SCRIPTDIR}/../kernel-ihk

echo ">> build mythos"
make --silent clean all HIPSARGS="BENCH_ITERATIONS=${ITERATIONS}"> /dev/null

echo ">> run mythos"
make run | tee ${SCRIPTDIR}/run.out 
grep "Duration" ${SCRIPTDIR}/run.out | tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/ODTMythosMuslHeap.out
cd -
rm ${SCRIPTDIR}/run.out

#########################################
echo "Mythos IHK openMP:"

for THREADS in ${NUMTHREADS}
do
	echo "ODT Mythos IHK openMP ${THREADS}:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}
	cd ${SCRIPTDIR}/../kernel-ihk
	echo ">> build mythos"
	make --silent clean all HIPSARGS="NTHREADS=${THREADS} openmp BENCH_ITERATIONS=${ITERATIONS}" > /dev/null

	echo ">> run mythos"
	make run | tee ${SCRIPTDIR}/run.out 
	grep "Duration" ${SCRIPTDIR}/run.out | tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/ODTMythosOMP${THREADS}.out
	cd -
	rm ${SCRIPTDIR}/run.out
done

#########################################
echo "Linux:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}

cd ${SCRIPTDIR}/../applications/hipsmixer/HiPSmixer/

echo ">> build ODT for linux"
make -f ../makefile.linux --silent purge
make -f ../makefile.linux -j `nproc` --silent aN=X tN=X pN=ODT* BENCH_ITERATIONS=${ITERATIONS}

echo ">> run ODT linux"
run/ODTLES-IMEX-3R-Serial-Channel.x | tee ${SCRIPTDIR}/run.out
grep "Duration" ${SCRIPTDIR}/run.out | tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/ODTLinux.out
cd -
rm ${SCRIPTDIR}/run.out

########################################
echo "Linux openMP:\n"

for THREADS in ${NUMTHREADS}
do
	echo "ODT Linux openMP ${THREADS}:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}
	cd ${SCRIPTDIR}/../applications/hipsmixer/HiPSmixer/
	echo ">> build ODT for linux"
	make -f ../makefile.linux --silent purge
	make -f ../makefile.linux -j `nproc` --silent aN=X tN=X pN=ODT* NTHREADS=${THREADS} openmp BENCH_ITERATIONS=${ITERATIONS}

	echo ">> run ODT linux"
	run/ODTLES-IMEX-3R-Serial-Channel.x | tee ${SCRIPTDIR}/run.out
	grep "Duration" ${SCRIPTDIR}/run.out | tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/ODTLinuxOMP${THREADS}.out
	cd -
	rm ${SCRIPTDIR}/run.out
done
