extends Node
class_name SfxManager

var sfx_collection: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.sfx = self
	for sfx in get_children():
		sfx_collection[sfx.name] = sfx

func play(sfx_name: String) -> void:
	sfx_collection[sfx_name].play()
