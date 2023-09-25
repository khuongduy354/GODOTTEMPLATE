extends CharacterBody2D
class_name Bullet

signal dealt_damage
@export var BULLET_SPEED = 1000
@export var damage = 30

var veloc = Vector2.ZERO
func _ready():
#	$Hitbox.connect("body_entered",Callable(self,"_on_hitbox_body_entered"))
#	$VisibleOnScreenEnabler2D.connect("screen_exited",Callable(self,"_on_visible_on_screen_enabler_2d_screen_exited"))
	set_as_top_level(true)
func _physics_process(delta):
	move_and_collide(veloc*delta)
	
func _damage_dealt(): 
	self.queue_free()
	emit_signal("dealt_damage")
	
	
func set_veloc(dir:Vector2): 
	dir = dir.normalized()
	veloc = dir * BULLET_SPEED
	look_at(self.global_position+dir)  


#func _on_hitbox_body_entered(body):
#	if body.name=="Forest": 
#		print("hi")
#		_damage_dealt()


#func _on_visible_on_screen_enabler_2d_screen_exited():
#	print("free bullet")
#	queue_free()
