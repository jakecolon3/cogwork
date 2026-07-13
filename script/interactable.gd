extends Area2D
class_name Interactable

@export var frames: SpriteFrames
var sprite        : AnimatedSprite2D
var collision_area: CollisionShape2D
var popup         : Label

func _ready() -> void:
    set_collision_layer_value(1, false)
    set_collision_layer_value(3, true)
    popup = Label.new()
    popup.text = "[F to interact]"
    popup.pivot_offset_ratio = Vector2(0.5, 0.5)
    popup.label_settings = load("res://scenes/resources/popup_label_settings.tres")
    popup.position = Vector2(-43, -32)
    popup.visible = false
    sprite = AnimatedSprite2D.new()
    sprite.sprite_frames = frames
    collision_area = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.size = Vector2(16, 16)
    collision_area.shape = rect
    add_child(collision_area)
    add_child(sprite)
    add_child(popup)


func _process(delta: float) -> void:
    var bodies := get_overlapping_bodies()
    for b in bodies:
        if b is Player:
            popup.rotation = b.rotation - rotation

func _interact(interactor: Player) -> void:
    pass


func show_popup() -> void:
    popup.visible = true


func hide_popup() -> void:
    popup.visible = false
