#define INPUT(I,J) input[(I)*length+(J)]
#define OUTPUT(I,J) output[(I)*length+(J)]

void simulate(double *input, double *output, int threads, int length, int iterations)
{
    void populate(){
        for(int i = 0 ; i < length/2 ; ++i){
            for(int j = 0 ; j < length/2 ; ++j){
                double cur = OUTPUT(i, j);
                OUTPUT(length-1-i, j) = cur;
                OUTPUT(i, length-1-j) = cur;
                OUTPUT(length-1-i, length-1-j);
            }
        }
    }
}