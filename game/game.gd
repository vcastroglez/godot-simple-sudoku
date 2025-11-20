extends Node2D

@onready var generator: SudokuGenerator = $Generator
@onready var blocks: Control = $Blocks
@onready var spin_box: SpinBox = $SpinBox
@onready var generator_claude: SudokuGeneratorClaude = $GeneratorClaude
@onready var generator_github: GeneratorGithub = $GeneratorGithub

var generator_to_use
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generator_to_use = generator_claude
	generate_new()
	
func generate_new():
	var diff = spin_box.value
	print("Using: ",generator_to_use)
	var puzzle = generator_to_use.generate_sudoku(diff)
	var block_number = 0
	for block in puzzle:
		var block_reference = blocks.get_child(block_number)
		var cell_number = 0
		for cell in block:
			var cell_reference : Cell = block_reference.get_child(cell_number)
			cell_reference.cell.value = cell
			cell_reference.set_fixed(cell > 0)
			cell_number += 1
		block_number += 1 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	generate_new()
