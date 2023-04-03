# Radosław Wojtczak 254607
# Lista 1 Zadanie 1

#Parametr n- rozmiar macierzy
param n, integer >= 0;

#Definicja macierzy A
param A{i in {1..n}, j in {1..n}} := 1/(i+j-1);

#Definicja b
param b{i in {1..n}} := sum{j in {1..n}}(1/(i+j-1));

#Definicja c
param c{i in {1..n}} := sum{j in {1..n}}(1/(i+j-1));

#Założenie odnośnie wektora x
var x{i in {1..n}} >= 0;

#Minimalizacja funkcji podanej z zadania
minimize func: sum{i in {1..n}} c[i]*x[i];

#Względem warunku Ax = b
subject to result{i in {1..n}}: sum{j in {1..n}} A[i,j] * x[j] = b[i];

solve;

#Wypisanie otrzymanego błędu względnego
printf "error: %f\n", sqrt(sum{i in {1..n}} ((1 - x[i]) * (1 - x[i]))) / sqrt(n);

data;

param n := 8;

end;


