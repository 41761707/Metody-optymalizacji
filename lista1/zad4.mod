#Radosław Wojtczak 254607
#Lista 1 Zadanie 4



set Subjects ;
set Groups ;
set Prefrences{1..10} ;
param preferences{Subjects,Groups} >= 0;
param start_hours{Subjects,Groups} >= 0;
param end_hours{Subjects,Groups} >= 0;
param days{Subjects,Groups} >= 0;

var solution{Subjects, Groups} >= 0;

minimize cost_func : 

solve;

display cost_func;

data;

set Subjects := Algebra Analiza Fizyka Chemia_Mineralow Chemia_Organiczna

set Groups := 'I' 'II' 'III' 'IV' 

param preferences : Algebra Analiza Fizyka Chemia_Mineralow Chemia_Organiczna :=
    'I'     5   4   3   10  0
    'II'    4   4   5   10  5
    'III'   10  5   7   7   3
    'IV'    5   6   8   5   4

param start_hours : Algebra Analiza Fizyka Chemia_Mineralow Chemia_Organiczna :=
    'I'     13  13  8   8   9
    'II'    10  10  10  8   10.5
    'III'   10  11  15  13  11
    'IV'    11  8   17  13  13

param end_hours : Algebra Analiza Fizyka Chemia_Mineralow Chemia_Organiczna :=
    'I'     15  15  11  10  10.5
    'II'    12  12  13  10  12
    'III'   12  13  18  15  12.5
    'IV'    13  10  20  15  14.5

param days : Algebra Analiza Fizyka Chemia_Mineralow Chemia_Organiczna :=
    'I'     1   1   2   1   1
    'II'    2   2   2   1   1
    'III'   3   3   4   4   5
    'IV'    3   4   4   5   5

end;
