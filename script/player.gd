extends CharacterBody2D
class_name Player

signal player_died
signal level_complete


# TODO: investigate flickering after rotations
# TODO: coyote time
const EPSILON          = 1e-3
const SPEED            = 200.0
const ACCEL            = 3000.0
const AIR_ACCEL        = 30.0
const SPEED_CAP_H      = 150.0
const SPEED_CAP_V      = 800.0
const FRICTION_CAP     = 600.0
const JUMP_VELOCITY    = -320.0
const LERP_SPEED       = 12.0
const INPUT_BUFFER     = 10
const POS_BUFFER_SIZE  = 3
const FRICTION         = 0.2
const AIR_FRICTION     = 0.08
const MAX_AIR_FRICTION = 0.3
const GRAVITY_DOWN     = Vector2(0, 1)
const GRAVITY_UP       = Vector2(0, -1)
const GRAVITY_LEFT     = Vector2(-1, 0)
const GRAVITY_RIGHT    = Vector2(1, 0)
const MAX_BOUNCES      = 5
var bounced          : bool # HACK:
var bounce_count     : int
var gravity_direction: Vector2
var right_vec        : Vector2
var attached         : bool
var attached_to      : Rotator
var input_buffer     : Array[String]
var air_friction     : float
var respawn_location : Vector2
var respawn_gravity  : Vector2
var position_buffer  : Array[Vector2]
var gear_sprite      : AnimatedSprite2D
var interactable     : Interactable


func _ready() -> void:
    gravity_direction = GRAVITY_DOWN
    respawn_gravity = gravity_direction
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


# TODO: remove
func debug_inputs() -> void:
    if Input.is_action_just_pressed("debug_1"):
        gravity_direction = Vector2(0, 1)
    if Input.is_action_just_pressed("debug_2"):
        gravity_direction = Vector2(0, -1)
    if Input.is_action_just_pressed("debug_3"):
        gravity_direction = Vector2(1, 0)
    if Input.is_action_just_pressed("debug_4"):
        gravity_direction = Vector2(-1, 0)


func respawn() -> void:
    if attached_to:
        attached_to.detach()
    set_deferred("attached", false)
    set_deferred("attached_to", null)
    set_deferred("position", respawn_location)
    set_deferred("velocity", Vector2.ZERO)
    set_deferred("gravity_direction", respawn_gravity)
    gear_sprite.set_deferred("position", position)


func die() -> void:
    player_died.emit()
    get_tree().paused = true


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
    if is_falling():
        bounced = false

    add_to_position_buffer(position)
    rotation = lerp_angle(rotation, gravity_direction.angle() - PI/2,
                          LERP_SPEED * delta)
    # HACK:?
    if rotation < EPSILON and rotation > 0 or rotation > -EPSILON and rotation < 0:
        rotation = 0

    # make gear follow
    if position_buffer.size() >= POS_BUFFER_SIZE:
        gear_sprite.set_deferred("position", position_buffer[POS_BUFFER_SIZE - 1])
    else:
        gear_sprite.set_deferred("position", position)

    if Input.is_action_just_pressed("interact"):
        interact()


    if attached:
        if $PlayerSprite.animation != "rotator" and $PlayerSprite.animation != "attached":
            $PlayerSprite.play("rotator")
        position = position.lerp(attached_to.position, LERP_SPEED * delta)
        velocity = Vector2.ZERO
        if Input.is_action_just_pressed("move_right"):
            attached_to.right_action()
        elif Input.is_action_just_pressed("move_left"):
            attached_to.left_action()

        gear_sprite.set_deferred("position",
                                 lerp(gear_sprite.position,
                                      attached_to.position + Vector2(-1, 4).rotated(attached_to.rotation),
                                      LERP_SPEED * delta))
        gear_sprite.set_deferred("rotation",
                                 lerp_angle(gear_sprite.rotation,
                                            attached_to.rotation,
                                            LERP_SPEED * delta))
        if gear_sprite.animation != "rotator":
            gear_sprite.play("rotator")
        return
    else:
        if gear_sprite.animation != "default":
            gear_sprite.play("default")

    $PlayerSprite.show()
    debug_inputs()
    right_vec = gravity_direction.orthogonal()

    if not is_on_floor():
        if $PlayerSprite.animation != "jump":
            $PlayerSprite.play("jump")
        # if going down and over limit: don't add gravity
        # if going down and under limit: add gravity
        if (velocity.slide(right_vec).length() < SPEED_CAP_V or
            velocity.slide(right_vec).dot(gravity_direction) < 0):
            velocity += (get_gravity().length() * gravity_direction) * delta
    else:
        bounce_count = 0


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
        bounced = true
        velocity = (velocity.slide(right_vec) * 0.25 +
                    velocity.slide(gravity_direction))

    # TODO:? scale air friction based on speed (not working rn)
    # air_friction = lerp(MAX_AIR_FRICTION,
    #                     AIR_FRICTION,
    #                     clamp(velocity.slide(gravity_direction).length() / FRICTION_CAP,
    #                     0, 1))
    velocity -= velocity.slide(gravity_direction) * (
                FRICTION if is_on_floor() else AIR_FRICTION)
    # TODO:? rework this shit
    #       I might've forgotten deltas in movement code
    var direction := Input.get_axis("move_left", "move_right")
    if direction:
        velocity = velocity.move_toward(direction * right_vec * SPEED_CAP_H + velocity.slide(right_vec), ACCEL * delta)
        if direction < 0:
            $PlayerSprite.flip_h = false
        else:
            $PlayerSprite.flip_h = true
        if $PlayerSprite.animation == "idle" and is_on_floor() and (
            Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
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
    if $PlayerSprite.animation == "rotator" and $PlayerSprite.frame != 0:
        if $PlayerSprite.frame != 11:
            $PlayerSprite.play_backwards("rotator")
        else:
            $PlayerSprite.hide()


func _on_interact_area_area_entered(area: Area2D) -> void:
    interactable = area
    var area_interactable := area as Interactable
    area_interactable.show_popup()


func _on_interact_area_area_exited(area: Area2D) -> void:
    (area as Interactable).hide_popup()
    if interactable == area:
        interactable = null


# handle obstacle collisions
func _on_collisions_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
    if body is not TileMapLayer:
        push_error("`Player/Collisions` collided with something that is not a tile")
        return
    var tile_map    := body as TileMapLayer
    var cell_coords := tile_map.get_coords_for_body_rid(body_rid)
    var cell_data   := tile_map.get_cell_tile_data(cell_coords)
    assert(cell_data.has_custom_data("type"), "Cell at %s collided but doesn't have custom data!" % cell_coords)
    match cell_data.get_custom_data("type"):
        "spike":
            die()
        "spring":
            if is_falling():
                set_deferred("bounced", true)
                bounce_count += 1
                set_deferred("velocity",
                             -velocity.slide(right_vec) * get_bounce_multiplier() +
                              velocity.slide(gravity_direction))
        "flag":
            level_complete.emit()
        _:
            push_error("Undefined behaviour for collided object at %s with data %s" % [cell_coords, cell_data])


func get_bounce_multiplier() -> float:
    var weight := clampf(max(bounce_count as float - 1, 0)/MAX_BOUNCES as float, 0, 1.0)
    return lerp(1.3, 0.5, weight)
