extends Node2D
class_name Level

@export var spawn_location: Marker2D
var player: Player

func _ready() -> void:
    if not spawn_location:
        spawn_location = get_node_or_null("SpawnLocation")
    assert(spawn_location, "a zi ti sei dimenticato lo SpawnLocation")
    assert(get_node_or_null("Tiles"), "a zi ti sei dimenticato le Tiles")


func reset_level() -> void:
    print("resetting level")
    reset_platforms()
    player.set_deferred("position", spawn_location.position)
    player.set_deferred("respawn_location", spawn_location.position)
    player.set_deferred("velocity", Vector2.ZERO)
    player.set_deferred("gravity_direction", player.GRAVITY_DOWN)
    player.gear_sprite.set_deferred("position", player.position)


func reset_platforms() -> void:
    for child in get_children():
        if child is PlatformRotator:
            (child as PlatformRotator).reset_platforms()
