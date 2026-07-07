extends CharacterBody2D
class_name Player


const SPEED            = 300.0
const ACCEL            = 70.0
const AIR_ACCEL        = 60.0
const SPEED_CAP_H      = 300.0
const SPEED_CAP_V      = 10000.0
const FRICTION_CAP     = 600.0
const JUMP_VELOCITY    = -600.0
const LERP_SPEED       = 12.0
const INPUT_BUFFER     = 10
const FRICTION         = 0.2
const AIR_FRICTION     = 0.01
const MAX_AIR_FRICTION = 0.3
var gravity_direction: Vector2
var right_vec        : Vector2
var attached         : bool
var attached_to      : Rotator
var input_buffer     : Array[String]
var air_friction     : float


func _ready() -> void:
    var screen_size = get_viewport_rect().size
    position = Vector2(screen_size.x / 2, screen_size.y / 2)
    gravity_direction = Vector2(0, 1)
    right_vec = Vector2(1, 0)
    input_buffer = []


func add_to_input_buffer(action: String):
    input_buffer.push_front(action)
    while input_buffer.size() > INPUT_BUFFER:
        input_buffer.pop_back()


func debug_inputs() -> void:
    if Input.is_action_just_pressed("debug_1"):
        gravity_direction = Vector2(0, 1)
        print("debug_1")
    if Input.is_action_just_pressed("debug_2"):
        gravity_direction = Vector2(0, -1)
        print("debug_2")
    if Input.is_action_just_pressed("debug_3"):
        gravity_direction = Vector2(1, 0)
        print("debug_3")
    if Input.is_action_just_pressed("debug_4"):
        gravity_direction = Vector2(-1, 0)
        print("debug_4")


func rotator_interact(rotator: Rotator) -> void:
    if attached:
        attached = false
        return
    print("attached")
    attached    = true
    attached_to = rotator


func _physics_process(delta: float) -> void:
    rotation = lerp_angle(rotation, gravity_direction.angle() - PI/2,
                          LERP_SPEED * delta)
    if attached:
        return
    debug_inputs()
    right_vec = gravity_direction.orthogonal()

    if not is_on_floor():
        velocity += (get_gravity().length() * gravity_direction) * delta


    # slide returns a vector which has only has the component of the starting vector that is perpendicular to the argument
    # also jumps if there's a jump in the input buffer
    if (is_on_floor() and Input.is_action_just_pressed("jump")) or (
        is_on_floor() and "jump" in input_buffer):
        velocity = velocity.slide(gravity_direction) + JUMP_VELOCITY * gravity_direction
    # buffer the input
    elif Input.is_action_just_pressed("jump"):
        add_to_input_buffer("jump")
    # HACK: this makes the input buffer duration based on physics ticks/sec
    else:
        add_to_input_buffer("")
    # start falling when jump is released
    if (Input.is_action_just_released("jump")
        and velocity.dot(gravity_direction) < 0.0):
        velocity = velocity.slide(gravity_direction)

    air_friction = lerp(MAX_AIR_FRICTION,
                                   AIR_FRICTION,
                                   clamp(velocity.slide(gravity_direction).length() / FRICTION_CAP,
                                   0, 1))
    velocity -= velocity.slide(gravity_direction) * (
                FRICTION if is_on_floor() else air_friction)
    # TODO: rework this shit
    #       I might've forgotten deltas in movement code
    var direction := Input.get_axis("move_left", "move_right")
    if direction:
        velocity = velocity.move_toward(direction * right_vec * SPEED_CAP_H + velocity.slide(right_vec), ACCEL)

    # needed for godot's internal physics stuff
    # WARN: maybe need to update this when attached
    up_direction = -gravity_direction
    move_and_slide()


func _process(delta: float) -> void:
    pass
