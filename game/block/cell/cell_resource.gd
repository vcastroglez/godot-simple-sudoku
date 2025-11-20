extends Resource
class_name CellResource

@export_enum("GOOD", "BAD") var status: int
@export var value: int
@export var hints: Array[bool]
@export var fixed: bool = false
@export var block: int
@export var cell: int
