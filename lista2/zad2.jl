#Radosław Wojtczak 254607
#Lista 2 zadanie 2

using JuMP
using GLPK

#Funkcja obsługująca harmonogramowanie zadań dla jednej maszyny
# @param n - liczba zadań
# @param p - czasy wykonywania zadań
# @param r - slot czasu, od którego dane zdanie może zostać rozpoczęte
# @param w - waga zadania
# W tym problemie czas traktujemy w sposób dyskretny
# Dzielimy go na "sloty"
function SingleMachineScheduling(n,p::Vector{Int},r::Vector{Int},w::Vector{Int})
    #Definicja modelu
    model = Model(GLPK.Optimizer)
    #Maksymalny czas pracy maszyny
    max_T = maximum(r) + sum(p) + 1
    #Wektor prac
    jobs = 1:n
    #Wektor slotów czasowych
    times = 0:max_T

    #Definicja zmiennej decyzyjnej
	@variable(model, x[jobs,times], Bin) 
	
    #Definicja funkcji celu jako minimalizacja iloczynu wagi oraz czasu zakończenia pracy
	@objective(model,Min, sum(w[j]*(t+p[j])*x[j,t] for  j in jobs, t in times)) 
	
    #Każda praca może mieć tylko jeden moment rozpoczęcia 
	for j in jobs
		@constraint(model,sum(x[j,t] for t in times)==1)
	end
	
	#j-te zadanie może rozpocząć nie wcześniej, niż wskazuje na to wartość r[j]
	for j in jobs
		@constraint(model,sum(t*x[j,t] for  t in times)>=r[j])
	end

    #Maksymalnie jedno zadanie może być wykonywane w danej jednostce czasu
	for t in times
		@constraint(model,sum(x[j,s]  for  j in jobs, s in max(0, t-p[j]+1):t)<=1)
	end

    print(model)

    optimize!(model)

    status=termination_status(model)
    if status == MOI.OPTIMAL
        return status,objective_value(model),value.(x)
    else
        return status,nothing,nothing
    end
end

#-----------------------------#
#       SEKCJA DANYCH
#-----------------------------#
#Definicje zmiennych
n = 6
p = [2,3,4,1,3,2]
w = [3,2,1,4,4,6]
r = [2,1,1,0,0,4]
#-----------------------------#
#       SEKCJA DANYCH
#-----------------------------#

#Wywołanie funkcji
(status,cel,momenty) = SingleMachineScheduling(n,p,r,w)

#Wypisanie wyniku
if status==MOI.OPTIMAL
    println("Funkcja celu: ",cel)
    for i in 1:n
        for j in 0:maximum(r) + sum(p) + 1
            if(momenty[i,j]!=0)
                println("Zadanie: $i, rozpoczęcie realizacji: $j")
            end
        end
    end
else
    println("Status: ",status)
end

