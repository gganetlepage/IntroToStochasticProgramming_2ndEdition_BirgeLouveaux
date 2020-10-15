include("C:/Personnel/Programmation/Julia/IntroToStochasticProgramming_2ndEdition_BirgeLouveaux/chapter1_IntroAndExamples_Lib.jl")
#import chapter1_IntroAndExamples.jl
#using chapter1_IntroAndExamples


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



# solve_multiple_models(land, cattle, sell_mean, sell_var, buy_mean, buy_var, yield_mean, yield_var, quota, plant)
#=
objective_value:59950.0
[100.0, 25.0, 375.0][0.0, 0.0, 6000.0, 0.0][0.0, 180.0]

objective_value:118600.0
[120.0, 80.0, 300.0][100.0, 0.0, 6000.0, 0.0][0.0, 0.0]

objective_value:167666.6666666667
[183.33333333333331, 66.66666666666667, 250.0][350.0, 0.0, 6000.0, 0.0][0.0, 0.0]
=#


println("Exercices:")
# 1. Value of the stochastic solution

#=
The average situation results in this solution:
objective_value:118600.0
[120.0, 80.0, 300.0][100.0, 0.0, 6000.0, 0.0][0.0, 0.0]
Apply this solution to the 2 other possible situations in order to get their associate outcome
=#
obj_value, w, y = model_with_first_stage_given([120, 80, 300], sell_mean, buy_mean, yield_mean *(1 - yield_var), plant) # 148_000.0
obj_value, w, y = model_with_first_stage_given([120, 80, 300], sell_mean, buy_mean, yield_mean *(1 + yield_var), plant) # 55_120.0
println("obj_value: ", obj_value,"\n w: ", w, "\n y: ", y)



values = [118600, 55120, 148000]
println(sum(values)/3)