extends Area2D
class_name Rotator

var interactable: bool
var attached    : bool = false
var player      : Player


func _ready() -> void:
    interactable = false


func left_action() -> void:
    player.gravity_direction = player.gravity_direction.rotated(PI / 2)


func right_action() -> void:
    player.gravity_direction = player.gravity_direction.rotated(3 * PI / 2)


func rotate_player() -> void:
    if Input.is_action_just_pressed("move_left"):
        left_action()
    if Input.is_action_just_pressed("move_right"):
        right_action()


func _process(delta: float) -> void:
    if Input.is_action_just_pressed("interact") and interactable:
        var bodies := get_overlapping_bodies()
        for body in bodies:
            if body.name == "Player":
                player = body as Player
                attached = !attached
                break
        if player:
            player.rotator_interact(self)
    if attached:
        player.position = player.position.lerp(position, player.LERP_SPEED * delta)
        player.velocity = Vector2.ZERO
        rotate_player()


func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        interactable = true


func _on_body_exited(body: Node2D) -> void:
    if body.name == "Player":
        interactable = false
