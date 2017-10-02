#include "semaphore.h"
#include "pthread.h"
#include <stdlib.h>		// for srand, rand
#include <unistd.h>
#include "time.h"
#include<stdio.h>
#include<string.h>
#include <vector>
#include<math.h>
#define total_party 20
#define total_threads 10
using namespace std;

int party_tally[total_party];
int sum=0;
int prev_sum =0;
Semaphore mutex = Semaphore(1);

void *thread_run(void *data){
	int thread_id = *((int*)data);
	char file_name[20] = "files/file";
    file_name[10]=thread_id+48;
    char *input_file = strcat(file_name,".txt");
    //printf("%s\n",input_file);
    //fflush(stdout);

    FILE *fptr;
	fptr = fopen(input_file, "r");
	if(fptr == NULL){
		printf("Error opening file %d", thread_id);
		exit(0);
	}
	else{
		// read the file
		char * line = (char *)malloc(10);
		size_t len = 0;
		ssize_t myread;
		char *key,*value,*ch;
		int key_val, value_val;
		while ((myread = getline(&line, &len, fptr)) != -1) {
	        if(myread > 4){
	        	mutex.down();
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
	            party_tally[key_val-1] += value_val;
	            sum += value_val;
	            if(floor(sum/50) != floor(prev_sum/50)){
	            	// display the election results
	            	for(int k=0;k<total_party;k++){
	            		printf("%d  ", party_tally[k]);
	            	}
	            	printf("\n\n");
	            	fflush(stdout);
	            }
	            prev_sum=sum;
	            mutex.up();
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