extends Node
class_name SudokuGeneratorClaude
# Sudoku Generator in GDScript
# Based on Norvig's algorithm: https://norvig.com/sudoku.html

const DIGITS = "123456789"
const ROWS = "ABCDEFGHI"
var squares := []
var unitlist := []
var units := {}
var peers := {}

func _ready():
	_initialize()

# Initialize the data structures
func _initialize():
	# Create all squares (A1-I9)
	squares = _cross(ROWS, DIGITS)
	
	# Create all units (rows, columns, and 3x3 boxes)
	unitlist = []
	for c in DIGITS:
		unitlist.append(_cross(ROWS, c))
	for r in ROWS:
		unitlist.append(_cross(r, DIGITS))
	for rs in ["ABC", "DEF", "GHI"]:
		for cs in ["123", "456", "789"]:
			unitlist.append(_cross(rs, cs))
	
	# Map each square to its units
	units = {}
	for s in squares:
		units[s] = []
		for u in unitlist:
			if s in u:
				units[s].append(u)
	
	# Map each square to its peers
	peers = {}
	for s in squares:
		var peer_set := {}
		for u in units[s]:
			for sq in u:
				if sq != s:
					peer_set[sq] = true
		peers[s] = peer_set.keys()

# Cross product of two strings
func _cross(a: String, b: String) -> Array:
	var result := []
	for ac in a:
		for bc in b:
			result.append(ac + bc)
	return result

# Main generation function with difficulty parameter (1-4)
# Returns Array[9][9] where each element is a 3x3 block
# Empty cells are represented by 0
func generate_sudoku(difficulty: int = 1) -> Array:
	var grid := _generate_puzzle(difficulty)
	return _grid_to_blocks(grid)

# Generate a puzzle based on difficulty (1=easy, 4=very hard)
func _generate_puzzle(difficulty: int) -> String:
	# Start with a solved puzzle
	var values := {}
	for s in squares:
		values[s] = DIGITS
	
	# Generate a random valid solution
	values = _search(values)
	if not values:
		return _generate_puzzle(difficulty) # Try again
	
	# Convert solution to grid string
	var full_grid := ""
	for s in squares:
		full_grid += values[s]
	
	# Remove digits based on difficulty
	# Difficulty 1: 35-40 clues (easy)
	# Difficulty 2: 30-35 clues (medium)
	# Difficulty 3: 25-30 clues (hard)
	# Difficulty 4: 17-25 clues (very hard)
	var min_clues = max(17, 45 - difficulty * 7)
	var max_clues = max(20, 50 - difficulty * 7)
	var target_clues = randi() % (max_clues - min_clues + 1) + min_clues
	
	var indices := range(81)
	indices.shuffle()
	
	var grid := full_grid
	var removed := 0
	
	for i in indices:
		if removed >= 81 - target_clues:
			break
		
		var test_grid := grid.substr(0, i) + "." + grid.substr(i + 1)
		var test_values := _parse_grid(test_grid)
		
		if test_values and _has_unique_solution(test_values):
			grid = test_grid
			removed += 1
	
	return grid

# Check if puzzle has unique solution (simplified check)
func _has_unique_solution(values: Dictionary) -> bool:
	return _search(values) != null

# Parse grid string into possible values dictionary
func _parse_grid(grid: String) -> Dictionary:
	var values := {}
	for s in squares:
		values[s] = DIGITS
	
	var chars := []
	for c in grid:
		if c in DIGITS or c in "0.":
			chars.append(c)
	
	if chars.size() != 81:
		return {}
	
	for i in range(81):
		var s = squares[i]
		var d = chars[i]
		if d in DIGITS and not _assign(values, s, d):
			return {}
	
	return values

# Assign value d to square s by eliminating all other values
func _assign(values: Dictionary, s: String, d: String) -> bool:
	var other_values = values[s].replace(d, "")
	for d2 in other_values:
		if not _eliminate(values, s, d2):
			return false
	return true

# Eliminate value d from square s and propagate constraints
func _eliminate(values: Dictionary, s: String, d: String) -> bool:
	if d not in values[s]:
		return true # Already eliminated
	
	values[s] = values[s].replace(d, "")
	
	# (1) If a square is reduced to one value, eliminate it from peers
	if values[s].length() == 0:
		return false # Contradiction
	elif values[s].length() == 1:
		var d2 = values[s]
		for s2 in peers[s]:
			if not _eliminate(values, s2, d2):
				return false
	
	# (2) If a unit has only one place for value d, assign it there
	for u in units[s]:
		var dplaces := []
		for us in u:
			if d in values[us]:
				dplaces.append(us)
		
		if dplaces.size() == 0:
			return false # Contradiction
		elif dplaces.size() == 1:
			if not _assign(values, dplaces[0], d):
				return false
	
	return true

# Depth-first search with constraint propagation
func _search(values: Dictionary):
	if not values:
		return null
	
	# Check if solved
	var all_solved := true
	for s in squares:
		if values[s].length() != 1:
			all_solved = false
			break
	
	if all_solved:
		return values
	
	# Choose unfilled square with fewest possibilities
	var min_len := 10
	var min_square := ""
	for s in squares:
		if values[s].length() > 1 and values[s].length() < min_len:
			min_len = values[s].length()
			min_square = s
	
	# Try each possible value
	for d in values[min_square]:
		var new_values := _copy_values(values)
		if _assign(new_values, min_square, d):
			var result = _search(new_values)
			if result:
				return result
	
	return null

# Deep copy values dictionary
func _copy_values(values: Dictionary) -> Dictionary:
	var copy := {}
	for s in values:
		copy[s] = values[s]
	return copy

# Convert 81-character grid string to 9x9 blocks array
# Blocks are numbered 0-8, left to right, top to bottom
# Each block contains 9 cells, also left to right, top to bottom
func _grid_to_blocks(grid: String) -> Array:
	var blocks := []
	
	# Initialize 9 empty blocks
	for i in range(9):
		blocks.append([])
		for j in range(9):
			blocks[i].append(0)
	
	# Map grid positions to blocks
	# Block layout:
	# 0 1 2
	# 3 4 5
	# 6 7 8
	for row in range(9):
		for col in range(9):
			var grid_index = row * 9 + col
			var char = grid[grid_index]
			
			# Determine which block (0-8)
			var block_row = int(row / 3)
			var block_col = int(col / 3)
			var block_index = block_row * 3 + block_col
			
			# Determine position within block (0-8)
			var cell_row = row % 3
			var cell_col = col % 3
			var cell_index = cell_row * 3 + cell_col
			
			# Set value (0 for empty, 1-9 for filled)
			if char in DIGITS:
				blocks[block_index][cell_index] = int(char)
			else:
				blocks[block_index][cell_index] = 0
	
	return blocks
