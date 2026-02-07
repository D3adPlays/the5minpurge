extends CharacterBody2D

const speed: float = 150.0

var target = null

func _ready():
  await get_tree().process_frame
  target = get_player()
  $AnimatedSprite2D.play("walk")

func get_player() -> Node2D:
 if not is_inside_tree():
  return null
 var players = get_tree().get_nodes_in_group("player")
 if players.size() > 0:
  return players[0] as Node2D	
 return null

func _physics_process(delta):
 if target == null:
  return
 var dir = (target.global_position - global_position).normalized()
 velocity = dir * speed
 move_and_slide()
