extends "res://script/interactable.gd"


@export var text: String
var scrolling: bool
var text_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super._ready()
    $Label.visible = false
    if $Label.text:
        text = $Label.text
        $Label.text = ""
    scrolling = false

func skip_scroll() -> void:
    $Label.text = text
    scrolling = false
    $Timer.stop()


func _interact(interactor: Player) -> void:
    if scrolling:
        skip_scroll()
    else:
        $Label.visible = !$Label.visible
        if $Label.visible:
            $Timer.start()
            scrolling = true
        else:
            text_index = 0
            $Label.text = ""


# scrolls characters
func _on_timer_timeout() -> void:
    if text_index >= text.length():
        $Timer.stop()
        scrolling = false
        return
    text_index += 1
    $Label.text = text.substr(0, text_index)
    $Timer.start()
