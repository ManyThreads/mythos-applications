import numpy as np
import matplotlib.pyplot as plt


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

# list with amount of used threads e.g. [1,2,4,6,..]
threads = [1,2,4,6]

# reading data
data_linux           = read_data("ODTLinux.out")
data_mythos_muslheap = read_data("ODTMythosMuslHeap.out")
data_mythos_seqheap  = read_data("ODTMythosSeqHeap.out")
if(len(threads)>=1):
    data_linux_OMP1      = read_data("ODTLinuxOMP1.out")
    data_mythos_OMP1     = read_data("ODTMythosOMP1.out")
if(len(threads)>=2):
    data_linux_OMP2      = read_data("ODTLinuxOMP2.out")
    data_mythos_OMP2     = read_data("ODTMythosOMP2.out")
if(len(threads)>=3):
    data_linux_OMP4      = read_data("ODTLinuxOMP4.out")
    data_mythos_OMP4     = read_data("ODTMythosOMP4.out")
if(len(threads)>=4):
    data_linux_OMP6      = read_data("ODTLinuxOMP6.out")
    data_mythos_OMP6     = read_data("ODTMythosOMP6.out")
if(len(threads)>=5):
    data_linux_OMP8      = read_data("ODTLinuxOMP8.out")
    data_mythos_OMP8     = read_data("ODTMythosOMP8.out")

# data for scalability plot
if(len(threads)>=1):
    data_to_plot_scalability_linux  = [data_linux_OMP1]
    data_to_plot_scalability_mythos = [data_mythos_OMP1]
if(len(threads)>=2):
    data_to_plot_scalability_linux  = [data_linux_OMP1, data_linux_OMP2]
    data_to_plot_scalability_mythos = [data_mythos_OMP1, data_mythos_OMP2]
if(len(threads)>=3):
    data_to_plot_scalability_linux  = [data_linux_OMP1, data_linux_OMP2,
                                       data_linux_OMP4]
    data_to_plot_scalability_mythos = [data_mythos_OMP1, data_mythos_OMP2,
                                       data_mythos_OMP4]
if(len(threads)>=4):
    data_to_plot_scalability_linux  = [data_linux_OMP1, data_linux_OMP2,
                                       data_linux_OMP4, data_linux_OMP6]
    data_to_plot_scalability_mythos = [data_mythos_OMP1, data_mythos_OMP2,
                                       data_mythos_OMP4, data_mythos_OMP6]
if(len(threads)>=5):
    data_to_plot_scalability_linux  = [data_linux_OMP1, data_linux_OMP2,
                                       data_linux_OMP4, data_linux_OMP6,
                                       data_linux_OMP8]
    data_to_plot_scalability_mythos = [data_mythos_OMP1, data_mythos_OMP2,
                                       data_mythos_OMP4, data_mythos_OMP6,
                                       data_mythos_OMP8]



x = np.linspace(0.0,1.0,len(threads))
fig1, ax1 = plt.subplots()
ax1.set_title("Scalability of ODTLES")
bp1 = plt.boxplot(data_to_plot_scalability_linux,0,'', widths=0.1,
                 positions=x-1/len(threads)*0.25,
                 patch_artist=True, boxprops=dict(facecolor="C0"))
bp2 = plt.boxplot(data_to_plot_scalability_mythos,0,'', widths=0.1,
                 positions=x+1/len(threads)*0.25,
                 patch_artist=True, boxprops=dict(facecolor="C2"))
ax1.legend([bp1["boxes"][0], bp2["boxes"][0]], ['Linux', 'MyThOS'],
                loc='upper right')
ax1.set_xticklabels(['1 Thread', '2 Threads', '4 Threads', '6 Threads'])
plt.xticks(x)
ax1.set_xlim([0.0-1.0*(1/len(threads)),1.0+1.0*(1/len(threads))])
ax1.set_ylim([30,50])
ax1.set_ylabel("Runtime in seconds")
fig1.savefig("ODTLES.pdf")


# data for heap plot
data_to_plot_heap = [ data_mythos_seqheap, data_mythos_muslheap,               \
                      data_mythos_OMP1, data_linux, data_linux_OMP1]


# plot heap version 1
fig1, ax1 = plt.subplots()
ax1.set_title("Heap")
bp1 = plt.boxplot(data_to_plot_heap,0,'',widths=1, patch_artist=True,
                  labels=['MyThOS_seqheap','MyThOS_muslheap','MyThOS_OMP1',
                          'Linux','Linux_OMP1'])
colors = ['blue', 'green', 'purple', 'tan', 'pink', 'red']
for patch, color in zip(bp1['boxes'], colors):
    patch.set_facecolor(color)
ax1.legend([bp1["boxes"][0],bp1["boxes"][1],bp1["boxes"][2],bp1["boxes"][3],
            bp1["boxes"][4]], ['1_MyThOS_seqheap','2_MyThOS_muslheap',
                               '3_MyThOS_OMP1','4_Linux','5_Linux_OMP1'],
                               loc='upper right')
ax1.set_ylabel("Runtime in seconds")
#ax1.set_ylim([48,49])
ax1.set_xticklabels(['1','2','3','4','5'])
fig1.savefig("heap_version_1.pdf", bbox_inches="tight")

# plot heap version 2
fig1, ax1 = plt.subplots()
ax1.set_title("Heap")
bp1 = plt.boxplot(data_to_plot_heap,0,'',widths=1, patch_artist=True)
colors = ['blue', 'green', 'purple', 'tan', 'pink', 'red']
for patch, color in zip(bp1['boxes'], colors):
    patch.set_facecolor(color)
ax1.set_ylabel("Runtime in seconds")
#ax1.set_ylim([48,49])
xticklabels = ['MyThOS_seqheap','MyThOS_muslheap','MyThOS_OMP1',
               'Linux','Linux_OMP1']
ax1.set_xticklabels(xticklabels, rotation = 60)
ax1.tick_params(axis='both', which='major', labelsize=10)
fig1.savefig("heap_version_2.pdf", bbox_inches="tight")


