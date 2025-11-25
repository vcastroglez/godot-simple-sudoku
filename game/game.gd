extends Node2D

@onready var generator: SudokuGenerator = $Generator
@onready var blocks: Control = $Blocks
@onready var spin_box: SpinBox = $SpinBox
@onready var generator_claude: SudokuGeneratorClaude = $GeneratorClaude
@onready var generator_github: GeneratorGithub = $GeneratorGithub

var puzzle : Array
var generator_to_use : SudokuGenerator
var save_path = "user://puzzle.json"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generator_to_use = generator
	GameState.game_updated.connect(_save_game)
	var file = FileAccess.open(save_path, FileAccess.READ)
	if !file:
		generate_new()
		return
	var to_load_puzzle = JSON.parse_string(file.get_as_text())
	var block_number = 0
	for block in to_load_puzzle:
		var block_reference = blocks.get_child(block_number)
		var cell_number = 0
		for cell in block:
			var cell_reference : Cell = block_reference.get_child(cell_number)
			cell_reference.cell.value = cell.value
			cell_reference.cell.block = block_number
			cell_reference.cell.cell = cell_number
			cell_reference.set_fixed(cell.fixed)
			for i in range(9):
				cell_reference.cell.hints[i] = cell.hints[i]
			cell_number += 1
		block_number += 1 
		
	
func _save_game():
	var to_save = generator_to_use.get_empty_puzzle()
	for block in blocks.get_children():
		for cell : Cell in block.get_children():
			var cell_reference : CellResource = cell.cell
			to_save[int(cell_reference.block)][int(cell_reference.cell)] = {
				"value": cell_reference.value,
				"hints": cell_reference.hints,
				"fixed": cell_reference.fixed,
			}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(to_save))
	
func generate_new():
	var diff = spin_box.value
	puzzle = generator_to_use.generate_sudoku(diff)
	var block_number = 0
	for block in puzzle:
		var block_reference = blocks.get_child(block_number)
		var cell_number = 0
		for cell in block:
			var cell_reference : Cell = block_reference.get_child(cell_number)
			cell_reference.cell.value = cell
			cell_reference.cell.block = block_number
			cell_reference.cell.cell = cell_number
			cell_reference.set_fixed(cell > 0)
			cell_number += 1
		block_number += 1 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	generate_new()
