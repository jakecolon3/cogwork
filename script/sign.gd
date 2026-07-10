extends "res://script/interactable.gd"

@export var text: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super._ready()
    if text:
        $Label.text = text

func _interact() -> void:
    visible = !visible
