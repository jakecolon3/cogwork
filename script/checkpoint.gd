extends Area2D

## Possible gravity respawn directions
enum RespawnGravityDirections {
    DOWN  = 0,
    UP    = 1,
    LEFT  = 2,
    RIGHT = 3
}

## The gravity direction that the player will respawn with.
@export var respawn_gravity_direction: RespawnGravityDirections


func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        var player = body as Player
        player.respawn_location = global_position
        match respawn_gravity_direction:
            RespawnGravityDirections.DOWN:
                player.respawn_gravity = Player.GRAVITY_DOWN
            RespawnGravityDirections.UP:
                player.respawn_gravity = Player.GRAVITY_UP
            RespawnGravityDirections.LEFT:
                player.respawn_gravity = Player.GRAVITY_LEFT
            RespawnGravityDirections.RIGHT:
                player.respawn_gravity = Player.GRAVITY_RIGHT
