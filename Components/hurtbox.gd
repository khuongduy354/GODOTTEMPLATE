extends Area2D
class_name Hurtbox
signal _hitted
@export var HealthComponent:HealthComponent =null

 

func _ready(): 
	self.connect("area_entered",Callable(self,"_on_area_entered"))

func _on_area_entered(hitbox: Hitbox):
	if hitbox == null or !hitbox.can_dmg:
		return
	if HealthComponent: 
		HealthComponent._receive_hit(hitbox)
	hitbox.emit_signal("_damage_dealt")
	emit_signal("_hitted")

