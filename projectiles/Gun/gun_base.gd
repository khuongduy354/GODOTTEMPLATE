extends "res://Items/item.gd"
class_name Gun


@export var BulletScene:PackedScene
var shoot_dir = Vector2.RIGHT
#@export var angle_variance=2.0
#@export var pos_variance =2.0
@export var fire_cooldown = 0.1
@onready var s_pos=$shoot_pos
var rng = RandomNumberGenerator.new()
func _ready():
	$fire_rate.wait_time = fire_cooldown
func _physics_process(delta):
	if Input.is_action_pressed("shoot"): 
		shoot()
func shoot(): 
	if !$fire_rate.is_stopped(): 
		return
	var bullet:Bullet = BulletScene.instantiate() 
	
#	shoot_dir=shoot_dir.rotated(deg_to_rad(rng.randf_range(-angle_variance,angle_variance)))
	shoot_dir = global_position.direction_to($shoot_pos.global_position)
	
	bullet.set_veloc(shoot_dir)
	
	get_tree().root.add_child(bullet)
#	var offset_pos = pos_variance
#	if rng.randi()%2 == 0:
#		offset_pos = -pos_variance
		
	bullet.global_position =  s_pos.global_position
	$fire_rate.start()
	if get_node("AnimationPlayer"):
		$AnimationPlayer.play("shoot_explode")
	return bullet 
