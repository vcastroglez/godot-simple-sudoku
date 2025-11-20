extends Control
class_name Cell

@export var cell: CellResource
@onready var label: Label = $Label
@onready var color_rect: ColorRect = $ColorRect
@onready var hints: Control = $Hints
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var line_edit: LineEdit = $CanvasLayer/Control/LineEdit
@onready var hint_togglers: Control = $CanvasLayer/Control/hintTogglers

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cell = CellResource.new()
	cell.status = 0
	cell.value = 0
	cell.hints = [false,false,false,false,false,false,false,false,false]
	cell.fixed = false
	var settings = LabelSettings.new()
	settings.font_size = 30
	settings.font_color = Color.BLACK
	label.label_settings = settings
	

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
		
	color_rect.color = Color(1,1,1,1) if cell.status == 0 else Color(1,0,0,1)
	label.label_settings.font_color = Color(0, 0, 0, 1) if cell.fixed else Color(0.388, 0.482, 1, 1)
	
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
	canvas_layer.visible = true

func _on_close_btn_pressed() -> void:	
	canvas_layer.visible = false

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
		
	for i in range(0, hints.get_child_count()):
		var hint_toggler : CheckBox = hint_togglers.get_child(i)
		var hint = cell.hints[i]
		hint_toggler.button_pressed = hint

func _on_t_1_toggled(toggled_on: bool) -> void:
	cell.hints[0] = toggled_on
	
func _on_t_2_toggled(toggled_on: bool) -> void:
	cell.hints[1] = toggled_on

func _on_t_3_toggled(toggled_on: bool) -> void:
	cell.hints[2] = toggled_on


func _on_t_4_toggled(toggled_on: bool) -> void:
	cell.hints[3] = toggled_on

func _on_t_5_toggled(toggled_on: bool) -> void:
	cell.hints[4] = toggled_on


func _on_t_6_toggled(toggled_on: bool) -> void:
	cell.hints[5] = toggled_on


func _on_t_7_toggled(toggled_on: bool) -> void:
	cell.hints[6] = toggled_on


func _on_t_8_toggled(toggled_on: bool) -> void:
	cell.hints[7] = toggled_on

func _on_t_9_toggled(toggled_on: bool) -> void:
	cell.hints[8] = toggled_on


func _on_clear_pressed() -> void:
	for i in range(0, hints.get_child_count()):
		var hint_toggler : CheckBox = hint_togglers.get_child(i)
		cell.hints[i] = false
		hint_toggler.button_pressed = false
