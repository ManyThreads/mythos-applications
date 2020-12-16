#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
nr_cpus=`lscpu --parse | awk -F"," '{if ($4 == 0) print $4}' | wc -l`
echo $nr_cpus
singlecpu=`lscpu --parse | awk -F"," '{if ($4 == 0) print $1}' | tail -n 1 | xargs echo -n | sed 's/ /,/g'`
echo $singlecpu

#config
SUMMARYFILE="bench_PM_summary.out"
ITERATIONS=200
NUMTHREADS=(2)

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
#while :; do sudo -v; sleep 59; done &
sudoinfiniloop=$!


echo "Benchmarking Pthread creation Linux vs Mythos"
echo "============================================="
echo ""

rm -f ${SCRIPTDIR}/*.out
touch ${SCRIPTDIR}/${SUMMARYFILE}

echo "Setup:"
cd ${SCRIPTDIR}/..
make --silent clean all > /dev/null
cd - 

########################################
echo "Mythos IHK Benchmark Pthread:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}
cd ${SCRIPTDIR}/../kernel-ihk

echo ">> build mythos"
make --silent clean all BENCH_APP_FLAGS="-DBENCH_ITERATIONS=${ITERATIONS}" > /dev/null

usedcpus=`lscpu --parse | awk -F"," '{if ($4 == 0) print $1}' | tail -n ${NUMTHREADS} | xargs echo -n | sed 's/ /,/g'`
echo ${usedcpus}

echo ">> run mythos"
sudo rm -rf /tmp/ihkmond
sudo ../mythos/3rdparty/ihkreboot.sh -m 4096M -k 1 -c ${usedcpus} -p ${SCRIPTDIR}/../kernel-ihk/boot64.elf
make wait stop | tee ${SCRIPTDIR}/run.out 
grep "PthreadCreate" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadCreate.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Mythos_PthreadCreate.out
grep "PthreadResponse" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadResponse.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Mythos_PthreadResponse.out
grep "PthreadJoin" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadJoin.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Mythos_PthreadJoin.out
cd -
rm ${SCRIPTDIR}/run.out

########################################
echo "Mythos IHK Benchmark Pthread Reuse SC:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}
cd ${SCRIPTDIR}/../kernel-ihk

echo ">> build mythos"
make --silent clean all BENCH_APP_FLAGS="-DBENCH_ITERATIONS=${ITERATIONS}" BENCH_KERNEL_FLAGS="-DPM_CACHE_SC" > /dev/null

usedcpus=`lscpu --parse | awk -F"," '{if ($4 == 0) print $1}' | tail -n ${NUMTHREADS} | xargs echo -n | sed 's/ /,/g'`
echo ${usedcpus}

echo ">> run mythos"
sudo rm -rf /tmp/ihkmond
sudo ../mythos/3rdparty/ihkreboot.sh -m 4096M -k 1 -c ${usedcpus} -p ${SCRIPTDIR}/../kernel-ihk/boot64.elf
make wait stop | tee ${SCRIPTDIR}/run.out 
grep "PthreadCreate" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadCreate.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Mythos_reuse_PthreadCreate.out
grep "PthreadResponse" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadResponse.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Mythos_reuse_PthreadResponse.out
grep "PthreadJoin" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadJoin.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Mythos_reuse_PthreadJoin.out
cd -
rm ${SCRIPTDIR}/run.out

########################################
echo "Mythos IHK Benchmark Pthread do not sleep SC:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}
cd ${SCRIPTDIR}/../kernel-ihk

echo ">> build mythos"
make --silent clean all BENCH_APP_FLAGS="-DBENCH_ITERATIONS=${ITERATIONS}" BENCH_KERNEL_FLAGS="-DSC_DO_NOT_SLEEP" > /dev/null

usedcpus=`lscpu --parse | awk -F"," '{if ($4 == 0) print $1}' | tail -n ${NUMTHREADS} | xargs echo -n | sed 's/ /,/g'`
echo ${usedcpus}

echo ">> run mythos"
sudo rm -rf /tmp/ihkmond
sudo ../mythos/3rdparty/ihkreboot.sh -m 4096M -k 1 -c ${usedcpus} -p ${SCRIPTDIR}/../kernel-ihk/boot64.elf
make wait stop | tee ${SCRIPTDIR}/run.out 
grep "PthreadCreate" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadCreate.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Mythos_nosleep_PthreadCreate.out
grep "PthreadResponse" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadResponse.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Mythos_nosleep_PthreadResponse.out
grep "PthreadJoin" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadJoin.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Mythos_nosleep_PthreadJoin.out
cd -
rm ${SCRIPTDIR}/run.out

##########################################
echo "Linux Benchmark Pthread:" | tee -a ${SCRIPTDIR}/${SUMMARYFILE}

usedcpus=`lscpu --parse | awk -F"," '{if ($4 == 0) print $1}' | tail -n ${NUMTHREADS} | xargs echo -n | sed 's/ /,/g'`
echo ${usedcpus}

cd ${SCRIPTDIR}/../applications/pthreadBenchmark/app/
echo ">> build ODT for linux"
make clean all BENCH_APP_FLAGS="-DBENCH_ITERATIONS=${ITERATIONS}" > /dev/null

echo ">> run ODT linux"
numactl -C ${usedcpus} ./main | tee ${SCRIPTDIR}/run.out

grep "PthreadCreate" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadCreate.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Linux_PthreadCreate.out
grep "PthreadResponse" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadRespone.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Linux_PthreadResponse.out
grep "PthreadJoin" ${SCRIPTDIR}/run.out | sed 's/^.*\(PthreadJoin.*\)/\1/'| tee -a ${SCRIPTDIR}/${SUMMARYFILE} >  ${SCRIPTDIR}/Linux_PthreadJoin.out
cd -
rm ${SCRIPTDIR}/run.out

#enable sudo timeout
#kill "$sudoinfiniloop"

# plot results
cd ${SCRIPTDIR}
python3 PM/plot.py
hostname=`hostname`
time=`date +%y-%m-%d_%H:%M`
outdir="PM/${hostname}_${time}"
echo ${outdir}
mkdir ${outdir}
mv *.out *.pdf ${outdir}
cd -
