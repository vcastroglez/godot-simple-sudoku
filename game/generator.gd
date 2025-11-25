extends Node
class_name SudokuGenerator

var solved_puzzle : Array = [range(1, 10),range(1, 10),range(1, 10),range(1, 10),range(1, 10),range(1, 10),range(1, 10),range(1, 10),range(1, 10)]
var to_return_puzzle: Array = []
const MIDDLE_DIAGONAL_LINE = [0,4,8]

const FIRST_ROW = [0,1,2]
const MIDDLE_ROW = [3,4,5]
const LAST_ROW = [6,7,8]

const FIRST_COL = [0,3,6]
const MIDDLE_COL = [1,4,7]
const LAST_COL = [2,5,8]

func generate_sudoku(difficulty : int) -> Array:
	var is_good = false
	var tries = 0
	var solved_puzzle = []
	while(!is_good && tries < 25):
		to_return_puzzle = get_empty_puzzle();
		solved_puzzle = generate_solved_sudoku()
		is_good = is_good_puzzle(solved_puzzle)
		tries += 1
	solved_puzzle = hide_some(difficulty, solved_puzzle)
	return solved_puzzle

func hide_some(difficulty, puzzle: Array) -> Array:
	# Remove digits based on difficulty
	# Difficulty 1: 35-40 clues (easy)
	# Difficulty 2: 30-35 clues (medium)
	# Difficulty 3: 25-30 clues (hard)
	# Difficulty 4: 17-25 clues (very hard)
	var min_clues = max(17, 45 - difficulty * 7)
	var max_clues = max(20, 50 - difficulty * 7)
	var target_clues = randi() % (max_clues - min_clues + 1) + min_clues
	
	var places = range(9)
	var removed = 0
	for i in range(81):
		if removed > (81 - target_clues):
			break
		var block_number = places.pick_random()
		var cell_number = places.pick_random()
		if !puzzle[block_number][cell_number]:
			continue
			
		puzzle[block_number][cell_number] = 0
		removed += 1
		if randi_range(0,1): #half symetric generator
			puzzle[8 - block_number][8 - cell_number] = 0
			removed += 1
	return puzzle
	
func is_good_puzzle(puzzle: Array) -> bool:
	for block in puzzle:
		for cell in block:
			if !cell:
				return false
	return true
	
func generate_solved_sudoku() -> Array:
	#first we generate middle line with random numbers from 1 to 9
	var stack = range(1,10)
	stack.shuffle()
	
	var cell_stack = range(9)
	cell_stack.shuffle()
	
	for block_number in [0,8]:
		stack.shuffle()
		for cell_number in cell_stack:
			to_return_puzzle[block_number][cell_number] = stack[cell_number]
		
	#block 2 and 6
	for block_number in [2,6,1,3,7,5,4]:
		for y in range(9):
			var block_possible = range(9)
			var smaller_size = 10
			var smaller_index = 0
			for i in range(9):
				var possible = get_possible_values(block_number, i, to_return_puzzle)
				if possible.size() < smaller_size && to_return_puzzle[block_number][i] == 0:
					smaller_size = possible.size()
					smaller_index = i
				block_possible[i] = possible
				
			var values_smaller = block_possible[smaller_index]
			var value_to_assign = values_smaller.pick_random()
			if !value_to_assign :
				return to_return_puzzle#bad one, stop doing anything
			to_return_puzzle[block_number][smaller_index] = value_to_assign
	
	return to_return_puzzle
	
func generate_consecutive_sudoku():
	#first we generate middle line with random numbers from 1 to 9
	var stack = range(1,10)
	stack.shuffle()
	
	#for each number 1 to 9
	var cell_number = randi_range(1, 9) #initial position of the cell is random
	for i in range(9):
		cell_number = (cell_number + 1) % 9
		var current_value = stack.pop_back() #this is what's written in the cell
		var row_number = floor(cell_number / 3)
		var col_number = cell_number % 3
		#for first row of blocks
		for block_number in  range(9):
			var target_row = (row_number + block_number) % 3
			var target_col = (col_number + block_number  + floor(block_number / 3)) % 3
			var cell_index = (target_row * 3) + target_col
			to_return_puzzle[block_number][cell_index] = current_value
		break
	print_sudoku(to_return_puzzle)
	
	return to_return_puzzle;

func get_possible_values(block_index : int, cell_index : int, puzzle: Array) -> Array:
	var block = puzzle[block_index]
	var cell = block[cell_index]
	
	var to_return = []
	#check the block
	for i in range(1,10):
		if !block.has(i):
			to_return.push_back(i)
			
	#get the blocks to check for row and col
	var blocks_row_to_check = []
	for r in [FIRST_ROW, MIDDLE_ROW, LAST_ROW]:
		if r.has(block_index):
			blocks_row_to_check = r.duplicate()
			blocks_row_to_check.erase(block_index)
			break

	var blocks_column_to_check = []
	for c in [FIRST_COL, MIDDLE_COL, LAST_COL]:
		if c.has(block_index):
			blocks_column_to_check = c.duplicate()
			blocks_column_to_check.erase(block_index)
			break
	
	var cell_row = floor(cell_index / 3)
	
	for block_number in blocks_row_to_check:
		var slice_start = cell_row * 3
		var block_row_numbers = puzzle[block_number].slice(slice_start, slice_start + 3)
		for block_row_number in block_row_numbers:
			to_return.erase(block_row_number)
	
		
	var cell_col = cell_index % 3
	for block_number in blocks_column_to_check:
		to_return.erase(puzzle[block_number][cell_col])
		to_return.erase(puzzle[block_number][cell_col + 3])
		to_return.erase(puzzle[block_number][cell_col + 6])
			
	return to_return


#UTILITY
func print_sudoku(sudoku: Array) -> void:
	print('|-------|-------|-------|')
	for row in range(3):
		var base_index = row * 3 # 0, 3, 6
		var fb = sudoku[base_index]
		var sb = sudoku[base_index + 1] #1,4,7
		var tb = sudoku[base_index + 2] #2,5,8
		for i in range(3):
			var base_i = i * 3 # 0, 3, 6
			print(
				"|",
				implode(' ', fb.slice(base_i, base_i + 3), true),
				"|",
				implode(' ', sb.slice(base_i, base_i + 3), true),
				"|",
				implode(' ', tb.slice(base_i, base_i + 3), true),
				"|"
				)
		print('|-------|-------|-------|')

func implode(separator : String, array : Array, wrap: bool = false) -> String:
	var to_return := "";
	
	for i in range(array.size()):
		var el = array[i]
		if !to_return && !wrap:
			to_return = str(el)
		else:
			to_return = to_return + separator + str(el)
	
	if wrap:
		to_return = to_return + separator
	return to_return
		
func get_empty_puzzle(fill_value := 0) -> Array:
	var fill = []
	fill.resize(9)
	fill.fill(fill_value)
	
	var to_return = []
	to_return.resize(9)
	for i in range(9):
		to_return[i] = fill.duplicate()
	return to_return;
