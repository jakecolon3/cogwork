extends Node2D
class_name Main

@export var level_name: String
var cur_level         : Level
var level_index       : int = 0
var level_count       : int

# TODO: better way to set starting position
func _ready() -> void:
    level_count = DirAccess.open("res://scenes/levels").get_files().size() - 2
    if not level_name:
        var spawn_location : Vector2 = $TestLevel.spawn_location.position
        $Player.set_deferred("position", spawn_location)
        $Player.respawn_location = spawn_location
        get_tree().paused = false
        $HUD/UI/LevelSelect.hide()
        $HUD/UI/MainMenu.hide()
        return
    $TestLevel.free()
    get_tree().paused = true
    $HUD/UI.respawn.connect($Player.respawn)


func _on_ui_toggled_pause() -> void:
    get_tree().paused = !get_tree().paused


func load_level(level_path: String) -> void:
    if cur_level:
        cur_level.free()
    var level_scene := load(level_path)
    assert(level_scene)
    var level : Level = level_scene.instantiate()
    level.player = $Player
    cur_level = level
    add_child(level)
    level_index = get_level_index_from_string(level_path)
    var spawn_location : Vector2 = level.spawn_location.position
    $Player.respawn_location = spawn_location
    $Player.set_deferred("position", spawn_location)
    level.show()
    level.get_node("Tiles").enabled = true
    $HUD/UI.reset_level.connect(level.reset_level)


func _on_ui_level_selected(level: String) -> void:
    load_level("res://scenes/levels/" + level)
    get_tree().paused = false


func get_level_index_from_string(level: String) -> int:
    var number := ""
    for c in level:
        if c.is_valid_int():
            number += c
    return number.to_int()


func get_level_path_from_index(index: int) -> String:
    return "res://scenes/levels/level_%s.tscn" % index


func _on_ui_next_level() -> void:
    load_level(get_level_path_from_index(level_index + 1))


func _on_player_level_complete() -> void:
    get_tree().paused = true
    print(level_index, level_count)
    if level_index >= level_count:
        $HUD/UI/LevelComplete/Label.text = "Final Level Finished!"
        $HUD/UI/LevelComplete/Label.position -= Vector2(50, 0)
        $HUD/UI/LevelComplete/NextLevelButton.free()
    $HUD/UI/LevelComplete.show()


func _on_ui_respawn() -> void:
    cur_level.reset_platforms()
