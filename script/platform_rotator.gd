extends Rotator
class_name PlatformRotator

@export var platforms: Array[Platform]

func _ready() -> void:
    super._ready()
    for child in get_children():
        if child is Platform:
            platforms.append(child as Platform)
    assert(!platforms.is_empty(), "a zi sto platform rotator non ha piattaforme assegnate")
    for platform in platforms:
        platform.call_deferred("reparent", get_parent())


func left_action() -> void:
    super.left_action()
    for platform in platforms:
        platform.step_backward()


func right_action() -> void:
    super.right_action()
    for platform in platforms:
        platform.step_forward()
