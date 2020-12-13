include("1_1_lib.jl")

#Parameters
land = 500
cattle = [200, 240]
sell_mean = [170, 150, 36, 10]
buy_mean = 1.4 * sell_mean[1:2]
quota = 6000
yield_mean = [2.5,3,20]
plant = [150,230,260]

sell_var = 0.0
buy_var = 0.0
yield_var = 0.2

solve_multiple_models(land, cattle, sell_mean, sell_var, buy_mean, buy_var, yield_mean, yield_var, quota, plant)
#=
objective_value:59950.0
[100.0, 25.0, 375.0][0.0, 0.0, 6000.0, 0.0][0.0, 180.0]

objective_value:118600.0
[120.0, 80.0, 300.0][100.0, 0.0, 6000.0, 0.0][0.0, 0.0]

objective_value:167666.6666666667
[183.33333333333331, 66.66666666666667, 250.0][350.0, 0.0, 6000.0, 0.0][0.0, 0.0]
=#

println("EVPI:")
println(sum([59950, 118600, 167666]) / 3) # 115405.33333333333

println("Exercices:")

println("1. VALUE OF THE STOCHASTIC SOLUTION")
#the average situation solution is:
obj_value, x, w, y = build_and_solve_model(land, cattle, sell_mean, buy_mean, yield_mean, quota, plant)
println("\nAverage situation\n","obj_value: ", obj_value,"\n x:", x, "\n w: ", w, "\n y: ", y)
#obj_value: 118600.0
# x:[120.0, 80.0, 300.0]
# w: [100.0, 0.0, 6000.0, 0.0]
# y: [0.0, 0.0]

#Let's apply these values of x to the 2 other possible scenarios:
obj_value, w, y = model_with_first_stage_given([120, 80, 300], cattle, sell_mean, buy_mean, yield_mean *(1 - yield_var), quota, plant) # 148_000.0
println("\nBelow average situation\n","obj_value: ", obj_value,"\n w: ", w, "\n y: ", y)
#=
below average situation
obj_value: 55120.00000000001
 w: [40.0, 0.0, 4800.0, 0.0]
 y: [0.0, 47.99999999999997]
=#
obj_value, w, y = model_with_first_stage_given([120, 80, 300], cattle, sell_mean, buy_mean, yield_mean *(1 + yield_var), quota, plant) # 55_120.0
println("\nOver average situation\n", "obj_value: ", obj_value,"\n w: ", w, "\n y: ", y)
#=
Over average situation
obj_value: 148000.0
 w: [160.0, 48.0, 6000.0, 1200.0]
 y: [0.0, 0.0]
=#
println("multiple simultaneously")
solve_multiple_models_with_first_stage_given([120,80,300],cattle, sell_mean, sell_var, buy_mean, buy_var, yield_mean, yield_var, quota, plant, false, false)
#=
OPTIMAL
objective_value:55120.00000000001
[40.0, 0.0, 4800.0, 0.0][0.0, 47.99999999999997]
OPTIMAL
objective_value:118600.0
[100.0, 0.0, 6000.0, 0.0][0.0, 0.0]
OPTIMAL
objective_value:148000.0
[160.0, 48.0, 6000.0, 1200.0][0.0, 0.0]
=#

values = [118600, 55120, 148000]
println("\nUsing the average situation solution for every situations, results in average to a gain of : ",sum(values)/3) # 107240
# Overall, in average, applying the average situation solution results in 107240

println("\n\n2. PRICE EFFECT\n")
# The selling and buying prices evolves inversely with the yield.
# Average yield => average selling and buying prices:
obj_value, x, w, y = build_and_solve_model(land, cattle, sell_mean, buy_mean, yield_mean, quota, plant)
println("\nAverage situation\n","obj_value: ", obj_value,"\n x:", x, "\n w: ", w, "\n y: ", y)
#= obj_value: 118600.0
 x:[120.0, 80.0, 300.0]
 w: [100.0, 0.0, 6000.0, 0.0]
 y: [0.0, 0.0]
 =#

# Good yield => lower selling and buying prices:
obj_value, x, w, y = build_and_solve_model(land, cattle, 0.9 * sell_mean, 0.9 * buy_mean, 1.2 * yield_mean, quota, plant)
println("\nGood yield situation\n","obj_value: ", obj_value,"\n x:", x, "\n w: ", w, "\n y: ", y)
#=
obj_value: 140116.6666666667
 x:[183.33333333333331, 66.66666666666667, 250.0]
 w: [350.0, 0.0, 6000.0, 0.0]
 y: [0.0, 0.0]
=#

# Bad yield => higher selling and buying prices:
obj_value, x, w, y = build_and_solve_model(land, cattle, 1.1 * sell_mean, 1.1 * buy_mean, 0.8 * yield_mean, quota, plant)
println("\nBad yield situation\n","obj_value: ", obj_value,"\n x:", x, "\n w: ", w, "\n y: ", y)
#=
obj_value: 77770.0
x:[100.0, 25.0, 375.0]
w: [0.0, 0.0, 6000.0, 0.0]
y: [0.0, 180.0]
=#

#println("sell: ",rangeValues(sell_mean,sell_var))
#println("buy: ",rangeValues(buy_mean,buy_var))
#println("yield: ",rangeValues(yield_mean,yield_var))

#Quickstart example
ξ₁ = Scenario(q₁ = 24.0, q₂ = 28.0, d₁ = 500.0, d₂ = 100.0, probability = 0.4)
ξ₂ = Scenario(q₁ = 28.0, q₂ = 32.0, d₁ = 300.0, d₂ = 300.0, probability = 0.6)
sp = instantiate(quickstart_model, [ξ₁,ξ₂], optimizer = GLPK.Optimizer)
#optimize!(sp)
#println(objective_value(sp))
#println(optimal_decision(sp))

#farm problem
println("stochastic farm problem")
yield_min, yield_mean, yield_max = rangeValues(yield_mean, yield_var)
#println("min: ", yield_min,"mean: ", yield_mean,"max: ", yield_max)
ξ₁ = Scenario( wheat = yield_min[1], corn = yield_min[2], beets = yield_min[3], probability = 1/3)
ξ₂ = Scenario( wheat = yield_mean[1], corn = yield_mean[2], beets = yield_mean[3], probability = 1/3)
ξ₃ = Scenario( wheat = yield_max[1], corn = yield_max[2], beets = yield_max[3], probability = 1/3)
farmInstance = instantiate(farm_stochastic_model, [ξ₁,ξ₂,ξ₃], optimizer = GLPK.Optimizer)

#print(farmInstance)
optimize!(farmInstance)
decisionsStochastic = optimal_decision(farmInstance)
println("wheat: $(decisionsStochastic[1])\n corn: $(decisionsStochastic[2])\n beets: $(decisionsStochastic[3])\n Profit: $(objective_value(farmInstance))")
#=
wheat: 170.00000000000006
 corn: 80.00000000000001
 beets: 250.0
 Profit: -108390.00000000001
 =#
 
println("\n\n7. RISK AVERSION\n")

#obj_value, w, y = model_with_first_stage_given([100, 25, 375], sell_mean, buy_mean, yield_mean *(1 + yield_var), plant) # 55_120.0
#println("\nBelow average situation\n", "obj_value: ", obj_value,"\n w: ", w, "\n y: ", y)
optimal_1st_stage_decisions_worst_scenario = [100, 25, 375]

solve_multiple_models_with_first_stage_given(optimal_1st_stage_decisions_worst_scenario, cattle, sell_mean, sell_var, buy_mean, buy_var, yield_mean, yield_var, quota, plant, false, true)

#=
OPTIMAL
objective_value:59950.0
[0.0, 0.0, 6000.0, 0.0][0.0, 180.0]
OPTIMAL
objective_value:86600.0
[50.0, 0.0, 6000.0, 1500.0][0.0, 165.0]
OPTIMAL
objective_value:113250.0
[100.0, 0.0, 6000.0, 3000.0][0.0, 150.0]
=#
risk_averse_expected_profit = (59950.0 + 86600 + 113250)/3 #86600


println("\nstandard expected profit")
standard_expected_profit_1st_stage_decisions = [170,80,250]
solve_multiple_models_with_first_stage_given(standard_expected_profit_1st_stage_decisions, cattle, sell_mean, sell_var, buy_mean, buy_var, yield_mean, yield_var, quota, plant, false, true)

#=
objective_value:48820.00000000001
[140.0, 0.0, 4000.0, 0.0][0.0, 47.99999999999997]
OPTIMAL
objective_value:109350.0
[225.0, 0.0, 5000.0, 0.0][0.0, 0.0]
OPTIMAL
objective_value:167000.0
[310.0, 48.0, 6000.0, 0.0][0.0, 0.0]
=#
expected_value = (48820 + 109350 + 167000)/3 #108390

println(" loss in expected profit:", expected_value - risk_averse_expected_profit)