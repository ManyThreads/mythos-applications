/* -*- mode:C++; indent-tabs-mode:nil; -*- */
/* MIT License -- MyThOS: The Many-Threads Operating System
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Copyright 2016 Randolf Rotta, Robert Kuban, and contributors, BTU Cottbus-Senftenberg
 */

#include "mythos/init.hh"
#include "mythos/invocation.hh"
#include "mythos/protocol/CpuDriverKNC.hh"
#include "mythos/PciMsgQueueMPSC.hh"
#include "runtime/Portal.hh"
#include "runtime/ExecutionContext.hh"
#include "runtime/CapMap.hh"
#include "runtime/Example.hh"
#include "runtime/PageMap.hh"
#include "runtime/KernelMemory.hh"
#include "runtime/SimpleCapAlloc.hh"
#include "runtime/tls.hh"
#include "runtime/mlog.hh"
#include "runtime/InterruptControl.hh"
#include <cstdint>
#include "util/optional.hh"
#include "runtime/umem.hh"
#include "runtime/Mutex.hh"

#include <omp.h>

mythos::InvocationBuf* msg_ptr asm("msg_ptr");
int main() asm("main");

constexpr uint64_t stacksize = 4*4096;
char initstack[stacksize];
char* initstack_top = initstack+stacksize;

mythos::Portal portal(mythos::init::PORTAL, msg_ptr);
mythos::CapMap myCS(mythos::init::CSPACE);
mythos::PageMap myAS(mythos::init::PML4);
mythos::KernelMemory kmem(mythos::init::KM);
mythos::SimpleCapAllocDel capAlloc(portal, myCS, mythos::init::APP_CAP_START+2,
                                  mythos::init::SIZE-mythos::init::APP_CAP_START - 2);


extern "C" void _init(){
  MLOG_INFO(mlog::app, "_init");
mythos::Portal initportal(mythos::init::PORTAL, msg_ptr);
mythos::CapMap initmyCS(mythos::init::CSPACE);
mythos::PageMap initmyAS(mythos::init::PML4);
mythos::KernelMemory initkmem(mythos::init::KM);
  mythos::PortalLock pl(initportal);
  uintptr_t vaddr = 4096 << 18;
  mythos::PageMap p2(mythos::init::APP_CAP_START);
  p2.create(pl, initkmem, 2);
  auto res1 = initmyAS.installMap(pl, p2, vaddr, 3,
                              mythos::protocol::PageMap::MapFlags().writable(true).configurable(true)).wait();

  auto size = 512*1024*1024; // 2 MB
  auto align = 2*1024*1024; // 2 MB

  mythos::Frame f(mythos::init::APP_CAP_START+1);
  auto res2 = f.create(pl, initkmem, size, align).wait();
  auto res3 = initmyAS.mmap(pl, f, vaddr , size, 0x1).wait();
  mythos::heap.init();
  mythos::heap.addRange(vaddr , size);
}

void test_omp(){
  MLOG_INFO(mlog::app, "Test Openmp");
  int nthreads, tid;
  omp_set_num_threads(2);
/* Fork a team of threads giving them their own copies of variables */
#pragma omp parallel private(nthreads, tid)
  {

  /* Obtain thread number */
  tid = omp_get_thread_num();
  MLOG_INFO(mlog::app, "Hello World from thread", DVAR(tid));

  /* Only master thread does this */
  if (tid == 0) 
    {
    nthreads = omp_get_num_threads();
  MLOG_INFO(mlog::app, "Number of threads", DVAR(nthreads));
    }

  }
  MLOG_INFO(mlog::app, "End Test Openmp");
}

int main()
{
  char const str[] = "hello world!";
  char const end[] = "bye, cruel world!";
  mythos::syscall_debug(str, sizeof(str)-1);

  test_omp();

  mythos::syscall_debug(end, sizeof(end)-1);

  return 0;
}
