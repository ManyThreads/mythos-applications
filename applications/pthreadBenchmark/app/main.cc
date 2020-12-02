#include <iostream>
#include <sys/time.h>
#include <pthread.h>
#include <atomic>

#ifndef BENCH_ITERATIONS
#define BENCH_ITERATIONS 1
#endif

void* threadBenchCreate(void* arg){
  std::cout << "Thread says hello" << std::endl;
  return 0;
}

void bench_pthread_create(){
  std::cout << "Test Pthread Create" << std::endl;
 
  timeval start, create;
  
  asm volatile ("":::"memory");
  gettimeofday(&start, 0);
	asm volatile ("":::"memory");

	pthread_t p;
	auto tmp = pthread_create(&p, NULL, &threadBenchCreate, (void*) 0xBEEF);

  asm volatile ("":::"memory");
  gettimeofday(&create, 0);
	asm volatile ("":::"memory");

  if(tmp == 0){
    pthread_join(p, NULL);
    uint64_t time =(create.tv_usec - start.tv_usec) + (create.tv_sec - start.tv_sec)*1000000;
    std::cout << "PthreadCreate " << time << " us" << std::endl; 
  }else{
    std::cout << "Error: pthread_create failed!!!" << std::endl;
  }
  std::cout << "End Test Pthreads" << std::endl;
}

std::atomic<bool> started;

void* threadBenchResponse(void* arg){
  started.store(true);
  return 0;
}

void bench_pthread_response(){
  std::cout << "Test Pthreads" << std::endl;
 
  timeval start, response;
  started.store(false);
  
  asm volatile ("":::"memory");
  gettimeofday(&start, 0);
	asm volatile ("":::"memory");

	pthread_t p;
	auto tmp = pthread_create(&p, NULL, &threadBenchResponse, (void*) 0xBEEF);

  if(tmp == 0){
    while(!started.load());
    
    asm volatile ("":::"memory");
    gettimeofday(&response, 0);
    asm volatile ("":::"memory");

    pthread_join(p, NULL);
    uint64_t time =(response.tv_usec - start.tv_usec) + (response.tv_sec - start.tv_sec)*1000000;
    std::cout << "PthreadResponse " << time << " us" << std::endl; 
  }else{
    std::cout << "Error: pthread_create failed!!!" << std::endl;
  }
  std::cout << "End Test Pthreads" << std::endl;
}

void* threadBenchCreateJoin(void* arg){
  return 0;
}

void bench_pthread_create_join(){
  std::cout << "Test Pthreads" << std::endl;
 
  timeval start, join;
  started.store(false);
  
  asm volatile ("":::"memory");
  gettimeofday(&start, 0);
	asm volatile ("":::"memory");

	pthread_t p;
	auto tmp = pthread_create(&p, NULL, &threadBenchCreateJoin, (void*) 0xBEEF);

  if(tmp == 0){
    pthread_join(p, NULL);
    asm volatile ("":::"memory");
    gettimeofday(&join, 0);
    asm volatile ("":::"memory");
    uint64_t time =(join.tv_usec - start.tv_usec) + (join.tv_sec - start.tv_sec)*1000000;
    std::cout << "PthreadJoin " << time << " us" << std::endl; 
  }else{
    std::cout << "Error: pthread_create failed!!!" << std::endl;
  }
  std::cout << "End Test Pthreads" << std::endl;
}

int main(){
  std::cout << "Main started" << std::endl;

  for(int i=0; i < BENCH_ITERATIONS; i++){
    bench_pthread_create();
  }

  for(int i=0; i < BENCH_ITERATIONS; i++){
    bench_pthread_response();
  }

  for(int i=0; i < BENCH_ITERATIONS; i++){
    bench_pthread_create_join();
  }

  std::cout << "Main finished" << std::endl;
  return 0;
};
