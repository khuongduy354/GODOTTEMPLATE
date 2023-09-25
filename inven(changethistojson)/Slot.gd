extends VBoxContainer
class_name Slot
var item:UIItem = null
signal equip_item(ui_item)
var equipped =false

func _ready(): 
	$Button.connect("pressed",Callable(self,"_on_button_pressed"))
	for child in get_children(): 
		if child is UIItem: 
			item = child

func _on_button_pressed():
	if equipped: 
		print("equipped")
		return
	equip_item.emit(item)
	equipped=true
