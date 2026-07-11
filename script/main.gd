extends Node2D

@export var level_name: String

# TODO: better way to set starting position
func _ready() -> void:
    if not level_name:
        var spawn_location : Vector2 = $TestLevel.spawn_location.position
        $Player.set_deferred("position", spawn_location)
        $Player.respawn_location = spawn_location
        get_tree().paused = true
        return
    $TestLevel.free()
    var level_scene := load("res://scenes/levels/%s.tscn" % level_name)
    assert(level_scene, "a zi hai sbagliato il nome del livello")
    var level : Level = level_scene.instantiate()
    add_child(level)
    var spawn_location : Vector2 = level.spawn_location.position
    $Player.set_deferred("position", spawn_location)
    $Player.respawn_location = spawn_location
    level.show()
    level.get_node("Tiles").enabled = true
    $Player.player_died.connect(level.reset_level)


func _on_ui_start_pressed() -> void:
    get_tree().paused = false


func _on_ui_toggled_pause() -> void:
    get_tree().paused = !get_tree().paused

