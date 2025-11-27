extends Control
class_name Cell

@export var cell: CellResource
@onready var label: Label = $Label
@onready var color_rect: ColorRect = $ColorRect
@onready var hints: Control = $Hints
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var line_edit: LineEdit = $CanvasLayer/Control/LineEdit
@onready var hint_togglers: Control = $CanvasLayer/Control/hintTogglers
@onready var value_togglers: Control = $CanvasLayer/Control/valueTogglers

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cell = CellResource.new()
	cell.status = 0
	cell.value = 0
	cell.hints = [false,false,false,false,false,false,false,false,false]
	cell.fixed = false
	var settings = LabelSettings.new()
	settings.font_size = 33
	settings.font_color = Color.BLACK
	label.label_settings = settings
	
	GameState.cell_selected.connect(_on_cell_selected)
	GameState.check_value.connect(_on_check_value)
	
func _on_check_value():
	if cell.fixed || cell.value == 0 || cell.value > 9:
		return
	var solved_value = GameState.solved_puzzle[cell.block][cell.cell]
	if cell.status != 1 && solved_value != cell.cell:
		cell.status = 1
	
func _on_cell_selected(block_number, cell_number):
	if block_number != cell.block || cell_number != cell.cell:
		canvas_layer.visible = false
	
	if block_number == cell.block:
		if cell.cell != cell_number:
			cell.status = 2
		else:
			cell.status = 3
		return
		
	var selected_row_col = get_row_col(block_number, cell_number)
	var my_row_col = get_row_col(cell.block, cell.cell)
	
	if (selected_row_col[0] == my_row_col[0]) || (selected_row_col[1] == my_row_col[1]):
		cell.status = 2
	else:
		cell.status = 0

func get_row_col(block_number, cell_number):
	var row_in_block = floor(cell_number / 3)
	var col_in_block = cell_number % 3
	
	var row = floor(block_number / 3) * 3 + row_in_block
	var col = (block_number % 3) * 3 + col_in_block
	return [row, col]
	

func set_fixed(new_value: bool):
	cell.fixed = new_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if cell.value < 0:
		cell.value = 0
	if cell.value != 0:
		label.visible = true
		label.text = str(cell.value)
	else:
		label.visible = false
		
	if cell.status == 0:#good
		color_rect.color = Color(1,1,1,1) 
	elif cell.status == 1:#bad
		color_rect.color = Color(1,0,0,1)
	elif cell.status == 2:#high
		color_rect.color = Color(0.8, 0.882, 0.954)
	else:#selected
		color_rect.color = Color(0.615, 0.771, 0.906)
		
		
	label.label_settings.font_color = Color(0, 0, 0, 1) if cell.fixed else Color(0.456, 0.259, 0.758)
	
	hints.visible = !label.visible
	for i in range(0, hints.get_child_count()):
		var ref_rect : ReferenceRect = hints.get_child(i)
		var hint = cell.hints[i]
		var label : Label = ref_rect.get_child(0)
		ref_rect.visible = hint
		label.text = str(i + 1)
		

func set_value(new_value: int):
	if cell.fixed:
		return
	cell.value = new_value

func _on_button_pressed() -> void:
	if cell.fixed:
		return
	GameState.cell_selected.emit(cell.block, cell.cell)
	canvas_layer.visible = true
	GameState.game_updated.emit()

func _on_line_edit_text_changed(new_text: String) -> void:
	var old_value = str(cell.value)
	if new_text.length() > 4:
		line_edit.text = old_value
		return
	cell.value = int(new_text)
	line_edit.text = str(cell.value)
	line_edit.caret_column = line_edit.text.length()   

func _on_canvas_layer_visibility_changed() -> void:
	if canvas_layer.visible:
		line_edit.text = str(cell.value)
	var value = str(cell.value)
	for i in range(0, hints.get_child_count()):
		var hint_toggler : CheckBox = hint_togglers.get_child(i)
		var value_toggler : CheckBox = value_togglers.get_child(i)
		
		var hint = cell.hints[i]
		var has_value = value.contains(str(i+1))
		hint_toggler.button_pressed = hint
		value_toggler.button_pressed = has_value

func _on_t_1_toggled(toggled_on: bool) -> void:
	cell.hints[0] = toggled_on
	GameState.game_updated.emit()
	
func _on_t_2_toggled(toggled_on: bool) -> void:
	cell.hints[1] = toggled_on
	GameState.game_updated.emit()

func _on_t_3_toggled(toggled_on: bool) -> void:
	cell.hints[2] = toggled_on
	GameState.game_updated.emit()

func _on_t_4_toggled(toggled_on: bool) -> void:
	cell.hints[3] = toggled_on
	GameState.game_updated.emit()

func _on_t_5_toggled(toggled_on: bool) -> void:
	cell.hints[4] = toggled_on

func _on_t_6_toggled(toggled_on: bool) -> void:
	cell.hints[5] = toggled_on
	GameState.game_updated.emit()

func _on_t_7_toggled(toggled_on: bool) -> void:
	cell.hints[6] = toggled_on
	GameState.game_updated.emit()

func _on_t_8_toggled(toggled_on: bool) -> void:
	cell.hints[7] = toggled_on
	GameState.game_updated.emit()

func _on_t_9_toggled(toggled_on: bool) -> void:
	cell.hints[8] = toggled_on
	GameState.game_updated.emit()

func _on_clear_pressed() -> void:
	for i in range(0, hints.get_child_count()):
		var hint_toggler : CheckBox = hint_togglers.get_child(i)
		cell.hints[i] = false
		hint_toggler.button_pressed = false

func _on_clear_values_pressed() -> void:
	cell.value = 0
	for i in range(0, value_togglers.get_child_count()):
		var value_toggler : CheckBox = value_togglers.get_child(i)
		value_toggler.button_pressed = false

func _on_t_1v_pressed() -> void:
	addValue(1)

func _on_t_2v_pressed() -> void:
	addValue(2)


func _on_t_3v_pressed() -> void:
	addValue(3)


func _on_t_4v_pressed() -> void:
	addValue(4)


func _on_t_5v_pressed() -> void:
	addValue(5)

func _on_t_6v_pressed() -> void:
	addValue(6)

func _on_t_7v_pressed() -> void:
	addValue(7)

func _on_t_8v_pressed() -> void:
	addValue(8)

func _on_t_9v_pressed() -> void:
	addValue(9)
	
func addValue(new_value):
	var str_value = str(new_value)
	var current_value = str(cell.value)
	if current_value.contains(str_value):
		current_value = current_value.replace(str_value, '')
	else:
		current_value = current_value + str_value
		
	if !current_value:
		current_value = "0"
	cell.value = int(current_value)
	GameState.game_updated.emit()
