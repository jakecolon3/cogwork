extends Interactable
class_name Rotator

var player      : Player


# TODO: _interact()
func _ready() -> void:
    super._ready()


func left_action() -> void:
    player.gravity_direction = player.gravity_direction.rotated(PI / 2)


func right_action() -> void:
    player.gravity_direction = player.gravity_direction.rotated(3 * PI / 2)


func detach() -> void:
    player = null


func attach(to: Player) -> void:
    player = to


func _interact(interactor: Player) -> void:
    if player:
        detach()
    else:
        attach(interactor)
