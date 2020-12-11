using JuMP, GLPK


function build_model()
    model = Model(with_optimizer(GLPK.Optimizer))
    @variable(model, x[i=1:9, j=1:9, k=1:9],Bin, (base_name = "x_$i$j$k"))
    @objective(model, Max, sum(x[i,j,k] for k in 1:9, j in 1:9, i in 1:9))
    
    @constraint(model, value_cell[i = 1:9, j = 1:9], sum(x[i, j, k] for k in 1:9)==1) # each cell has only one value
    @constraint(model, value_line[i = 1:9, k = 1:9], sum(x[i, j, k] for j in 1:9)==1) # each value appears once in each line 
    @constraint(model, value_column[j = 1:9, k= 1:9], sum(x[i, j, k] for i in 1:9)==1) # each value appears once in each column
    @constraint(model, value_square[b1 = 1:3, b2 = 1:3, k = 1:9], sum(sum(x[-2 + 3*b1 + l1, -2 + 3*b2 + l2, k] for l2 in 0:2) for l1 in 0:2)==1) # each of the 9 squares contains each value once
    model
end




function solve_model(model)
    optimize!(model)
    objective_value(model), value.(model[:x])
end

function binary_to_sudoku(x)
    sudoku = Array{Integer,2}(undef,9,9)
    count = 0
    for i in 1:9
        for j in 1:9
            for k in 1:9
                if x[i,j,k] > 0.1
                    sudoku[i,j]=k
                    break
                end
            end
        end
    end
    sudoku, count
end

function print_sudoku(sudoku)
    for line in 1:9
        println(sudoku[line, :])
    end
end


