extends Area2D
class_name Interactable

@export var frames: SpriteFrames
var sprite: AnimatedSprite2D
var collision_area: CollisionShape2D

func _ready() -> void:
    set_collision_layer_value(1, false)
    set_collision_layer_value(3, true)
    sprite = AnimatedSprite2D.new()
    sprite.sprite_frames = frames
    collision_area = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.size = Vector2(16, 16)
    collision_area.shape = rect
    add_child(collision_area)
    add_child(sprite)

func _interact(interactor: Player) -> void:
    pass
