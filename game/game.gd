extends Node2D

@onready var blocks: Control = $Blocks
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var spin_box: SpinBox = $CanvasLayer/SpinBox

var puzzle : Array
var generator_to_use : SudokuGenerator
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.init()
	GameState.game_updated.connect(_save_game)
	fill_up(GameState.get_puzzle())
		
	
func _save_game(new_cell: CellResource):
	var to_save = GameState.get_puzzle()
	
	to_save[int(new_cell.block)][(new_cell.cell)] = {
				"value": new_cell.value,
				"hints": new_cell.hints,
				"fixed": new_cell.fixed,
				"cell": new_cell.cell,
				"block": new_cell.block,
				"status": new_cell.status
			}

	GameState._save_game(to_save)
	
func fill_up(puzzle):
	var block_number = 0
	for block in puzzle:
		var block_reference = blocks.get_child(block_number)
		for cell in block:
			var cell_reference : Cell = block_reference.get_child(cell.cell)
			cell_reference.cell.value = cell.value
			cell_reference.cell.block = cell.block
			cell_reference.cell.cell = cell.cell
			cell_reference.cell.status = cell.status
			cell_reference.set_fixed(cell.fixed)
		block_number += 1 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	GameState.difficulty = int(spin_box.value)
	GameState.generate_new()
	fill_up(GameState.get_puzzle())


func _on_check_btn_pressed() -> void:
	GameState.check_value.emit()

func _on_hints_pressed() -> void:
	var block_number = 0
	for block in blocks.get_children():
		for cell in block.get_children():
			var cell_reference : Cell = block.get_child(cell.cell.cell)
			var hints = GameState.get_hints(cell.cell.block, cell.cell.cell)
			var hint_number = 0
			for i in cell.cell.hints:
				cell.cell.hints[hint_number] = hints.has(hint_number + 1)
				hint_number += 1
		block_number += 1 

func _on_clear_hints_pressed() -> void:
	var block_number = 0
	for block in blocks.get_children():
		for cell in block.get_children():
			var cell_reference : Cell = block.get_child(cell.cell.cell)
			cell_reference.cell.hints = [false,false,false,false,false,false,false,false,false]
		block_number += 1 


func _on_settings_pressed() -> void:
	canvas_layer.visible = true


func _on_close_pressed() -> void:
	canvas_layer.visible = false
