extends StaticBody3D

@onready var player = $"../../Player"

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.position.z < position.z:
		visible = false
	else:
		visible = true
