#the same notation as in the book is used in order to compare promptly.
using JuMP, Gurobi


#Parameters
land = 500
cattle = [200,240]
sell_mean = [170,150,36,10]
buy_mean = 1.4 * sell_mean[1:2]
quota = 6000
yield_mean = [2.5,3,20]
plant = [150,230,260]


"Add a new model, create the variables with their domain, the objective and the constraints"
function add_model(land, cattle, sell, buy, yield, quota, plant, print_model = false)
    model = Model(Gurobi.Optimizer)
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
    
    x,y,z = add_variables(model)
    add_objective(model, x, y, z, sell, buy, plant)
    add_constraints(model, x, y, z, yield, quota)
    model
end

"Solve the model, return: the objective value, x, w, y)"
function solve_model(model)
    optimize!(model)
    println(termination_status(model))
    objective_value(model), value.(model[:x]), value.(model[:w]), value.(model[:y])
end

sell_var = 0.0
buy_var = 0.0
yield_var = 0.0
model1 = add_model(land, cattle, sell_mean, buy_mean, yield_mean, quota, plant)


objective, x, w, y = solve_model(model1)

println("objective: ", objective)
println(x,w,y)

#(land, cattle, sell_mean, sell_var, buy_mean, buy_var, yield_mean, yield_var, quota, plant)

#function solve_multiple_models(land, cattle, sell_mean, sell_var, buy_mean, buy_var, yield_mean, yield_var, quota, plant)



println("end")