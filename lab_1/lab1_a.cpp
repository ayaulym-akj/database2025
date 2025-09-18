#include <iostream>
using namespace std;
int main (){
    int a;
    cin >> a;
    while(a--){
        int n;
        cin >> n;
        int d[1000];
        int s=0;
        for(int k=n; k>=1; k--){
            for(int i=s; i>0; i--){
                d[i]=d[i-1];
            }
            d[0]=k;
            s++;
            for(int i=0; i<k; i++){
                int last= d[s-1];
                for(int j=s-1; j>0; j--){
                    d[j]=d[j-1];
                }
                d[0]=last;
            }
        }
        for(int i=0; i<s; i++){
            cout << d[i] << " ";
        }
        cout<< "\n";
    }
}