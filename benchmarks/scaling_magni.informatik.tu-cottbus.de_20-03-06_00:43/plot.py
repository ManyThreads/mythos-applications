import numpy as np
import matplotlib.pyplot as plt
import sys as sys


#function for reading the run times from ODTLES out files
def read_data( file_name ):
    data = []
    with open(file_name) as fp:
        line = fp.readline()
        while line:
            words = line.split()
            if(len(words)>1):
                if(words[0] == "Duration"):
                    words[3] = words[3].replace(":", ".")
                    data.append(float(words[3]))
            line  = fp.readline()
    return(sorted(data))

# reading data
data_linux_OMP1      = np.median(read_data("ODTLinuxOMP1.out"))
data_mythos_OMP1     = np.median(read_data("ODTMythosOMP1.out"))
data_linux_OMP2      = np.median(read_data("ODTLinuxOMP2.out"))
data_mythos_OMP2     = np.median(read_data("ODTMythosOMP2.out"))
data_linux_OMP4      = np.median(read_data("ODTLinuxOMP4.out"))
data_mythos_OMP4     = np.median(read_data("ODTMythosOMP4.out"))
data_linux_OMP8      = np.median(read_data("ODTLinuxOMP8.out"))
data_mythos_OMP8     = np.median(read_data("ODTMythosOMP8.out"))
data_linux_OMP16      = np.median(read_data("ODTLinuxOMP16.out"))
data_mythos_OMP16     = np.median(read_data("ODTMythosOMP16.out"))
data_linux_OMP24      = np.median(read_data("ODTLinuxOMP24.out"))
data_mythos_OMP24     = np.median(read_data("ODTMythosOMP24.out"))

data_to_plot_scalability_linux  = [data_linux_OMP1, data_linux_OMP2,
                                   data_linux_OMP4, data_linux_OMP8,
                                   data_linux_OMP16, data_linux_OMP24]
data_to_plot_scalability_mythos = [data_mythos_OMP1, data_mythos_OMP2,
                                   data_mythos_OMP4, data_mythos_OMP8,
                                   data_mythos_OMP16, data_mythos_OMP24]

thread_data = [1,2,4,8,16,24]

# x = np.linspace(0.0,1.0,6)
fig1, ax1 = plt.subplots()
ax1.set_title("Scalability of ODTLES on Linux and MyThOS")
p1 = plt.plot(thread_data, data_to_plot_scalability_linux, 'k-o')
p2 = plt.plot(thread_data, data_to_plot_scalability_mythos, 'r-d')
# bp1 = plt.boxplot(data_to_plot_scalability_linux,0,'', widths=0.1,
                 # positions=x-1/6*0.25,
                 # patch_artist=True, boxprops=dict(facecolor="C0"))
# bp2 = plt.boxplot(data_to_plot_scalability_mythos,0,'', widths=0.1,
                 # positions=x+1/6*0.25,
                 # patch_artist=True, boxprops=dict(facecolor="C2"))
ax1.legend([p1[0],p2[0]], ['Linux', 'MyThOS'],
                loc='upper left')
# ax1.set_xticklabels(['1', '2', '4', '8',
                         # '16', '24'])
# plt.xticks(x)
# ax1.set_xlim([0,25])
#ax1.set_ylim([30,50])
ax1.set_ylabel("Runtime in seconds")
ax1.set_xlabel("Number of threads")
fig1.savefig("ODTLES.pdf")



