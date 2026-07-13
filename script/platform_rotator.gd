extends Rotator
class_name PlatformRotator

@export var platforms: Array[Platform]

func _ready() -> void:
    super._ready()
    $Sprite2D.hide()
    for child in get_children():
        if child is Platform:
            platforms.append(child as Platform)
    assert(!platforms.is_empty(), "a zi sto platform rotator non ha piattaforme assegnate")
    for platform in platforms:
        platform.call_deferred("reparent", get_parent())


func left_action() -> void:
    for platform in platforms:
        if !platform.is_close_to_target():
            return
        platform.step_backward()
    super.left_action()


func right_action() -> void:
    for platform in platforms:
        if !platform.is_close_to_target():
            return
        platform.step_forward()
    super.right_action()


# TODO: also warp the platforms instead of letting them lerp
# BUG:  bad behaviour with checkpoints
func reset_platforms() -> void:
    print("Rotator %s resetting platforms" % self)
    for platform in platforms:
        platform.point_index = 0
