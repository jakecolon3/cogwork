extends Area2D
class_name Rotator

var interactable: bool


func _ready() -> void:
    pass # Replace with function body.


func _process(delta: float) -> void:
    if Input.is_action_just_pressed("interact") and interactable:
        # print("interacted")
        var bodies := get_overlapping_bodies()
        var player: Player = null
        for body in bodies:
            if body.name == "Player":
                player = body as Player
                break
        if player:
            player.attach_to_rotator(self)


func _on_body_entered(body: Node2D) -> void:
    if body.name == "Player":
        interactable = true
        # print("player entered rotator")


func _on_body_exited(body: Node2D) -> void:
    if body.name == "Player":
        interactable = false
        # print("player exited rotator")

