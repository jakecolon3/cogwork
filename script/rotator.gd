extends Interactable
class_name Rotator

var attached    : bool = false
var player      : Player


func _ready() -> void:
    super._ready()


func left_action() -> void:
    player.gravity_direction = player.gravity_direction.rotated(PI / 2)


func right_action() -> void:
    player.gravity_direction = player.gravity_direction.rotated(3 * PI / 2)


func detach() -> void:
    attached = false
    player = null


func attach(to: Player) -> void:
    attached = true
    player = to
