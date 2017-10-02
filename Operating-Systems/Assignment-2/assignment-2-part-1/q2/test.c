#include "pthread.h"
#include <stdlib.h>		// for srand, rand
#include <unistd.h>
#include "time.h"
#include <iostream>
#include<stdio.h>
#include<string.h>
#include <vector>
#include<math.h>
#include"copy_semaphore.h"
using namespace std;
#define total_threads 2
Semaphore mutex = Semaphore(1);
/*
void wait(int *s){
	while(*s<=0);
	--(*s);
}
void signal(int *s){
	++(*s);
}
*/

void producer(){
	mutex.down();
}

void consumer(){
	mutex.up();
}

void *thread_run(void *data){          // void pointer(generic pointer) can be pointed at objects of any data type

	int thread_id = *((int *)data);
	if (thread_id == 0) producer();
	else consumer();

}

int main(){
	srand (time(NULL));
	pthread_attr_t attr;
	pthread_attr_init(&attr);
	vector<pthread_t> thr(total_threads);
	vector<int> tid(total_threads);

	for(int i=0; i < total_threads; i++){
		tid[i] = i;
		pthread_create(&thr[i], NULL, thread_run,(void *)&tid[i]);
	}

	for(int i=0; i < total_threads; i++){
		pthread_join(thr[i], NULL);            // parent waiting for the thread to return
	}
	return 0;
}