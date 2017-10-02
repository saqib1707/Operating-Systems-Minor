g++ -g -pthread q2_pthread_mutex_lock.c -o q2_pthread_mutex_lock
for i in `seq 1 50` ; do
	./q2_pthread_mutex_lock
done

lohithravuru@gmail.com