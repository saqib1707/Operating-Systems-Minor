#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<sys/wait.h>
#include<unistd.h>     //contains functions like pipe,close,etc
#include<math.h>

#define read_end 0
#define write_end 1

bool isPrime(int a){
	bool prime = true;
	for(int j=2; j<=sqrt(a); j++){
		if(a%j==0){
			prime=false;
			break;
		}
	}
	return prime;
}
int main(){
	int fd1[2],fd2[2],fd3[2],fd4[2];    //pipes for 2 way communication between parent and child
	int ret1, ret2;                 //fork return values corresponding to 2 children
	bool flag = true;
	int a,b,n,count_c1=0,count_c2=0;
	printf("Enter n:");
	scanf("%d", &n);
	int c1[n],c2[n];
	
	
	
	if(pipe(fd1) == -1){
		printf("failed to create pipe 1\n");
		exit(1);
	}
	if(pipe(fd2) == -1){
		printf("failed to create pipe 2\n");
		exit(1);
	}
	if(pipe(fd3) == -1){
		printf("failed to create pipe 3\n");
		exit(1);
	}
	if(pipe(fd4) == -1){
		printf("failed to create pipe 4\n");
		exit(1);
	}


	ret1 = fork();    //creating first child
	if(ret1 < 0){
		printf("failed to create a new child\n");
		exit(1);
	}
	if(ret1 != 0)
	{   // parent process P
		ret2 = fork();    //parent creating second child
		if(ret2 < 0)
		{
			printf("failed to create a new child\n");
			exit(1);
		}
	}

	if(ret1 !=0 && ret2 != 0)    //parent executes
	{
		close(fd1[read_end]);
		close(fd2[read_end]);
		for(int i=2 ;i<=n; i++)
		{
			if((i%2 == 0 || i%3 == 0 || i%5 == 0 || i%7 == 0 	|| i%11 == 0) && 
					i!=2 && i!=3 && i!=5 && i!=7 && i!=11)                           //numbers are composite if they satisfy the condition
			{
				//do nothing
			}
			
			else
			{
			
				if(flag)
				{             // if flag == true then write to the pipe of C1
					printf("writing %d to c1\n",i);
					write(fd1[write_end], &i, sizeof(i));
					flag = !flag;      //flipping the flag with the aim of equally distributing numbers among c1 and c2
					
				} 
				else
				{                // if flag == false then write to the pipe of C2
					
					printf("writing %d to c2\n",i);
					write(fd2[write_end], &i, sizeof(i));
					flag = !flag;
					
				}
			}
		}

	    printf("Parent has completed writing\n");

		close(fd1[write_end]);  //required to close the writing end of file(with fd1) so that c1 stops reading
		close(fd2[write_end]);  //required to close the writing end of file(with fd2) so that c2 stops reading
		

		close(fd3[write_end]);   //parent is receiving data through fd3 pipe so it is closing its writing end 

		while(read(fd3[read_end], &a, sizeof(a))>0) 
		{
			printf("parent read %d from c1\n", a);
			c1[count_c1++]=a;
			
		}

		close(fd3[read_end]);      
		printf("finished reading from C1\n");
			
		close(fd4[write_end]);
		
		while(read(fd4[read_end], &a, sizeof(a))>0)
		{
			
			printf("parent read %d from c2\n", a);
			c2[count_c2++]=a;
						
		}
		close(fd4[read_end]);
		printf("finished reading from C2\n");
		printf("count_c1=%d count_c2=%d\n",count_c1,count_c2);

		wait(NULL);

	    int k=0,l=0;
	    printf("List of prime numbers between 1 and %d:\n",n);
        if(n==1) printf("No primes\n");
	    while((k<=count_c1-1)&&(l<=count_c2-1))
	    {
  			if(c1[k]<c2[l]) 
  				{
  					printf("%d\n",c1[k]);
  					k++;
  				}
  			else 
  				{
  					printf("%d\n",c2[l]);
  					l++;
  				}
  			
	    }
	    while(k<=count_c1-1)
	    {
          printf("%d\n",c1[k]);
          k++;
	    }

	    while(l<=count_c2-1)
	    {
          printf("%d\n",c2[l]);
          l++;
	    }

	    exit(0);
		
	}
	if(ret1 == 0)
	{    // child 1
		printf("Inside child 1\n");

		//c1 closes writing ends which won't be used by it so that no reader is waiting for any data
		close(fd1[write_end]);
		close(fd2[write_end]);
		close(fd3[read_end]);
		close(fd4[write_end]);
		while(read(fd1[read_end], &a, sizeof(a))>0)
		{
			printf("c1 read %d\n",a);
			if(isPrime(a))
			{
				printf("c1 writing %d\n",a);
				write(fd3[write_end], &a, sizeof(a));
			}
		}
		//c1 closes writing end of fd3 to indicate to parent that all the data has been written
		close(fd3[write_end]);
		printf("Child1 is going to exit\n");
		exit(0);
	}

	if(ret1 !=0 && ret2 == 0)
	{         // child 2
		printf("Inside child 2\n");
		
		//c2 closes writing ends which won't be used by it so that no reader is waiting for any data
		close(fd1[write_end]);
		close(fd1[write_end]);
		close(fd2[write_end]);
		close(fd3[write_end]);
		close(fd4[read_end]);
		while(read(fd2[read_end], &b, sizeof(b))>0)
		{
			printf("c2 read %d\n",b);
				if(isPrime(b)){
				
					printf("c2 writing %d\n",b);
				write(fd4[write_end], &b, sizeof(b));
			}
		}
		//c2 closes writing end of fd4 to indicate to parent that all the data has been written
		close(fd4[write_end]);
		printf("Child2 is going to exit\n");
		exit(0);
	}
}
