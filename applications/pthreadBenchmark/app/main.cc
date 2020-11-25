#include <iostream>
#include <sys/time.h>
#include <pthread.h>
#include <atomic>

std::atomic<bool> started;

void* threadBench(void* arg){
  //std::cout << "Thread says hello" << std::endl;
  started.store(true);
  return 0;
}

void bench_pthreads(){
  std::cout << "Test Pthreads" << std::endl;
 
  timeval start, create, running, join;
  started.store(false);
  
  asm volatile ("":::"memory");
  gettimeofday(&start, 0);
	asm volatile ("":::"memory");

	pthread_t p;
	auto tmp = pthread_create(&p, NULL, &threadBench, (void*) 0xBEEF);

  asm volatile ("":::"memory");
  gettimeofday(&create, 0);
	asm volatile ("":::"memory");

  while(!started.load());

  asm volatile ("":::"memory");
  gettimeofday(&running, 0);
	asm volatile ("":::"memory");
  
	pthread_join(p, NULL);

  asm volatile ("":::"memory");
  gettimeofday(&join, 0);
	asm volatile ("":::"memory");

  double cseconds =(create.tv_usec - start.tv_usec)/1000000.0 + create.tv_sec - start.tv_sec;
  double jseconds =(join.tv_usec - start.tv_usec)/1000000.0 + join.tv_sec - start.tv_sec;
  double rseconds =(running.tv_usec - start.tv_usec)/1000000.0 + running.tv_sec - start.tv_sec;

  std::cout << "creation: " << cseconds << "s running: " << rseconds << "s join: "<< jseconds << "s" << std::endl; 
  std::cout << "End Test Pthreads" << std::endl;
}


int main(){
  std::cout << "Main started" << std::endl;
  
  bench_pthreads();

  return 0;
};
