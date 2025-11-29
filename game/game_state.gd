extends Node

signal cell_selected(block: int, cell: int)
signal game_updated(cell: CellResource)
signal check_value()

var puzzle: Array
var solved_puzzle: Array
var plain_puzzle: Array
var save_path = "user://puzzle.json"
var difficulty := 1

const Generator = preload("res://game/generator.gd")
var generator : SudokuGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cell_selected.connect(_on_cell_selected)

var selected_block
var selected_cell

func _on_cell_selected(block_number, cell_number):
	selected_block = block_number
	selected_cell = cell_number
	
func init() -> void:
	generator = Generator.new()
	var file = FileAccess.open(save_path, FileAccess.READ)
	if !file:
		generate_new()
		return
		
	var generation = JSON.parse_string(file.get_as_text())
	if typeof(generation[0][0]) != TYPE_ARRAY:
		DirAccess.remove_absolute(save_path)
		generate_new()
		return
	puzzle = generation[0]
	solved_puzzle = generation[1]
	plain_puzzle = generator.get_empty_puzzle()
	for block in puzzle:
		for cell in block:
			plain_puzzle[cell.block][cell.cell] = int(cell.value)
	
func _save_game(to_save):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify([to_save, solved_puzzle]))
	
func get_empty_puzzle() -> Array:
	return generator.get_empty_puzzle()

func generate_new():
	puzzle = generator.get_empty_puzzle()
	print('Generating ',difficulty)
	var generation = generator.generate_sudoku(difficulty)
	plain_puzzle = generation[0]
	solved_puzzle = generation[1]
	
	var block_number = 0
	for block in plain_puzzle:
		var cell_number = 0
		for cell in block:
			puzzle[block_number][cell_number] = {
				"value": cell,
				"fixed": cell > 0,
				"hints": generator.get_empty_block(false),
				"block": block_number,
				"cell": cell_number,
				"status": 0
			}
			cell_number += 1
		block_number += 1
	
func get_puzzle() -> Array:
	return puzzle;

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
		
func get_hints(block_number, cell_number) -> Array:
	return generator.get_possible_values(block_number, cell_number, plain_puzzle)
