extends Node3D

var tile_scene = preload("res://scenes/tile.tscn")

func _ready() -> void:
	var test_tilemap := []
	for z in range(12):
		var line := []
		for x in range(12):
			line.append(randi_range(0,1))
		test_tilemap.append(line)
	
	var x = 0
	var z = 0
	var increment := sqrt(.5)
	for inc_x in range(len(test_tilemap)):
		x = inc_x * -increment 
		z = inc_x * increment
		for inc_z in range(len(test_tilemap[0])):
			var new_tile = tile_scene.instantiate()
			new_tile.position = Vector3(x,0,z)
			add_child(new_tile)
			z += increment
			x += increment
