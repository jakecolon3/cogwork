extends Node2D


# TODO: better way to set starting position
func _ready() -> void:
    var spawn_location : Vector2 = $TestLevel.spawn_location.position
    $Player.set_deferred("position", spawn_location)
    $Player.respawn_location = spawn_location
