include("C:/Personnel/Programmation/Julia/IntroToStochasticProgramming_2ndEdition_BirgeLouveaux/JuMPTutorialsExercises.jl")

#Sudoku
model = build_model()

obj, x = solve_model(model)

sudoku, count = binary_to_sudoku(x)
print_sudoku(sudoku)

#=
Integer[3, 2, 8, 1, 4, 7, 6, 5, 9]
Integer[1, 9, 4, 6, 5, 8, 3, 2, 7]
Integer[7, 6, 5, 9, 3, 2, 1, 4, 8]
Integer[4, 1, 9, 2, 6, 5, 8, 7, 3]
Integer[2, 7, 3, 4, 8, 1, 9, 6, 5]
Integer[8, 5, 6, 3, 7, 9, 2, 1, 4]
Integer[5, 3, 7, 8, 2, 6, 4, 9, 1]
Integer[9, 4, 2, 7, 1, 3, 5, 8, 6]
Integer[6, 8, 1, 5, 9, 4, 7, 3, 2]
=#



