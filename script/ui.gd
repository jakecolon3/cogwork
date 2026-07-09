extends Control

signal start_pressed
signal toggled_pause


func _ready() -> void:
    $MainMenu.show()
    $PauseMenu.hide()


func _on_start_button_pressed() -> void:
    $MainMenu.hide()
    emit_signal("start_pressed")


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
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

