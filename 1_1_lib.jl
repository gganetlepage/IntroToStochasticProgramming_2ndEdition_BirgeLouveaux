#the same notation as in the book is used in order to compare promptly
using JuMP, StochasticPrograms, GLPK


"Add a new model, create the variables with their domain, the objective and the constraints"
function build_and_solve_model(land, cattle, sell, buy, yield, quota, plant, print_model = false, print_result = false)
    model = Model(with_optimizer(GLPK.Optimizer))
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
    model = Model(with_optimizer(GLPK.Optimizer))
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

"Return the minimal value(s), mean value(s) and the max value(s) due to the uncertainty"
rangeValues(mean, variation::Number) = mean*(1 - variation), mean, mean*(1 + variation)



"Build the stochastic farm model"
function build_farm_model(land, cattle, sell_mean, sell_var, buy_mean, buy_var, yield_mean, yield_var, quota, plant, print_models = false, print_results = false)
    sell_min, sell_mean, sell_max = rangeValues(sell_mean, sell_var)
    buy_min, buy_mean, buy_max = rangeValues(buy_mean, buy_var)
    yield_min, yield_mean, yield_max = rangeValues(yield_mean, yield_var)
    farmer_model = @stochastic_model begin
        @stage 1 begin
            
        end
        @stage 2 begin
            
        end
    end
end

#quickstart of StochasticPrograms
quickstart_model = @stochastic_model begin
    @stage 1 begin
        @decision(model, x₁ >= 40)
        @decision(model, x₂ >= 20)
        @objective(model, Min, 100*x₁ + 150*x₂)
        @constraint(model, x₁ + x₂ <= 120)
    end
    @stage 2 begin
        @uncertain q₁ q₂ d₁ d₂
        @variables(model, begin
            0 <= y₁ <= d₁
            0 <= y₂ <= d₂
        end)
        @objective(model, Max, q₁ * y₁ + q₂ * y₂)
        @constraints(model, begin
            6*y₁ + 10*y₂ <= 60*x₁
            8*y₁ + 5*y₂ <= 80*x₂
         end)
    end
    
end


#farm problem
farm_stochastic_model = @stochastic_model begin
    @stage 1 begin
        @parameters begin
            crop = [:wheat, :corn, :beets]
            plant = Dict(:wheat => 150, :corn => 230, :beets => 260)
            land = 500
        end
        @decision(model, x[c in crop] >= 0)
        @objective(model, Min, sum(plant[c]*x[c] for c in crop))
        @constraint(model, sizeLand, sum(x[c] for c in crop) <= land)
    end
    @stage 2 begin
        @parameters begin
            crop = [:wheat, :corn, :beets]
            sell = Dict(:wheat => 170, :corn => 150, :beets => 36, :extra_beets => 10)
            buy = Dict(:wheat => 238, :corn => 210)
            requirement = Dict(:wheat => 200, :corn => 240, :beets => 0)
        end
        @uncertain ξ[c in crop]
        @variables(model, begin
            y[b in setdiff(crop, [:beets])] >= 0
            w[s in crop ∪ [:extra_beets]] >= 0
        end)
        @objective(model, Min, sum(buy[b]*y[b] for b in setdiff(crop, [:beets])) - sum(sell[s]*w[s] for s in crop ∪ [:extra_beets]))
        @constraint(model, minimum_requirement[b in setdiff(crop, [:beets])], ξ[b]*x[b] + y[b] - w[b] >= requirement[b])
        @constraint(model, minimum_requirement_beets, ξ[:beets]*x[:beets] - w[:beets] - w[:extra_beets]>= requirement[:beets])
        @constraint(model, good_price_cap, w[:beets] <= 6000)
    end
end

# Binary first stage
#=
function binary_first_stage(fields, plants, land)
    binary_model = @stochastic_model begin
        @stage 1 begin
            @parameters begin
                crop = [:wheat, :corn, :beets]
                plant = Dict(:wheat=>plants[1], :corn=>plants[2], :beets=>plants[3])
                #land
            end
            @decision(model, x[i in fields][j in crop], Bin)
            @objective(model, Min, sum( for j in crop)) #TODO complete the objective
        end
        #TODO add stage 2
    end
=#