#Radosław Wojtczak 254607
#Lista 2 zadanie 1

using LinearAlgebra
using Combinatorics
using JuMP
using Cbc


global divs = []

#Funkcja odpowiedzialna za generowanie mozliwych kombinacji cięć
function generate_combinations(nums ,target, n, cur)
    if n == 0
        push!(divs,cur)
    else
        for i in eachindex(nums)
            if nums[i] <= target
                new_cur = [cur; nums[i]]
                generate_combinations(nums[i:end], target-nums[i], n-1, new_cur)
            end
        end
    end
end
#Funkcja obsługująca problem tartaku
# @param size - rozmiar wyjściowej deski
# @param cuts - wektor zdefiniowanych możliwych podziałów deski
# @param demand - zapotrzebowanie na deski danego typu
function sawmill(size::Int,cuts::Vector{Int},demand::Vector{Int})
    for n in 1:floor(size/minimum(cuts))
        generate_combinations(cuts, size , n, [])
    end

    n = length(divs)
    k = length(cuts)
    configurations = Matrix{Int32}(undef, n, k+1)

    for i in eachindex(divs)
        dict_counts = Dict{Int, Int}()
        for j in eachindex(divs[i])
            if divs[i][j] in keys(dict_counts)
                dict_counts[divs[i][j]] += 1
            else
                dict_counts[divs[i][j]] = 1
            end
        end
        
        for j in eachindex(cuts)
            configurations[i,j] = get(dict_counts, cuts[j], 0)
        end
        
        configurations[i, k+1] = size - sum([configurations[i, j]*cuts[j] for j in eachindex(cuts)])
    end
    # definicja modelu
    println(configurations)
    model = Model(Cbc.Optimizer)

    # zmienna decyzyjna
    @variable(model, x[1:n] >= 0, Int)

    #Minimalizacja sumy odpadu i nadmiarowych desek
    @objective(model,Min,sum(configurations[a,k+1]*x[a] for a in 1:n) + sum([(sum(configurations[a,j]*x[a] for a in 1:n) - demand[j])*cuts[j] for j in eachindex(cuts)]))

    # Zaspokojenie wszystkich potrzeb klientów
    for j in eachindex(cuts)
        @constraint(model, sum(configurations[a,j]*x[a] for a in 1:n)>= demand[j])
    end

    print(model)
	optimize!(model)		
    status = termination_status(model)

    if status == MOI.OPTIMAL
        return status, objective_value(model), value.(x), divs
    else
        return status, nothing, nothing, nothing
    end
end

#-----------------------------#
#       SEKCJA DANYCH
#-----------------------------#
size = 22
cuts = [7, 5, 3]
demand = [110, 120, 80]
#-----------------------------#
#       SEKCJA DANYCH
#-----------------------------#

(status, cel, results, divs) = sawmill(size, cuts, demand)

if status==MOI.OPTIMAL
    println("Odpady: ", cel)
    for i in eachindex(results)
        if results[i] > 0
            println(results[i], " podziałów typu: ", divs[i])
        end
    end
else
    println("Status: ",status)
end