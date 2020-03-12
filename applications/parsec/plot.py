import numpy as np
import matplotlib.pyplot as plt
import sys as sys
import operator as op
from matplotlib.ticker import PercentFormatter


#function for reading the run times from ODTLES out files
def read_data( file_name ):
    data = []

try:
    #handover over file name
    file_name = sys.argv[1]
except:
    #exception handling
    raise ValueError("File name must be given in the call, "\
                      "e.g. python plot.py yourfile")

bench_name = "unknown app"
times = []
threads = []

wtimes = []
worker = []

fp = open(file_name)

line = fp.readline()
while line:
    words = line.split()
    if(len(words)>1):
        if(words[0] == "#NAME"):
            bench_name = words[1]
        elif(words[0] == "#TBB_THREADS"):
            threads.append(int(words[1]))
            times.append(float(words[2])/1000000000)
        elif(words[0] == "#TBB_WORKER"):
            worker.append(int(words[1]))
            wtimes.append(float(words[2])/1000000000)
    line  = fp.readline()

# sort events by timestamp
tmp = sorted(zip(times, threads), key=op.itemgetter(0))
times, threads = zip(*tmp)
times = list(times)
threads = list(threads)

length = len(threads)

num = 0
for i in range(length):
    num += threads[i]
    threads[i] = num


plt.step(times, threads, where='post')
plt.xlabel('runtime in seconds')
plt.ylabel('#threads requested')
plt.title('Parallelism profile of app ' + bench_name)
plt.savefig('parallelism_profile_'+bench_name+'.png', dpi=300)
plt.clf()

dt = times.copy()
prev = 0.0
for i in range(length):
    dt[i] = times[i] - prev
    prev = times[i]

# my_bins = ['1.0e-09' '1.0e-08' '1.0e-07' '1.0e-06' '1.0e-07' '1.0e-06' '1.0e-05' '1.0e-04' '1.0e-03' '1.0e-02' '1.0e-01' '1.0e+00']
my_bins = []
# [float(i) for i in my_bins]

for x in range (-9, 1):
    my_bins.append(float(1.0)*10**x)

plt.hist(x=dt, weights=np.ones(len(dt)) / len(dt), bins=my_bins)
plt.xscale('log')
plt.gca().yaxis.set_major_formatter(PercentFormatter(1))
plt.xlabel('reconfiguration rate in seconds')
# plt.ylabel('percentage')
plt.title('Threadpool reconfiguration rate distribution of ' + bench_name)
plt.savefig('reconf_rate_'+bench_name+'.png', dpi=300)
plt.clf()

wtmp = sorted(zip(wtimes, worker), key=op.itemgetter(0))
wtimes, worker = zip(*wtmp)
wtimes = list(wtimes)
worker = list(worker)


dw = worker.copy()
dow = worker.copy()
dwt = wtimes.copy()
wlength = len(worker)

num = 0
t = 0.0
for i in range(wlength):
    dwt[i] = wtimes[i] - t
    t = wtimes[i]
    dow[i] = num
    num += worker[i]
    dw[i] = num


plt.step(wtimes, dw, where='post')
plt.xlabel('runtime in seconds')
plt.ylabel('#threads running')
plt.title('Parallelism profile of app ' + bench_name)
plt.savefig('thread_profile_'+bench_name+'.png', dpi=300)
plt.clf()

wtsum = list(zip(dwt, dow))

d = {x:0 for _, x in wtsum}

for dt, w in wtsum: d[w] += dt

Output = list(map(tuple, d.items()))


x , y = zip(*Output)
x = list(x)
ysum = sum(y) 
y = list(map(lambda x: x/ysum, y))

plt.bar(x, y)
plt.gca().yaxis.set_major_formatter(PercentFormatter(1))
plt.xlabel('Number of concurrently running threads')
plt.ylabel('Runtime')
plt.title('Parallelism grade of ' + bench_name)
plt.savefig('thread_grade_'+bench_name+'.png', dpi=300)
plt.clf()
