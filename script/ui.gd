extends Control

signal toggled_pause
signal respawn
signal reset_level
signal level_selected(level: String)
signal next_level

var started: bool


func _ready() -> void:
    $MainMenu.show()
    $PauseMenu.hide()
    $LevelSelect.hide()
    $DiedMenu.hide()
    $LevelComplete.hide()
    started = false


func _on_start_button_pressed() -> void:
    $MainMenu.hide()
    $LevelSelect.show()


func _process(delta: float) -> void:
    if started and Input.is_action_just_pressed("pause"):
        toggle_pause()


func toggle_pause() -> void:
    if $MainMenu.visible:
        return
    emit_signal("toggled_pause")
    if $PauseMenu.visible:
        $PauseMenu.hide()
    else:
        $PauseMenu.show()


func _on_quit_button_pressed() -> void:
    get_tree().quit()


func _on_reset_button_pressed() -> void:
    reset_level.emit()
    $PauseMenu.hide()
    get_tree().paused = false


func _on_level_select_exit() -> void:
    $LevelSelect.hide()
    $MainMenu.show()


func _on_level_select_level_selected(level: String) -> void:
    level_selected.emit(level)
    $LevelSelect.hide()
    started = true


func _on_player_died() -> void:
    $DiedMenu.show()


func _on_respawn_button_pressed() -> void:
    respawn.emit()
    reset_level.emit()
    $DiedMenu.hide()
    get_tree().paused = false


func _on_next_level_button_pressed() -> void:
    next_level.emit()
    $LevelComplete.hide()
