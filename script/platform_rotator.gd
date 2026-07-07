extends Rotator
class_name PlatformRotator

@export var platforms: Array[Platform]

func _ready() -> void:
    if not platforms:
        push_warning("There is a platform rotator without any assigned platforms!")
    print("platform: ", platforms)


func left_action() -> void:
    super.left_action()
    for platform in platforms:
        platform.step_backward()


func right_action() -> void:
    super.right_action()
    for platform in platforms:
        platform.step_forward()
