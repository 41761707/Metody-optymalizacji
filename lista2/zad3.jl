#Radosław Wojtczak 254607
#Lista 2 zadanie 3

using JuMP
using GLPK

#Funkcja obsługująca harmonogramowanie zadań dla wielu maszyn
# @param n - liczba zadań
# @param m - liczba maszyn
# @param p - czasy wykonywania zadań
# @paramprecedence - relacja pierwszeństwa między zadaniami
# W tym problemie czas traktujemy w sposób dyskretny
# Dzielimy go na "sloty"
function MultiMachineScheduling(n::Int,m::Int,p::Vector{Int},precedence::Dict{Int, Vector{Int}})  
    #Definicja modelu
    model = Model(GLPK.Optimizer)
    #Maksymalny czas pracy maszyny
    max_T = sum(p) + 1
    #Wektor prac
    jobs = 1:n
    #Wektor slotów czasowych
    times = 0:max_T

    #Definicja zmiennej decyzyjnej
    @variable(model, x[jobs,times], Bin)    
    
    #Czas potrzebny do wykonania wszystkich zadań
    @variable(model, c_max >= 0, Int)

    #Funkcja celu- minimalizacja wymaganego czasu
    @objective(model, Min, c_max)

    # Wymagany czas nie może być mniejszy niż suma rozpoczęcia ostatniej pracy na maszynie oraz czasu jej trwania
    for j in jobs
        @constraint(model, sum(x[j,t] * (p[j] + t) for t in times) <= c_max) 
    end

    #Każda praca może mieć tylko jeden moment rozpoczęcia 
    for j in jobs
        @constraint(model, sum(x[j,t] for t in times) == 1)
    end

    #Zachowanie relacji pierwszeństwa między zadaniami
    for (j, relation) in precedence
        for k in relation
            @constraint(model, sum((p[j] + t) * x[j,t] for t in times) <= sum(t * x[k,t] for t in times))
        end
    end

    #W jednej jednostce czasu nie może być więcej aktywny zadań niż dostepnych maszyn
    for t in times
        @constraint(model, sum(x[j,s] for j in jobs for s in max(0, t-p[j]+1):t) <= m)
    end

    print(model)

	optimize!(model)		
    status = termination_status(model)

    if status == MOI.OPTIMAL
        return status, objective_value(model), value.(x)
    else
        return status, nothing, nothing
    end    
end

#-----------------------------#
#       SEKCJA DANYCH
#-----------------------------#
#Definicje zmiennych
n = 9
m = 3                         
p = [1, 2, 1, 2, 1, 1, 3, 6, 2]  
#Pierwszeństwo w formie słownika  
precedence = Dict(1 => [4], 2 => [4,5], 3 => [4,5], 4 => [6,7], 5 => [7,8], 6 => [9], 7 => [9],)
#-----------------------------#
#       SEKCJA DANYCH
#-----------------------------#

#Wywołanie funkcji
(status, cel, x) = MultiMachineScheduling(n, m, p, precedence)

jobs = 1:n
flag = false
max_T = sum(p) + 1
times = 0:max_T
machines = [zeros(Int,Int(cel)) for i in 1:m]
#Mocno eksperymentalne wypisanie wyniku, oby zadziałało
if status==MOI.OPTIMAL
    println("Funkcja celu: ",cel)
    println("Harmonogram: ")
    println(x)
    for j in jobs
        for t in times
            if x[j,t] != 0 
                for machine in machines
                    for z in (t+1):(t+p[j])
                        if machine[z] != 0
                            global flag = true
                            break
                        end
                    end
                    if flag
                        global flag = false
                    else
                        for z in (t+1):(t+p[j])
                            machine[z] = j
                        end
                        break
                    end
                end
            end
        end
    end
    for j in eachindex(machines)
        println("Maszyna $j : ",machines[j])
    end
else
    println("Status: ",status)
end