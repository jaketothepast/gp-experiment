import ExcelReaders
import DataFrames

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

function breeder(parent)
end

function fitness(candidate)
end

function search(candidates)
    # Truncation selection, top 3 as parents.
    # First, check everyone's fitness.  
    # Then, generate new solutions by selecting parents and breeding
    sort!(candidates, by = x -> fitness(x))
    parents = candidates[1:3]
end

function randRow()
    # Generate a random row index
    abs(rand(Int) % size(df, 1))
end

function randomCandidate(n)
    # Select n random rows from the dataset.
    rows = [randRow() for i = 1:n]
    df[rows, :]
end