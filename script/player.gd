extends CharacterBody2D
class_name Player


# TODO: investigate flickering after rotations
const EPSILON          = 1e-3
const SPEED            = 200.0
const ACCEL            = 35.0
const AIR_ACCEL        = 30.0
const SPEED_CAP_H      = 150.0
const SPEED_CAP_V      = 10000.0
const FRICTION_CAP     = 600.0
const JUMP_VELOCITY    = -300.0
const LERP_SPEED       = 12.0
const INPUT_BUFFER     = 10
const POS_BUFFER_SIZE  = 3
const FRICTION         = 0.2
const AIR_FRICTION     = 0.01
const MAX_AIR_FRICTION = 0.3
var bounced          : bool # HACK:
var gravity_direction: Vector2
var right_vec        : Vector2
var attached         : bool
var attached_to      : Rotator
var input_buffer     : Array[String]
var air_friction     : float
var respawn_location : Vector2
var position_buffer  : Array[Vector2]
var gear_sprite      : AnimatedSprite2D
var interactable     : Interactable


func _ready() -> void:
    gravity_direction = Vector2(0, 1)
    right_vec = Vector2(1, 0)
    input_buffer = []
    position_buffer = []
    gear_sprite = $GearSprite
    $GearSprite.call_deferred("reparent", get_parent())
    gear_sprite.play("default")
    bounced = false


func add_to_position_buffer(pos: Vector2):
    position_buffer.push_front(pos)
    while position_buffer.size() > POS_BUFFER_SIZE:
        position_buffer.pop_back()


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


func die() -> void:
    set_deferred("position", respawn_location)
    gear_sprite.set_deferred("position", position)


func interact() -> void:
    if not interactable:
        return
    if interactable is Rotator:
        attached = !attached
        attached_to = interactable as Rotator
    interactable._interact(self)


func is_falling() -> bool:
    return velocity.dot(gravity_direction) > 0.0


func _physics_process(delta: float) -> void:
    if is_falling(): bounced = false

    add_to_position_buffer(position)
    rotation = lerp_angle(rotation, gravity_direction.angle() - PI/2,
                          LERP_SPEED * delta)
    # HACK:?
    if rotation < EPSILON and rotation > 0 or rotation > -EPSILON and rotation < 0:
        rotation = 0
    if position_buffer.size() >= POS_BUFFER_SIZE:
        gear_sprite.set_deferred("position", position_buffer[POS_BUFFER_SIZE - 1])
    else:
        gear_sprite.set_deferred("position", position)

    if Input.is_action_just_pressed("interact"):
        interact()


    if attached:
        position = position.lerp(attached_to.position, LERP_SPEED * delta)
        velocity = Vector2.ZERO
        if Input.is_action_just_pressed("move_right"):
            attached_to.right_action()
        elif Input.is_action_just_pressed("move_left"):
            attached_to.left_action()
        return

    debug_inputs()
    right_vec = gravity_direction.orthogonal()

    if not is_on_floor():
        if $PlayerSprite.animation != "jump":
            $PlayerSprite.play("jump")
        velocity += (get_gravity().length() * gravity_direction) * delta


    # slide returns a vector which has only has the component of the starting vector that is perpendicular to the argument
    # also jumps if there's a jump in the input buffer
    if (is_on_floor() and (Input.is_action_just_pressed("jump")
                           or "jump" in input_buffer)):
        velocity = velocity.slide(gravity_direction) + JUMP_VELOCITY * gravity_direction
    # buffer the input
    elif Input.is_action_just_pressed("jump"):
        add_to_input_buffer("jump")
    # HACK: this makes the input buffer duration based on physics ticks/sec
    else:
        add_to_input_buffer("")

    # start falling when jump is released
    if (!is_on_floor() and !Input.is_action_pressed("jump") and
        !is_falling()  and !bounced):
        velocity = (velocity.slide(right_vec) * 0.25 +
                    velocity.slide(gravity_direction))

    # TODO:? scale air friction based on speed (not working rn)
    air_friction = lerp(MAX_AIR_FRICTION,
                        AIR_FRICTION,
                        clamp(velocity.slide(gravity_direction).length() / FRICTION_CAP,
                        0, 1))
    velocity -= velocity.slide(gravity_direction) * (
                FRICTION if is_on_floor() else air_friction)
    # TODO:? rework this shit
    #       I might've forgotten deltas in movement code
    var direction := Input.get_axis("move_left", "move_right")
    if direction:
        velocity = velocity.move_toward(direction * right_vec * SPEED_CAP_H + velocity.slide(right_vec), ACCEL)
        if direction < 0:
            $PlayerSprite.flip_h = false
        else:
            $PlayerSprite.flip_h = true
        if $PlayerSprite.animation == "idle" and is_on_floor():
            $PlayerSprite.play("start_walk")
        if $PlayerSprite.animation == "jump" and is_on_floor():
            $PlayerSprite.play("walk")
    elif is_on_floor():
        $PlayerSprite.play("idle")

    # needed for godot's internal physics stuff
    # WARN: maybe need to update this when attached
    up_direction = -gravity_direction
    move_and_slide()


# func _process(delta: float) -> void:
#     pass


func _on_player_sprite_animation_finished() -> void:
    if $PlayerSprite.animation == "start_walk":
        $PlayerSprite.play("walk")


func _on_interact_area_area_entered(area: Area2D) -> void:
    interactable = area


func _on_interact_area_area_exited(area: Area2D) -> void:
    if interactable == area:
        interactable = null


# handle obstacle collisions
func _on_collisions_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
    if body is not TileMapLayer:
        push_error("`Player/Collisions` collided with something that is not a tile")
        return
    var tile_map := body as TileMapLayer
    print(tile_map)
    var cell_coords := tile_map.get_coords_for_body_rid(body_rid)
    var cell_data := tile_map.get_cell_tile_data(cell_coords)
    assert(cell_data.has_custom_data("type"), "Cell at %s collided but doesn't have custom data!" % cell_coords)
    match cell_data.get_custom_data("type"):
        "spike":
            die()
        "spring":
            if is_falling():
                set_deferred("bounced", true)
                set_deferred("velocity", -velocity.slide(right_vec) * 1.2 +
                                          velocity.slide(gravity_direction))
        _:
            push_error("Undefined behaviour for collided object")
