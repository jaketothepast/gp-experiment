import ExcelReaders
import DataFrames

POPSIZE = 5
mu = 1
lambda = 4
GENLIMIT = 20
TARGETCALORIES = 1000

data = ExcelReaders.readxlsheet("./data/nutrional_information_5917.xlsx", "Sheet2", skipstartrows=1)
header = ExcelReaders.readxlsheet("./data/nutrional_information_5917.xlsx", "Sheet2", nrows=1)

# Convert to symbols to build header row.
for i = 1:length(header)
    tmp = header[i]
    tmp = Symbol(tmp)
    header[i] = tmp
end
header = dropdims(reshape(header, :, 1), dims=2)
df = DataFrames.DataFrame()

# Finally, construct our dataframe
for i = 1:length(header)
    df[header[i]] = data[2:end, i]
end

function mutate(parent)
    randomCandidate(4)
end

"""
    fitness(candidate::DataFrames.DataFrame)

Calculate the fitness of the candidate, which is the
absolute value of the difference of TARGETCALORIES and the sum
of all calories in the meal.
"""
function fitness(candidate::DataFrames.DataFrame)
    abs(TARGETCALORIES - sum(+, candidate[:Calories]))
end


function randRow()
    # Generate a random row index
    abs(rand(Int) % size(df, 1))
end

function randomCandidate(n::Integer)
    # Select n random rows from the dataset.
    rows = [randRow() for i = 1:n]
    df[rows, :]
end

function generateInitialPopulation(lambda::Integer, candidateSize::Integer)
    [randomCandidate(candidateSize) for i = 1:lambda]
end

function main()
    # Generate the initial population.
    pop = generateInitialPopulation(lambda, 4)
    best = nothing
    generationNum = 0
    fit = nothing
    parents = nothing

    while generationNum != GENLIMIT || (best != nothing && fitness(best) != 0)

        # Assess the fitness of parents
        for parent in pop
            fit = fitness(parent)
            if best === nothing || fit < fitness(best)
                best = parent
            end
        end

        bestFitness = fitness(best)

        sort!(pop, by = x -> fitness(x))
        parents = pop[1:mu]
        pop = parents

        for p in parents
            for i = 1:(lambda/mu)
                push!(pop, mutate(p))
            end
        end

        println("Generation $generationNum, best $best, fitness $bestFitness")
        generationNum += 1
    end

end
# search(generateInitialPopulation())