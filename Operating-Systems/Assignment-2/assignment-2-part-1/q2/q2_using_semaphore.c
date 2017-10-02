//#include "semaphore.h"
#include "pthread.h"
#include <stdlib.h>		// for srand, rand
#include <unistd.h>
#include "time.h"
#include <iostream>
#include<stdio.h>
#include<string.h>
#include <vector>
#include<math.h>
#define BUFFER_CAP 2
#define total_party 20
#define total_threads 10
using namespace std;

//int finite_num = 50; // some random iterations
//Semaphore empty_count = Semaphore(BUFFER_CAP);
//Semaphore filled_count = Semaphore(0);
//int buffer_size = 0;
//Semaphore buffer_lock = Semaphore(1);

int party_tally[total_party];
int mutex=1;
int sum=0;
int prev_sum =0;
/*
int produce_item(){
	cout<<endl<<"Produced"<<endl;
	return 0;
}

void put_item_in_buffer(int item){
	buffer_lock.down();
	// some action
	cout<< endl<< "Added | Buffer size : " << ++buffer_size << endl;
	buffer_lock.up();
	return;
}

int remove_item_from_buffer(){
	buffer_lock.down();
	// some action
	cout<< endl<< "Removed | Buffer size : " << --buffer_size << endl;
	buffer_lock.up();
	return 0;
}

void producer(){
	while(--finite_num > 0){ 	// finite_num shared but dont care
		int item = produce_item();
		empty_count.down();
		put_item_in_buffer(item);
		filled_count.up();
		sleep(rand()%2);
	}
}

void consumer(){
	while(--finite_num > 0){
		cout<<endl<<"Try to remove"<<endl;
		filled_count.down();
		int item = remove_item_from_buffer();
		empty_count.up();
		// consume item
		sleep(rand()%2);
	}
}
*/
/*
void *thread_run(void *data){          // void pointer(generic pointer) can be pointed at objects of any data type

	int thread_id = *((int *)data);
	if (thread_id == 0) producer();
	else consumer();

}
*/
/*
void wait(int *s){
	while(*s<=0);
	--(*s);
}
void signal(int *s){
	++(*s);
}
*/
void *thread_run(void *data){
	int thread_id = *((int*)data);
	char file_name[20] = "files/file";
    file_name[10]=thread_id+48;
    char *input_file = strcat(file_name,".txt");

    FILE *fptr;
	fptr = fopen(input_file, "r");
	if(fptr == NULL){
		printf("Error opening file %d", thread_id);
		exit(0);
	}
	else{
		// read the file
		char * line = NULL;
		size_t len = 0;
		ssize_t myread;
		char *key,*value,*ch;
		int key_val, value_val;
		while ((myread = getline(&line, &len, fptr)) != -1) {
	        //printf("Retrieved line of length %zu :\n", read);
	        //printf("%s", line);
	        if(myread > 4){      // 
	            ch = strtok(line, " ");
	            key = ch;
	            while (ch != NULL) {
	                ch = strtok(NULL, " ");
	                if(ch!=NULL){
	                    value=ch;
	                }
	            }
	            sscanf(key, "%d", &key_val);
	            sscanf(value, "%d", &value_val);
	            wait(&mutex);
	            party_tally[key_val-1] += value_val;
	            sum += value_val;
	            if(floor(sum/50) != floor(prev_sum/50)){
	            	// display the election results
	            	for(int k=0;k<total_party;k++){
	            		printf("%d  ", party_tally[k]);
	            	}
	            	printf("\n\n");
	            }
	            //printf("%d, %d\n",key_val, value_val);
	            prev_sum=sum;
	            signal(&mutex);
	        }
    	}
    	fclose(fptr);
    	
    	if (line)
        	free(line);
	}
	pthread_exit(0);       // the thread calling it will get terminated. Argument is a &ret_val..passing the 
							//address of a variable to the function
} 

int main(int argc, char *argv[]){
	srand (time(NULL));
	pthread_attr_t attr;
	pthread_attr_init(&attr);
	vector<pthread_t> thr(total_threads);
	vector<int> tid(total_threads);
	for(int i=0;i<total_party;i++){
		party_tally[i]=0;
	}
	for(int i=0; i < total_threads; i++){
		tid[i] = i;
		pthread_create(&thr[i], NULL, thread_run,(void *)&tid[i]);
	}

	for(int i=0; i < total_threads; i++){
		pthread_join(thr[i], NULL);            // parent waiting for the thread to return
	}
	// the parent will reach here only when all the threads have returned
	printf("Election Result\n");
	for(int i=0;i<total_party;i++){
		printf("%d, %d\n",i+1, party_tally[i]);
	}
	exit(0);
}