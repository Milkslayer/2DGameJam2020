extends BaseBar


func _initialize(max_val:int):
	._initialize(max_val)
	self.value = 0
	self.status_text = self.status_template % [max_val, 0]
	bar_status.text = self.status_text 


