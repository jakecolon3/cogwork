extends Node2D

@export var level: Level

# TODO: better way to set starting position
func _ready() -> void:
    if not level:
        var spawn_location : Vector2 = $TestLevel.spawn_location.position
        $Player.set_deferred("position", spawn_location)
        $Player.respawn_location = spawn_location
        get_tree().paused = true
    else:
        $TestLevel.free()
        var spawn_location : Vector2 = level.spawn_location.position
        $Player.set_deferred("position", spawn_location)
        $Player.respawn_location = spawn_location
        level.show()
        level.get_node("Tiles").enabled = true



func _on_ui_start_pressed() -> void:
    get_tree().paused = false


func _on_ui_toggled_pause() -> void:
    get_tree().paused = !get_tree().paused

