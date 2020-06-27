extends ProgressBar

class_name BaseBar

onready var bar_status = $BarStatus
var status_text = "0/0"
var status_template = "%d/%d"
var max_val:int = 0

func _ready():
	pass # Replace with function body.


func _initialize(max_val:int):
	self.max_val = max_val
	self.status_text = self.status_template % [max_val, max_val]
	self.value = 100
	bar_status.text = status_text

func _update_bar(new_value:int):
	var ratio = (float(new_value) / float(self.max_val)) * 100
	self.value = ratio
	self.status_text = self.status_template % [self.max_val, new_value]
	bar_status.text = status_text
	
