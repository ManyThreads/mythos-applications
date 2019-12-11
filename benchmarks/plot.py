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

# reading data
data_linux           = read_data("ODTLinux.out")
data_linux_OMP1      = read_data("ODTLinuxOMP1.out")
data_mythos_muslheap = read_data("ODTMythosMuslHeap.out")
data_mythos_seqheap  = read_data("ODTMythosSeqHeap.out")
data_mythos_OMP1     = read_data("ODTMythosOMP1.out")
data_linux_OMP2      = read_data("ODTLinuxOMP2.out")
data_mythos_OMP2     = read_data("ODTMythosOMP2.out")
data_linux_OMP4      = read_data("ODTLinuxOMP4.out")
data_mythos_OMP4     = read_data("ODTMythosOMP4.out")
data_linux_OMP6      = read_data("ODTLinuxOMP6.out")
data_mythos_OMP6     = read_data("ODTMythosOMP6.out")

data_to_plot_1 = [data_linux_OMP1, data_linux_OMP2, data_linux_OMP4, data_linux_OMP6]
data_to_plot_2 = [data_mythos_OMP1, data_mythos_OMP2, data_mythos_OMP4, data_mythos_OMP6]

x = np.array([900,2000])
fig1, ax1 = plt.subplots()
ax1.set_title("Skalierbarkeit ODTLES")
bp1 = plt.boxplot(data_to_plot_1,0,'',positions=x-150,widths=250, patch_artist=True, boxprops=dict(facecolor="C0"))
bp2 = plt.boxplot(data_to_plot_2,0,'',positions=x+150,widths=250, patch_artist=True, boxprops=dict(facecolor="C2"))
ax1.legend([bp1["boxes"][0], bp2["boxes"][0]], ['Linux', 'MyThOS'], loc='upper right')
ax1.set_xticklabels(['1 Thread', '2 Threads', '4 Threads', '6 Threads'])
ax1.set_xticks([900,2000])
ax1.set_xlim([500,2500])
ax1.set_ylabel("Laufzeit in Sekunden")
fig1.savefig("ODTLES.pdf", bbox_inches="tight")


data_to_plot_1 = [data_linux, data_linux_OMP1, data_mythos_muslheap, data_mythos_seqheap, data_mythos_OMP1]

fig1, ax1 = plt.subplots()
ax1.set_title("Heap")
bp1 = plt.boxplot(data_to_plot_1,0,'',widths=1, patch_artist=True, labels=['Linux','Linux_OMP1','MyThOS_muslheap','MyThOS_seqheap','MyThOS_OMP1'])
colors = ['blue', 'green', 'purple', 'tan', 'pink', 'red']
for patch, color in zip(bp1['boxes'], colors):
    patch.set_facecolor(color)
ax1.legend([bp1["boxes"][0],bp1["boxes"][1],bp1["boxes"][2],bp1["boxes"][3],
            bp1["boxes"][4]], ['1_Linux','2_Linux_OMP1','3_MyThOS_muslheap',
            '4_MyThOS_seqheap','5_MyThOS_OMP1'], loc='upper right')
ax1.set_ylabel("Laufzeit in Sekunden")
#ax1.set_ylim([48,49])
ax1.set_xticklabels(['1','2','3','4','5'])
fig1.savefig("heap.pdf", bbox_inches="tight")


