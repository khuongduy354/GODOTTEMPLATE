extends CanvasLayer

@onready var inventory = $MarginContainer/Inventory 
@onready var hotbar = $Hotbar

func _ready():
	inventory.connect("equip_item",Callable(self,"_on_equip_item"))
	hotbar.connect("out_hotbar",Callable(self,"_out_hotbar"))
func _out_hotbar(item:UIItem): 
	inventory.unequip(item) #TODO 
	
func _on_equip_item(item:UIItem): 
	hotbar.load_from_inventory(item)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("inventory_toggle"): 
		inventory.visible = !inventory.visible
	
