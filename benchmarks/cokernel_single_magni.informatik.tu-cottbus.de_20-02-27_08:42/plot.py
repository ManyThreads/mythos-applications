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
data_linux           = read_data("ODTLinux.out")
data_mythos_muslheap = read_data("ODTMythosMuslHeap.out")
data_mythos_seqheap  = read_data("ODTMythosSeqHeap.out")

# data for heap plot
data_to_plot_heap = [ data_mythos_seqheap, data_mythos_muslheap,               \
                      data_linux]

# plot heap version 2
fig1, ax1 = plt.subplots()
ax1.set_title("ODT-LES Linux/MyThOS Co-Kernel")
bp1 = plt.boxplot(data_to_plot_heap,0,'',widths=1, patch_artist=True)
colors = ['blue', 'green', 'purple', 'tan', 'pink', 'red']
for patch, color in zip(bp1['boxes'], colors):
    patch.set_facecolor(color)
ax1.set_ylabel("Runtime in seconds")
#ax1.set_ylim([48,49])
xticklabels = ['MyThOS_seqheap','MyThOS_muslheap','Linux']
ax1.set_xticklabels(xticklabels, rotation = 60)
ax1.tick_params(axis='both', which='major', labelsize=10)
fig1.savefig("heap_version_2.pdf", bbox_inches="tight")


