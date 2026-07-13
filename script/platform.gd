extends TileMapLayer
class_name Platform

const MIN_DISTANCE = 20
@export var path: Path2D
@export var platform_speed = 100.0
var point_index = 0


func _ready() -> void:
    if path:
        path.call_deferred("reparent", get_parent())


func step_forward() -> void:
    point_index = wrapi(point_index + 1, 0, path.curve.point_count)


func step_backward() -> void:
    point_index = wrapi(point_index - 1, 0, path.curve.point_count)


func get_target_pos() -> Vector2:
    return path.curve.get_point_position(point_index) + path.global_position


func _physics_process(delta: float) -> void:
    if path:
        # print("position: ", position, "; target position: ", path.curve.get_point_position(point_index) + path.global_position)
        var new_pos := get_target_pos()
        position = position.move_toward(new_pos, platform_speed * delta)


func is_close_to_target() -> bool:
    return position.distance_to(get_target_pos()) < MIN_DISTANCE
