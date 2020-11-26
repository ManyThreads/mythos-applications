#-------------------------------------------------------------------------------
# C++ Compiler and compiler options
#-------------------------------------------------------------------------------

CC               ?= g++ 
CFLAGS           := -std=c++11 -march=native -Wfatal-errors -g -O2
CFLAGS           += -fno-stack-protector -static 
#CFLAGS           += -isystem ../../../libraries/cxx-amd64/usr/include/c++/v1 
#CFLAGS           += -isystem ../../../libraries/cxx-amd64/usr/include
CFLAGS           += -fopenmp -specs "../../../libraries/cxx-amd64/usr/lib/musl-gcc.specs" 
#CFLAGS           += -I../../../kernel-amd64/ 
CFLAGS           += -MP -MMD -pipe -Wl,--eh-frame-hdr  
CFLAGS           += $(CPPFLAGS)

APP_LIBS         := ../../../libraries/cxx-amd64/usr/lib/libomp.a ../../../libraries/cxx-amd64/usr/lib/libc++.a ../../../libraries/cxx-amd64/usr/lib/libc++abi.a ../../../libraries/cxx-amd64/usr/lib/libunwind.a ../../../libraries/cxx-amd64/usr/lib/libc.a -lgcc 

main : main.cc 
	$(CC) $(CFLAGS) main.cc -o main $(APP_LIBS)
	@echo "done"

run : main
	./main

clean :
	rm main
