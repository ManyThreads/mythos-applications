#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
nr_cpus=`lscpu --parse | awk -F"," '{if ($4 == 0) print $4}' | wc -l`
echo $nr_cpus
singlecpu=`lscpu --parse | awk -F"," '{if ($4 == 0) print $1}' | tail -n 1 | xargs echo -n | sed 's/ /,/g'`
echo $singlecpu

#config
SUMMARYFILE="bench_summary.out"
ITERATIONS=5
NUMTHREADS=(1 2 4 8 16 24)

for i in ${NUMTHREADS[*]}
do
	if [ $i -ge $nr_cpus ]
	then
		echo "Error: too few cores(${nr_cpus} cores available on numa node 0, ${i} cores requested)"
		exit
	fi
done

#periodically delay sudo timeout
sudo echo "sudo sudo"
while :; do sudo -v; sleep 59; done &
sudoinfiniloop=$!


echo "Benchmarking ODT Linux vs Mythos and Sequential heap vs musl heap"
echo "==================================================================="
echo ""

rm -f ${SCRIPTDIR}/*.out
touch ${SCRIPTDIR}/${SUMMARYFILE}

echo "Setup:"
cd ${SCRIPTDIR}/..
make --silent clean all > /dev/null
cd - 

#########################################
echo "Mythos IHK openMP:"

for THREADS in ${NUMTHREADS[*]}
do
	usedcpus=`lscpu --parse | awk -F"," '{if ($4 == 0) print $1}' | tail -n ${THREADS} | xargs echo -n | sed 's/ /,/g'`
	echo ${usedcpus}
	echo "ODT Mythos IHK openMP ${THREADS}:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}
	cd ${SCRIPTDIR}/../kernel-ihk
	echo ">> build mythos"
	make --silent clean all MYTHOSFLAGS="-DNUM_CPUS=${THREADS}" HIPSARGS="NTHREADS=${THREADS} openmp BENCH_ITERATIONS=${ITERATIONS}" > /dev/null

	echo ">> run mythos"
	sudo rm -rf /tmp/ihkmond
	sudo ../mythos/3rdparty/ihkreboot.sh -m 4096M -k 1 -c ${usedcpus} -p ${SCRIPTDIR}/../kernel-ihk/boot64.elf
	make wait stop | tee ${SCRIPTDIR}/run.out 
	grep "Duration" ${SCRIPTDIR}/run.out | sed 's/^.*\(Duration.*\).$/\1/' | tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/ODTMythosOMP${THREADS}.out
	cd -
	rm ${SCRIPTDIR}/run.out
done

##########################################
echo "Linux openMP:\n"

for THREADS in ${NUMTHREADS[*]}
do
	usedcpus=`lscpu --parse | awk -F"," '{if ($4 == 0) print $1}' | tail -n ${THREADS} | xargs echo -n | sed 's/ /,/g'`
	echo ${usedcpus}
	echo "ODT Linux openMP ${THREADS}:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}
	cd ${SCRIPTDIR}/../applications/hipsmixer/HiPSmixer/
	echo ">> build ODT for linux"
	make -f ../makefile.linux --silent purge
	make -f ../makefile.linux -j `nproc` --silent aN=X tN=X pN=ODT* NTHREADS=${THREADS} openmp BENCH_ITERATIONS=${ITERATIONS}

	echo ">> run ODT linux"
	numactl -C ${usedcpus} run/ODTLES-IMEX-3R-Serial-Channel.x | tee ${SCRIPTDIR}/run.out
	grep "Duration" ${SCRIPTDIR}/run.out | tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/ODTLinuxOMP${THREADS}.out
	cd -
	rm ${SCRIPTDIR}/run.out
done

#enable sudo timeout
kill "$sudoinfiniloop"

# plot results
cd ${SCRIPTDIR}
#python3 plot.py
hostname=`hostname`
time=`date +%y-%m-%d_%H:%M`
outdir="scaling_${hostname}_${time}"
echo ${outdir}
mkdir ${outdir}
mv *.out *.pdf ${outdir}
cd -
