extends Node
class_name SudokuGenerator

var solved_puzzle : Array = [range(9),range(9),range(9),range(9),range(9),range(9),range(9),range(9),range(9)]
var to_return_puzzle: Array = [range(9),range(9),range(9),range(9),range(9),range(9),range(9),range(9),range(9)]
# Generate a Sudoku puzzle with difficulty level 1-4
func generate_sudoku(difficulty: int) -> Array:
	#Generate random 
	return to_return_puzzle;
