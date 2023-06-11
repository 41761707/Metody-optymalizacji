#Radosław Wojtczak, numer indeksu: 254607
#Metody optymalizacji, Lista 3, laboratorium
using JuMP
using GLPK
using IterTools

# Funkcja odpowiedzialna za odpowiednie parsowanie pliku
# @param instance_name - ścieżka względna do pliku zawierającego instancję rozpatrywanego problemu
# @param solution_name - ściezka względna do pliku zawierającego rozwiązanie optymalne
# @return jobs - liczba prac dla wskazanej instancji
# @return machines - liczba maszyn dla wskazanej instancji
# @return ps - dwuwymiarowa tablica zawierające informację o czasie realizacji
#              i-tego zadania na j-tej maszynie
# @return cmax - wartość funkcji celu
function read_from_file(instance_name, solution_name)
    file = readlines(instance_name)
    jobs, machines, _ = split(file[1])
    jobs = 1:parse(Int, jobs)
    machines = 1:parse(Int, machines)
    #println(length(jobs))
    #println(length(machines))
    ps = zeros(Int, length(machines), length(jobs))
    file_iter = 3
    for j in jobs
        column_iter = 0
        row = split(file[file_iter])
        for i in machines
            column_iter = column_iter + 2
            ps[i,j] = parse(Int,row[column_iter])
        end
        file_iter = file_iter + 1
    end
    solution = readlines(solution_name)
    cmax = 0
    for line in solution
        if occursin("MIP - Integer optimal solution:", line)
            cmax = parse(Float64, split(line, " ")[end])
            break
        end
    end
    return jobs, machines, ps, cmax
end

# Funkcja zwracająca najmniejsze T takie, że LP(T) jest rozwiązywalne
# @param lower_bound - dolne ograniczenie, od którego zaczynamy poszukiwanie
# @param upper_bound - górne ograniczenie, od którego zaczynamy poszukiwanie
# @param jobs - liczba prac dla wskazanej instancji
# @param machines - liczba maszyn dla wskazanej instancji
# @param ps - dwuwymiarowa tablica zawierające informację o czasie realizacji
#              i-tego zadania na j-tej maszynie
# @return desired_T - najmniejsza wartość czasu realizacji, dla której 
# z                   zadanie jest rozwiązywalne
# @ return desired_x - wartości zmiennych decyzyjnych dla rozwiązywalnego rozwiązania 
function feasible_solution(lower_bound, upper_bound, jobs, machines, ps)
    desired_T = 0
    desired_x = []
    #Wyszukiwaniem binarnym szukamy najmniejszego T, dla którego model jest rozwiązywalny
    while lower_bound < upper_bound
        T = floor(Int, (lower_bound + upper_bound) / 2)
        #Definicja modelu
        model = Model(GLPK.Optimizer)
        set_silent(model)
        #Zbiór S_T z książki
        S_T = Vector([(i, j) for i in machines for j in jobs if ps[i, j] <= T])
        #Sprawdzenie, czy prace zostały rozdysponowane między maszynami
        if(all(j -> any(p -> p[2] == j, S_T), jobs) == false )
            #println("NIE WSZYSTKIE PRACE W S_T")
            #println(T)
            lower_bound = lower_bound + 1
            continue
        else
            #println("WSZYSTKIE PRACE W S_T")
        end
        #utworzenie słowników, której wskazują, które maszyny zostały przyporządkowane do których
        #prac i vice versa
        jobs_to_machines = Dict{Int, Set{Int}}()
        machines_to_jobs = Dict{Int, Set{Int}}()
        for (i, j) in S_T
            if !haskey(jobs_to_machines, i)
                jobs_to_machines[i] = Set{Int}()
            end
            if !haskey(machines_to_jobs, j)
                machines_to_jobs[j] = Set{Int}()
            end
            push!(jobs_to_machines[i], j)
            push!(machines_to_jobs[j], i)
        end
        #Definicja zmiennych decyzyjnych
        @variable(model, x[i in keys(jobs_to_machines), j in keys(machines_to_jobs)] >= 0)
        #Definicja pierwszego ograniczenia z modelu programowania liniowego
        for j in keys(machines_to_jobs)
            @constraint(model, sum(x[i,j] for i in machines_to_jobs[j]) == 1)
        end
        #Definicja drugiego ograniczenia z modelu programowania liniowego
        for i in keys(jobs_to_machines)
            @constraint(model, sum(x[i,j] * ps[i,j] for j in jobs_to_machines[i]) <= T)
        end
        #Uruchomienie optymalizatora
		optimize!(model)
        status = termination_status(model)
        #Jeśli model jest rozwiązywalny, to zmniejszamy ograniczenie górne i sprawdzamy,
        #czy istnieje mniejsze T, dla którego model również jest rozwiązywalny
        if status == MOI.OPTIMAL || status == MOI.FEASIBLE_POINT
            upper_bound = T
            desired_T = T
            desired_x = value.(x)
        else
        #W przeciwnym wypadku zwiększamy ograniczenie dolne i ponawiamy sprawdzenie
            lower_bound = T+1
        end
    end
    return desired_T, desired_x
end

# Funkcja odpowiedzialna za zdeterminowanie, które prace zostały 
# przyporządkowane do więcej niż jednej maszyny 
# @param x - wartości zmiennych decyzyjnych
# @param jobs - lista prac
# @param machines - lista maszyn
# @return whole - całkowite przyporządkowania
# @return partial - częściowe przyporządkowania
function partial_jobs(x,jobs,machines)
    whole = Dict{Int, Set{Int}}()
    partial = Dict{Int, Set{Int}}()
    for i in machines
        partial[i] = Set{Int}()
        whole[i] = Set{Int}()
        for j in jobs
            try
                index = getindex(x,i,j)
                value = isapprox(index,1)
                #Sprawdzamy, czy rozwiązanie jest blisko 1
                if index > 0 && value == false
                    push!(partial[i], j)
                elseif value == true
                    push!(whole[i],j)
                end
            catch e
                continue
            end
        end
    end
    return whole, partial

end

# Funkcja zwracająca wymuszone pary, czyli takie, gdzie maszyny jest liściem grafu
# @param v - zbiór wierzchołków
# @param e - zbiór krawędzi
# @param len - liczba prac
# @return pairs - zbiór wymuszonych par (maszyna,praca)
function forced_pairs(v,e,len)
    pairs = Vector{Tuple{Int, Int}}()
    for vertex in v
        if length(e[vertex]) == 1
            machine = 0
            job = 0
            if vertex > len
                machine = vertex
                job = e[vertex][1]
            else
                job = vertex
                machine = e[vertex][1]
            end
            #println("(" * "$job" * "," * "$machine" *  ")")
            push!(pairs,(machine,job))
            delete!(v,machine)
            delete!(v,job)
            for (key, values) in e
                if(machine in values)
                    filter!(x -> x != machine, values)
                end
                if(job in values)
                    filter!(x -> x != job, values)
                end
                if isempty(values)
                    delete!(v,key)
                    delete!(e,key)
                end
            end
        end
    end
    return pairs   
end

# Przeszukiwanie wgłąb grafu w celu eliminacji cyklu
# @param node - wierzchołek startowy
# @param e - zbiór krawędzi
# @param pairs - zbiór par utworzonych w przebiegu funkcji
# @param paired - zbiór wczesniej utworzonych już par, który finalnie jest rozszerzony o kolekcję pairs
# @param visited - lista odwiedzonych wierzchołków
# @return pairs - jak powyzej
# @return paired - jak powyżej
# @return visited - jak powyżej
function dfs(node,e,pairs,paired,visited)
    push!(visited, node)
    for neighbor in e[node]
        if !(neighbor in visited)
            if !(node in paired) && !(neighbor in paired)
                if node > len
                    push!(pairs, (node, neighbor))
                else
                    push!(pairs, (neighbor, node))
                end
                    push!(paired, node)
                push!(paired, neighbor)
            end
            dfs(neighbor)
        end
    end
    return pairs, paired, visited
end

# Funkcja rozwiązująca sytuację, w której w grafie nie ma lisci
# @param v - lista wierzchołków 
# @param e - lista krawędzi 
# @param len - liczba prac
# @return new_pairs - nowo utowrzone pary (maszyna, praca)
function resolve_conflict(v,e,len)
    pairs = Vector{Tuple{Int, Int}}()
    paired = Vector()
    visited = Vector()

    for vertex in v
        pairs,paired,visited = dfs(vertex,e,pairs,paired,visited)
    end
    new_pairs = Vector{Tuple{Int, Int}}()
    for pair in pairs
        if pair[1] < len
            append!(new_pairs,(reverse(pair),))
        else
            append!(new_pairs,(pair,))
        end
    end
    return new_pairs
end

# Funkcja rozwiązująca problem maksymalnego sparowania w celu usunięcia częściowych realizacji prac
# @param partial - lista częściowo realizowanych prac
# @param jobs - lista prac
# @param machines - lista maszyn
# @return pairs - rozwiązanie problemu w postaci par (maszyna, praca)
function perfect_matching(partial,jobs,machines)
    #Żeby uniknąc niespójności (połączenie maszyny 4 z pracą 4 dałoby krawędź 
    #między wierzchołkami 4 i 4 co jest pętlą) indeksy maszyn są zwielokrotnione 
    #o liczbę prac w danej instancji
    v = Set{Int}()
    for (key,values) in partial
        push!(v, key+length(jobs))
        for vertex in values
            push!(v,vertex)
        end
    end
    e = Dict{Int, Vector{Int}}([vertex => [] for vertex in v])
    for (key,values) in partial
        for vertex in values
            append!(e[key+length(jobs)],vertex)
            append!(e[vertex],key+length(jobs))
        end
    end
    #println(v)
    #println(e)
    pairs = Vector{Tuple{Int, Int}}()
    while true
        tmp = forced_pairs(v,e,length(jobs))
        #println(tmp)
        if isempty(tmp)
            break
        end
        for element in tmp
            append!(pairs,(element,))
        end
    end
    if length(v) > 0
        #print("ROZWIAZUJEMY KONFLIKTY")
        tmp_resolve = resolve_conflict(v,e,length(jobs))
        for element in tmp_resolve
            append!(pairs,(element,))
        end
    end
    #println(pairs)
    #println(e)
    return pairs
end


#Wywołanie
#julia zad.jl <nazwa_instancji> <nazwa_rozwiazania>
function main()
    instance_name = ARGS[1] #pobranie pliku z instancją instancji
    solution_name = ARGS[2] #pobranie pliku z rozwiązaniem optymalnym 
    #parsowanie pliku do odpowiedniego formatu
    jobs, machines, ps, cmax = read_from_file(instance_name,solution_name)
    #Jeśli w plikach nie znalazłem rozwiązania optymalnego to nie wykonuję niepotrzebnie roboty,
    #której później i tak nie jestem w stanie zweryfikować
    if(cmax == 0)
        return
    end
    #ustalanie granic, dla których rozpatrujemy T (krok 1 algorytmu 17.5)
    upper_bound = sum(minimum(ps[i,j] for i in machines) for j in jobs)
    lower_bound = div(upper_bound, length(machines))
    #wyznaczenie odpowiedniego t (krok 1 algorytmu 17.5)
    T_star, x = feasible_solution(lower_bound, upper_bound, jobs, machines, ps)
    #println("T_STAR: ",T_star)
    #Rozdzielamy prace między te, które zostały w całości przeznaczone do 
    #realizacji, a te, które zostały przeznaczone do
    #realizacji "częściowo"
    whole,partial = partial_jobs(x,jobs,machines)
    results = deepcopy(whole)
    #println(partial)
    #println(results)
    #Teraz rozwiązujemy problem częściowych prac tworząc graf 
    #i szukając w nim doskonałego skojarzenia
    pairs = perfect_matching(partial,jobs,machines)
    for (machine,job) in pairs
        push!(results[machine-length(jobs)],job)
    end
    #Wypisanie rozwiązania
    makespan = maximum([sum([ps[i,j] for j in results[i]]) for i in machines])
    cmax_2 = 2*cmax
    println(split(instance_name,"/")[2] * ";" * "$cmax" * ";" * "$makespan" * ";" * "$cmax_2")

end

main()