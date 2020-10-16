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

println("1. VALUE OF THE STOCHASTIC SOLUTION")
#the average situation solution is:
obj_value, x, w, y = build_and_solve_model(land, cattle, sell_mean, buy_mean, yield_mean, quota, plant)
println("\nAverage situation\n","obj_value: ", obj_value,"\n x:", x, "\n w: ", w, "\n y: ", y)
#obj_value: 118600.0
# x:[120.0, 80.0, 300.0]
# w: [100.0, 0.0, 6000.0, 0.0]
# y: [0.0, 0.0]

#Let's apply these values of x to the 2 other possible scenarios:
obj_value, w, y = model_with_first_stage_given([120, 80, 300], sell_mean, buy_mean, yield_mean *(1 - yield_var), plant) # 148_000.0
println("\nOver average situation\n","obj_value: ", obj_value,"\n w: ", w, "\n y: ", y)
obj_value, w, y = model_with_first_stage_given([120, 80, 300], sell_mean, buy_mean, yield_mean *(1 + yield_var), plant) # 55_120.0
println("\nBelow average situation\n", "obj_value: ", obj_value,"\n w: ", w, "\n y: ", y)



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

println("\n\n3. BINARY FIRST STAGE\n")


