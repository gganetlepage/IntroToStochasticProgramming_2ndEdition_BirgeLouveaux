#the same notation as in the book is used in order to compare promptly
using JuMP, Gurobi

const GUROBI_ENV = Gurobi.Env() # This constant able not to see more than once "Academic license - for non-commercial use only"

"Add a new model, create the variables with their domain, the objective and the constraints"
function build_and_solve_model(land, cattle, sell, buy, yield, quota, plant, print_model = false, print_result = false)
    model = Model(with_optimizer(Gurobi.Optimizer,GUROBI_ENV)) # GUROBI_ENV to hide the gurobi message
    function add_variables(model)
        @variables(model, begin
        x[i=1:3] >= 0, (base_name = "x_$i") # acres devoted to a resource to produce
        w[j=1:4] >= 0, (base_name = "w_$j") # tons of resources sold
        y[k=1:2] >= 0, (base_name = "y_$k") # tons of resources purchased
        end)
        x,w,y
    end
    
    function add_objective(model, x, w, y, sell, buy, plant)
        #Preference for a max objective representing the profit, as opposed to the book's solution.
        @objective(model, Max, sum(sell[j] * w[j] for j in 1:4) 
                        - sum(buy[k] * y[k] for k in 1:2) - sum(plant[i] * x[i] for i in 1:3))
    end
    
    function add_constraints(model, x, w, y, yield, quota)
        @constraint(model,conLand, sum(x) <= land)
        @constraint(model, conQuota, w[3] <= quota)
        #Preference for equality constraint relating the purchase, the sell and the production, as opposed to the book's solution.
        @constraint(model, conCattle[i = 1:2], yield[i] * x[i] + y[i] - w[i] == cattle[i])
        @constraint(model, conMarket, yield[3] * x[3] - w[3] - w[4] == 0)
    end
    
    function solve_model(model, print_result)
        optimize!(model)
        if print_result
            println(termination_status(model))
            println("objective_value:", objective_value(model))
            println(value.(model[:x]), value.(model[:w]), value.(model[:y]))
        end
        objective_value(model), value.(model[:x]), value.(model[:w]), value.(model[:y])
    end

    # Build model
    x,y,z = add_variables(model)
    add_objective(model, x, y, z, sell, buy, plant)
    add_constraints(model, x, y, z, yield, quota)
    print_model && println(model)
    # Solve model
    solve_model(model, print_result)
end

"Solve the model, return: the objective value, x, w, y)"
function solve_multiple_models(land, cattle, sell_mean, sell_var, buy_mean, buy_var, yield_mean, yield_var, quota, plant, print_models = false, print_results = false)
    sell_min = sell_mean * (1 - sell_var)
    sell_max = sell_mean * (1 + sell_var)
    buy_min = buy_mean * (1 - buy_var)
    buy_max = buy_mean * (1 + buy_var)
    yield_min = yield_mean * (1 - yield_var)
    yield_max = yield_mean * (1 + yield_var)
    build_and_solve_model(land, cattle, sell_min, buy_min, yield_min, quota, plant, print_models, print_results)
    build_and_solve_model(land, cattle, sell_mean, buy_mean, yield_mean, quota, plant, print_models, print_results)
    build_and_solve_model(land, cattle, sell_max, buy_max, yield_max, quota, plant, print_models, print_results)
end

function model_with_first_stage_given(x, sell, buy, yield, plant, print_model = false, print_result = false)
    model = Model(with_optimizer(Gurobi.Optimizer,GUROBI_ENV)) # GUROBI_ENV to hide the gurobi message
    function add_variables(model)
        @variables(model, begin
        w[j=1:4] >= 0, (base_name = "w_$j") # tons of resources sold
        y[k=1:2] >= 0, (base_name = "y_$k") # tons of resources purchased
        end)
        w,y
    end
    
    function add_objective(model, x, w, y, sell, buy, plant)
        #Preference for a max objective representing the profit, as opposed to the book's solution.
        @objective(model, Max, sum(sell[j] * w[j] for j in 1:4) 
                        - sum(buy[k] * y[k] for k in 1:2) - sum(plant .* x))
    end
    
    function add_constraints(model, x, w, y, yield, quota)
        #@constraint(model,conLand, sum(x) <= land)
        @constraint(model, conQuota, w[3] <= quota)
        #Preference for equality constraint relating the purchase, the sell and the production, as opposed to the book's solution.
        @constraint(model, conCattle[i = 1:2], y[i] - w[i] == cattle[i] - yield[i] * x[i])
        @constraint(model, conMarket,  w[3] + w[4] == yield[3] * x[3])
    end
    
    function solve_model(model, print_result = false)
        optimize!(model)
        if print_result
            println(termination_status(model))
            println("objective_value:", objective_value(model))
            println(value.(model[:w]), value.(model[:y]))
        end
        objective_value(model), value.(model[:w]), value.(model[:y])
    end

    # Build model
    w, y = add_variables(model)
    add_objective(model, x, w, y , sell, buy, plant)
    add_constraints(model, x, w, y , yield, quota)
    print_model && println(model)
    # Solve model
    solve_model(model, print_result)
end

println("END ______________________________________________________________________________________")

#obj_value, w, y = model_with_first_stage_given([120, 80, 300], sell_mean, buy_mean, yield_mean, plant, true)
#println("obj_value: ", obj_value,"\n w: ", w, "\n y: ", y)

function solve_multiple_models_with_first_stage_given(land, cattle, sell_mean, sell_var, buy_mean, buy_var, yield_mean, yield_var, quota, plant, print_models = false, print_results = false)
    sell_min = sell_mean * (1 - sell_var)
    sell_max = sell_mean * (1 + sell_var)
    buy_min = buy_mean * (1 - buy_var)
    buy_max = buy_mean * (1 + buy_var)
    yield_min = yield_mean * (1 - yield_var)
    yield_max = yield_mean * (1 + yield_var)
    model_with_first_stage_given(land, cattle, sell_min, buy_min, yield_min, quota, plant, print_models, print_results)
    model_with_first_stage_given(land, cattle, sell_mean, buy_mean, yield_mean, quota, plant, print_models, print_results)
    model_with_first_stage_given(land, cattle, sell_max, buy_max, yield_max, quota, plant, print_models, print_results)
end

#page 13

function recourse3(x)
    if x <= 250
        return - 36*20*x
    elseif x >= 375
        return -156000 - 10*20*x
    else
        return -36*20*x + 13*(24*x - 6000)^2 / (8*x)
    end
end

function recourse2(x)
    if x <= 200/3
        return 50400 - 630*x
    elseif x >= 100
        return 36000 - 450*x
    else
        87.5*(240 - 2.4*x)^2 / x - 62.5*(240 - 3.6 * x)^2 / x
    end
end

function recourse1(x)
    if x <= 200/3
        return 47600 - 595*x
    elseif x >= 100
        return 34000 - 425*x
    else
        119*(200 - 2*x)^2 / x - 85*(200 - 3 * x)^2 / x
    end
end

