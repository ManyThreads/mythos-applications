import numpy as np
import matplotlib.pyplot as plt
import sys as sys
import seaborn as sns
import pandas as pd


#function for reading the run times from *.out files
def read_data( file_name ):
    print("read_data "+file_name)
    data = []
    with open(file_name) as fp:
        line = fp.readline()
        while line:
            words = line.split()
            if(len(words)>1):
                # if(words[0] == "Duration"):
                data.append(float(words[1]))
            line  = fp.readline()
    return(sorted(data))

# reading data
scenarios = ["PthreadCreate", "PthreadResponse", "PthreadJoin"]
platforms = ["Mythos", "Linux"]

data = []
for s in scenarios:
    for p in platforms: 
        vals = read_data(p+"_"+s+".out");
        for v in vals:
            data.append([p, s, v])

# print(data)

# Create the pandas DataFrame 
df = pd.DataFrame(data, columns = ['platform', 'scenario', 'time']) 
# print(df)

ax = sns.boxplot(x='scenario', y='time', hue='platform', data=df)
ax.set(xlabel='', ylabel='time in µs')
plt.title("Posix-Thread Overhead")
plt.savefig("pthread_overhead.pdf")
# plt.show()


