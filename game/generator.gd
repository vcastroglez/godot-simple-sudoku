extends Node
class_name SudokuGenerator

# Generate a Sudoku puzzle with difficulty level 1-4
func generate_sudoku(difficulty: int) -> Array:
	difficulty = clamp(difficulty, 1, 4)
	
	var board = _generate_solved_board()
	var clues_to_keep = _get_clues_for_difficulty(difficulty)
	var puzzle = _remove_numbers(board, clues_to_keep)
	return puzzle

# Generate a complete valid Sudoku board
func _generate_solved_board() -> Array:
	var board = []
	for i in range(9):
		board.append([])
		for j in range(9):
			board[i].append(0)
	
	_fill_board(board)
	return board

# Recursive backtracking to fill the board
func _fill_board(board: Array) -> bool:
	for row in range(9):
		for col in range(9):
			if board[row][col] == 0:
				var numbers = range(1, 10)
				numbers.shuffle()
				
				for num in numbers:
					if _is_valid(board, row, col, num):
						board[row][col] = num
						
						if _fill_board(board):
							return true
						
						board[row][col] = 0
				
				return false
	return true

# Check if placing a number is valid
func _is_valid(board: Array, row: int, col: int, num: int) -> bool:
	for x in range(9):
		if board[row][x] == num:
			return false
	for x in range(9):
		if board[x][col] == num:
			return false
	
	var start_row = (row / 3) * 3
	var start_col = (col / 3) * 3
	for i in range(3):
		for j in range(3):
			if board[start_row + i][start_col + j] == num:
				return false
	return true

# Determine number of clues based on difficulty
func _get_clues_for_difficulty(difficulty: int) -> int:
	match difficulty:
		1: return randi_range(36, 40)
		2: return randi_range(30, 35)
		3: return randi_range(25, 29)
		4: return randi_range(20, 24)
		_: return 30

# Remove numbers while preserving unique solution
func _remove_numbers(board: Array, clues_to_keep: int) -> Array:
	var puzzle = []
	for row in board:
		puzzle.append(row.duplicate())
	
	var cells_to_remove = 81 - clues_to_keep
	var attempts = 0
	var max_attempts = 1000
	
	while cells_to_remove > 0 and attempts < max_attempts:
		var row = randi() % 9
		var col = randi() % 9
		
		if puzzle[row][col] != 0:
			var backup = puzzle[row][col]
			puzzle[row][col] = 0
			
			if _has_unique_solution(puzzle):
				cells_to_remove -= 1
			else:
				puzzle[row][col] = backup
		
		attempts += 1
	
	return puzzle

# Check if puzzle has a unique solution
func _has_unique_solution(puzzle: Array) -> bool:
	var test_board = []
	for row in puzzle:
		test_board.append(row.duplicate())
	
	var solutions = [0]
	
	_count_solutions(test_board, solutions, 2)
	
	return solutions[0] == 1

# Count number of solutions using backtracking
func _count_solutions(board: Array, solutions: Array, max_count: int) -> void:
	if solutions[0] >= max_count:
		return
	
	for row in range(9):
		for col in range(9):
			if board[row][col] == 0:
				for num in range(1, 10):
					if _is_valid(board, row, col, num):
						board[row][col] = num
						_count_solutions(board, solutions, max_count)
						board[row][col] = 0
						
						if solutions[0] >= max_count:
							return
				return
	
	solutions[0] += 1
