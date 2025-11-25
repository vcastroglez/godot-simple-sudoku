extends Node

signal cell_selected(block: int, cell: int)
signal game_updated()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func save_game(puzzle: Array) -> void:
	print_sudoku(puzzle)

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
		
