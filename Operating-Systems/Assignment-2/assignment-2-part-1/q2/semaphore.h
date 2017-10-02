#include "pthread.h"
#include<stdlib.h>
#include<stdio.h>
#include<iostream>
using namespace std;

class Semaphore{
	int count;	//value of semaphore
	pthread_mutex_t lk; 	//lock used by up and down methods
	pthread_cond_t condvar; 	//conditional variable used by up and down methods

public:
	Semaphore(int N);
	void down();
	void up(); 
};

void panic(){
	cerr<<"Fatal error"<<endl;
	exit(1);
}


Semaphore::Semaphore(int N){
	count = N; //initialization
	if (pthread_cond_init(&condvar, NULL) != 0) panic();
	if (pthread_mutex_init(&lk, NULL)!=0) panic();
}

void Semaphore::down(){
	//acquire lock
	if (pthread_mutex_lock(&lk) !=0) panic();
	//wait for count to be positive
	while(count==0){
		if (pthread_cond_wait(&condvar,&lk)!=0) panic();
	}
	//decrement count
	count--;
	//unlock
	if (pthread_mutex_unlock(&lk)!=0) panic();
}

void Semaphore::up(){
	//acquire lock
	if (pthread_mutex_lock(&lk)!=0) panic();
	//increment count
	count++;
	//signal 
	if (pthread_cond_signal(&condvar)!=0) panic();
	//unlock
	if (pthread_mutex_unlock(&lk) !=0) panic();
}