extends Label

@onready var player := get_node("/root/Main/Player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    text = "Velocity: {a}\nFriction: {b}\nRotation: {c}\nGrounded: {d}".format({"a": floor(player.velocity), "b": floor(player.air_friction), "c": player.rotation, "d": player.is_on_floor()})
