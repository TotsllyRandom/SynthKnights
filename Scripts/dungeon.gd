extends Node3D

var tile_scene = preload("res://scenes/tile.tscn")
var wall_scene = preload("res://scenes/wall.tscn")

var rooms = []
func find_room(pos:Vector2i) -> int:
	for room in range(len(rooms)):
		if rooms[room]["pos"] == Vector2i(pos.x,pos.y):
			return room
	return -1

var tilemap = []

const TILE_INCREMENT := sqrt(.5) ##Distance moved (either on X or Z axis) to get to next tile.

func _ready() -> void:
	var test_tilemap := []
	for z in range(12):
		var line := []
		for x in range(12):
			if x == 0 || x == 11 || z == 0 || z == 11:
				line.append("W")
			else:
				line.append(1)
		test_tilemap.append(line)
	build_tiles(test_tilemap)
	

func build_tiles(_tilemap: Array):
	for child in $Ground.get_children():
		child.queue_free()
		
	for inc_x in range(len(tilemap)):
		for inc_z in range(len(tilemap[inc_x])):
			var x_pos = (inc_z - inc_x) * TILE_INCREMENT
			var z_pos = (inc_z + inc_x) * TILE_INCREMENT
			
			var new_tile: Node3D
			if str(tilemap[inc_x][inc_z]) != "W":
				new_tile = tile_scene.instantiate()
				new_tile.tile_data = [1,1,1,1]
			else:
				new_tile = wall_scene.instantiate()
				
			new_tile.position = Vector3(x_pos, 0, z_pos)
			$Ground.add_child(new_tile)

func make_room_heightmap() -> Array:
	var ret = []
	for x in range(9):
		var line = []
		for z in range(9):
			line.append([1,1,1,1])
		ret.append(line)
	return ret

func gen_dungeon():
	make_room(Vector2i(0,0))

func door_vector_change(door:int,x,y):
	var ret = Vector2i(x,y)
	match door:
		0:
			ret.x = x-1
		2:
			ret.x = x+1
		1:
			ret.y = y-1
		3:
			ret.y = y+1
	return ret

func make_room(pos:Vector2i, strand = 0):
	var max_strand = 5
	
	var x = pos.x
	var z = pos.y
	var room = find_room(Vector2i(x,z))
	
	if room == -1:
		room = len(rooms)
		rooms.append(
			{
				#doors: -1 = undecided, 0 = wall, 1 = door unconfirmed, 2 = door confirmed
				"doors" : [-1,-1,-1,-1],
				"pos" : Vector2i(x,z),
				"type" : "none",
				"made" : false,
			}
		)
	
	for door in range(4):
		if rooms[room]["doors"][door] == -1:
			var next_room = find_room(door_vector_change(door,x,z))
			if next_room == -1:
				next_room = len(rooms)
				rooms.append(
					{
						#doors: -1 = undecided, 0 = wall, 1 = door
						"doors" : [-1,-1,-1,-1],
						"pos" : door_vector_change(door,x,z),
						"type" : "none",
						"made" : false,
					}
				)
			var next_door = door - 2
			if next_door < 0:
				next_door += 4
			
			if rooms[next_room]["doors"][next_door] == -1 || rooms[room]["doors"][door] == -1:
				if strand == max_strand:
					rooms[room]["doors"][door] = 0
				else:
					rooms[room]["doors"][door] = randi_range(0,1)
				rooms[next_room]["doors"][next_door] = rooms[room]["doors"][door]
	
	rooms[room]["made"] = true
	for door in range(4):
		var next_room = find_room(door_vector_change(door,x,z))
		if rooms[room]["doors"][door] == 1 && (rooms[next_room]["made"] == false):
			make_room(door_vector_change(door,x,z),strand + 1)
