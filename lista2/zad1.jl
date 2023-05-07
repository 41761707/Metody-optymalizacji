#Radosław Wojtczak 254607
#Lista 2 zadanie 1

using LinearAlgebra
using Combinatorics
using JuMP
using Cbc


function divide_boards(board_size::Int,smaller_boards::Vector{Int},demand::Vector{Int})
    splits = [] 
    comb_max_len = div(board_size, minimum(smaller_boards))
    for i in 1:comb_max_len
        append!(splits, [j for j in with_replacement_combinations(smaller_boards, i)])
    end
    splits = [x for x in splits if sum(x) <= 22]

    n = length(splits)
    k = length(smaller_boards)
    A = Matrix{Int32}(undef, n, k+1)
    for i in eachindex(splits)
        for j in eachindex(smaller_boards)
            A[i,j] = count(==(smaller_boards[j]), splits[i])
        end
        A[i, k+1] = board_size - sum([A[i, j]*smaller_boards[j] for j in eachindex(smaller_boards)])
    end

    model = Model(Cbc.Optimizer)

    @variable(model, x[1:n] >= 0, Int)

    @objective(
        model, 
        Min, 
        dot(A[:, k+1], x) + sum([(dot(A[:, j], x) - demand[j])*smaller_boards[j] for j in eachindex(smaller_boards)]))

    for j in eachindex(smaller_boards)
        @constraint(model, dot(A[:, j], x) >= demand[j])
    end

    print(model)
	if verbose
		optimize!(model)		
	else
		set_silent(model)
		optimize!(model)
		unset_silent(model)
	end
    status = termination_status(model)

    if status == MOI.OPTIMAL
        return status, objective_value(model), value.(x), splits
    else
        return status, nothing, nothing, nothing
    end
end


board_size = 22
smaller_boards = [7, 5, 3]
demand = [110, 120, 80]

(status, obj_val, results, splits) = divide_boards(board_size, smaller_boards, demand)

println("Status: ", status)
println("Odpady: ", obj_val)
for i in eachindex(results)
    if results[i] > 0
        println(results[i], " x ", splits[i])
    end
end