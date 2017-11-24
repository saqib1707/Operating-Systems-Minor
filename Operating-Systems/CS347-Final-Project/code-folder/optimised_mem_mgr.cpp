 #include <iostream>
#include <stdlib.h> 
using namespace std;

struct Block  
  {
  Block* next;
  };

  class GenMag  
  {
    
  public:
    
    virtual void* allocate(size_t) = 0;
    virtual void   free(void*) = 0;
  };
 
 class Comp_mem_mag: public GenMag   
  { 

   void expandPoolSize ();
  void cleanUp ();
  Block* BlockHead;
  public:
    Comp_mem_mag () { 
      BlockHead = 0;
     expandPoolSize (); 
            }

     virtual ~Comp_mem_mag () {    
      cleanUp ();
      }
    virtual void* allocate(size_t);
    virtual void   free(void*);
  };
 
 GenMag* gMemoryManager=new Comp_mem_mag;    // Memory Manager, global variable


class Complex
  {
  public:
    Complex (double a, double b): x (a), y (b) {}
    inline void* operator new(size_t);
    inline void   operator delete(void*);
  private:
    double x; 
    double y; 
  };


inline void* Comp_mem_mag::allocate(size_t size)
  {

 if (BlockHead==NULL)
    expandPoolSize ();
   Block* head = BlockHead;
  BlockHead = head->next;
  return head;
  }
 
inline void Comp_mem_mag::free(void* deleted)
  {
  Block* head = static_cast <Block*> (deleted);
  head->next = BlockHead;
  BlockHead = head;
  }

   
void* Complex::operator new (size_t size) 
  {
    
  return gMemoryManager->allocate(size);
  
  }
 
void Complex::operator delete (void* pointerToDelete)
  {
     gMemoryManager->free(pointerToDelete);
  }

#define POOLSIZE 1
 
void Comp_mem_mag::expandPoolSize ()
  {
    size_t size = (sizeof(Complex) > sizeof(Block*)) ?
    sizeof(Complex) : sizeof(Block*);

 Block* head = reinterpret_cast <Block*> (new char[size]);
  BlockHead = head;

  for (int i = 0; i < 100; i++) {
    head->next = reinterpret_cast <Block*> (new char [size]);
    head = head->next;
    }
 
  head->next = NULL;
  
  }
 
void Comp_mem_mag::cleanUp()
  {

  Block* nextPtr = BlockHead;
  for (; nextPtr; nextPtr = BlockHead) {
    BlockHead = BlockHead->next;
    delete [] nextPtr; 
    }
  }
  int main(int argc, char* argv[]) 
  {
    
    clock_t begin = clock();

  Complex* array[20000];
//allocating space to 20000 complex numbers in heap(16B) and then deallocating 
  //repeating this 1000 times
for(int k=0;k<1000;k++){
      for (int j = 0; j  <  20000; j++) 
      array[j] = new Complex (j, j*j);
   
      for (int j = 0; j  <  20000; j++) {
      delete array[j];
      }
    }

   
    clock_t end = clock();
    double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;
    cout<<elapsed_secs<<endl;


  return 0;
  }