#include <iostream>
using namespace std;

class Complex 
  {
  public:
  Complex (double a, double b): r (a), c (b) {}
  private:
  double r; // Real Part
  double c; // Complex Part
  };
   
int main(int argc, char* argv[]) 
  {
    
    clock_t begin = clock();

  Complex* array[20000];

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

  

  

  
  