extends Area2D
class_name Hitbox
signal _damage_dealt
@onready var damage = owner.damage
@export var can_dmg = true

func _ready():
	self.connect("_damage_dealt",Callable(owner,"_damage_dealt"))
