extends Area2D
class_name Interactable

signal player_entered
signal player_exited

@export var sprite: AnimatedSprite2D


func _ready() -> void:
    sprite.reparent(self)


func _process(delta: float) -> void:
    pass



func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        emit_signal("player_entered")


func _on_body_exited(body: Node2D) -> void:
    if body is Player:
        emit_signal("player_exited")
