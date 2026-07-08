extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var player := get_node('/root/Main/Player')
    text = "Velocity: {a}\nFriction: {b}".format({"a": floor(player.velocity), "b": floor(player.air_friction)})
