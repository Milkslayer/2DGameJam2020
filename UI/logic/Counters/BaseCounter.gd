extends NinePatchRect


onready var count_label = $CountLabel

var status_text = "0"
var max_val:int

func _ready():
	pass # Replace with function body.


func _initialize(max_value:int):
	self.max_val = max_value
	self.status_text = str(self.max_val)

func _update_counter(new_value:int):
	self.status_text = str(new_value)
	count_label.text = self.status_text

