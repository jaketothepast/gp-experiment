import ExcelReaders
import DataFrames

POPSIZE = 5
mu = 1
lambda = 4
GENLIMIT = 20
TARGETCALORIES = 2000

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

"""
Our mutator function

    steps through the parent, and randomly selects the
    allelles to delete. Will replace the alleles with new
    alleles (meals).
"""
function mutate(parent)

    # Copy the parent so we can do some work.
    child = deepcopy(parent)
    toDelete = []

    for i in 1:size(parent, 1)
        if rand(Float64) > 0.5 # NOTE: make this tunable
            push!(toDelete, i)
        end
        # If we get tails, delete the row and push a new one to it.
    end

    # Delete all rows we don't want at once.
    DataFrames.deleterows!(child, toDelete)

    # Add new random rows from the ones we deleted
    for i in 1:length(toDelete)
        push!(child, df[randRow(), :])
    end

    child
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

"""
Helper function to generate a random row index
    used by randomCandidate
"""
function randRow()
    # Generate a random row index
    abs(rand(Int) % size(df, 1)) + 1
end

"""
Helper function to generate a random candidate from the dataset.

    n is the size of the candidate.
"""
function randomCandidate(n::Integer)
    # Select n random rows from the dataset.
    rows = [randRow() for i = 1:n]
    df[rows, :]
end


"""
generateInitialPopulation(lambda::Integer, candidateSize::Integer)

From our dataset, generate an array of initial candidates to begin the search.
"""
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

    while generationNum <= GENLIMIT
        # Assess the fitness of parents
        for parent in pop
            fit = fitness(parent)
            if best === nothing || fit < fitness(best)
                best = parent
            end
        end

        # Grab our best fitness for logging purposes.
        bestFitness = fitness(best)

        # Copy the best mu parents into the population.
        sort!(pop, by = x -> fitness(x))
        parents = pop[1:mu]
        pop = deepcopy(parents)

        # Employ our (mu + lambda) strategy by generating lambda/mu kids.
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