extends Node2D
class_name HealthComponent

signal out_of_health
signal health_changed(new_health)

@export var max_health = 1000
@onready var current_health = max_health: set= set_health

func set_health(new_health): 
	current_health = new_health
	emit_signal("health_changed",current_health)

func replenish(): 
	current_health = max_health


func _receive_hit(hitbox:Hitbox): 
	current_health-=hitbox.damage
	if current_health < 0: 
		emit_signal("out_of_health") 
	
