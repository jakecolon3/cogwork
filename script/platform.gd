extends AnimatableBody2D
class_name Platform

@export var path: Path2D
@export var platform_speed = 100.0
var point_index = 0

func step_forward() -> void:
    print("stepping")
    point_index = wrapi(point_index + 1, 0, path.curve.point_count)


func step_backward() -> void:
    print("stepping")
    point_index = wrapi(point_index - 1, 0, path.curve.point_count)


func _ready() -> void:
    print("path: ", path)


func _physics_process(delta: float) -> void:
    if path:
        print("position: ", position, "; target position: ", path.curve.get_point_position(point_index) + path.global_position)
        var new_pos := path.curve.get_point_position(point_index) + path.global_position
        print(new_pos)
        position = position.move_toward(new_pos, platform_speed * delta)


func _process(delta: float) -> void:
    pass
