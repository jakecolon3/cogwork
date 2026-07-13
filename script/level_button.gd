extends Button
class_name LevelButton

signal pressed_(level: String)

@export var level: String


func _on_pressed() -> void:
    pressed_.emit(level)

