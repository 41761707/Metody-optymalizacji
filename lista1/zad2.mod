# Radosław Wojtczak 254607
# Lista 1 Zadanie 2

#Zbiór miast
set Cities;

#Zbiór dźwigów
set Cranes;

#Odległości między miastami
param distance{Cities,Cities} >= 0;

#Nadmiarowe dźwigi per miasto
param excess{Cranes,Cities} >= 0;

#Brakujące dźwigi per miasto
param deficiency{Cranes,Cities} >= 0;

#Koszt transportu
param transport_cost{Cranes} >= 0;

#Możliwość zamiany
param could_replace symbolic in Cranes;

#Wynik w formie : miasto, miasto, liczba dźwigów do przetransportowania
var solution{Cities, Cities, Cranes} >= 0;

#Minimalizacja funkcji transportu między miastami zależna od typu dźwigu oraz odległości między miastami
minimize cost_func: sum{crane in Cranes}(sum{c1 in Cities, c2 in Cities} distance[c1, c2] * solution[c1, c2, crane] * transport_cost[crane]);

#Wszystkie nadmiarowe dźwigi muszą zostać przewiezione
subject to move_all_excessive{c1 in Cities, crane in Cranes}: sum{c2 in Cities} solution[c1, c2, crane] == excess[crane, c1];

#Zastąpienie dźwigów typu pierwszego, dźwigami typu drugiego
subject to move_replacable{c1 in Cities}: sum{c2 in Cities} solution[c2, c1, could_replace] >= deficiency[could_replace, c1];

#Wszystkie braki muszą zostać uzupełnione
subject to sent{c1 in Cities}:  sum{crane in Cranes}(sum{c2 in Cities} solution[c2, c1, crane]) == sum{crane in Cranes} deficiency[crane, c1];

solve;

for{c1 in Cities} 
{
    for{c2 in Cities} 
    {
        for{crane in Cranes} 
        {
            printf (if solution[c1, c2, crane] != 0 then "Przenieś %d dzwigi typu %s z %s do %s\n" else ""), solution[c1, c2, crane], crane, c1, c2 ;
        }
    }
}

printf "Total cost: %f\n", cost_func;