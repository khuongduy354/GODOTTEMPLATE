extends TextureRect
class_name UIItem
signal _set_active(item:Item)

@export var item_type:Global.item_type
@export var item_name:Global.item_name 
var is_active =false
var real_item = null

func load_item(_type:String, _name):
	var path = "res://Items/"+_type+"/"+_name+".tscn"
	var node = load(path).instantiate() 
func set_active(): 
	var item = Global.load_real_item(item_type,item_name) 
	if real_item: 
		item = real_item
	else: 
		real_item = item
	Events.active_item.emit(item)

func set_inactive(): 
	if real_item: 
		Events.inactive_item.emit(real_item)
