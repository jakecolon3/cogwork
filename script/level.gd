extends Node2D
class_name Level

@export var spawn_location: Marker2D

func _ready() -> void:
    if not spawn_location:
        spawn_location = get_node_or_null("SpawnLocation")
    assert(spawn_location, "a zi ti sei dimenticato lo SpawnLocation")
    assert(get_node_or_null("Tiles"), "a zi ti sei dimenticato le Tiles")

func reset_level() -> void:
    print("resetting level")
    for child in get_children():
        if child is PlatformRotator:
            (child as PlatformRotator).reset_platforms()
