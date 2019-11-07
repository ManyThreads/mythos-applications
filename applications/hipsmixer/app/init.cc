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

mythos::InvocationBuf* msg_ptr asm("msg_ptr");
int main() asm("main");

constexpr uint64_t stacksize = 64*4096;
char initstack[stacksize];
char* initstack_top = initstack+stacksize;

mythos::Portal portal(mythos::init::PORTAL, msg_ptr);
mythos::CapMap myCS(mythos::init::CSPACE);
mythos::PageMap myAS(mythos::init::PML4);
mythos::KernelMemory kmem(mythos::init::KM);
mythos::SimpleCapAllocDel capAlloc(portal, myCS, mythos::init::APP_CAP_START,
                                  mythos::init::SIZE-mythos::init::APP_CAP_START);

//__attribute__((constructor))
void initMythos(){
  //MLOG_INFO(mlog::app, "init Mythos");
  //mythos::localEC = mythos::init::EC; //important initialization!!

  mythos::PortalLock pl(portal);
  uintptr_t vaddr = 4096 << 18;
  
  //MLOG_INFO(mlog::app, "create page map");
  mythos::PageMap p2(capAlloc());
  p2.create(pl, kmem, 2);
  
  //MLOG_INFO(mlog::app, "map level 2 page map on level 3", DVARhex(vaddr));
  auto res1 = myAS.installMap(pl, p2, vaddr, 3,
                              mythos::protocol::PageMap::MapFlags().writable(true).configurable(true)).wait();

  //MLOG_INFO(mlog::app, "Mythos: Init Heap");
  //uintptr_t vaddr = 22*1024*1024; // choose address different from invokation buffer
  
  auto size = 512*1024*1024; // 2 MB
  auto align = 2*1024*1024; // 2 MB

  mythos::Frame f(capAlloc());
  auto res2 = f.create(pl, kmem, size, align).wait();
  // map the frame into our address space
  auto res3 = myAS.mmap(pl, f, vaddr , size, 0x1).wait();
  //MLOG_INFO(mlog::app, "mmap frame", DVAR(res3.state()),
	    //DVARhex(res3->vaddr), DVAR(res3->level));
  mythos::heap.addRange(vaddr , size);
	
}
