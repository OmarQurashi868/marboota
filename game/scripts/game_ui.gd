extends Panel

var min_score_str_global: String
var max_score_str_global: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventManager.YOURTRUMPCALL_received.connect(_on_yourtrumpcall)
	EventManager.TRUMPCALL_received.connect(_on_trumpcall)

func _on_yourtrumpcall(min_score_str: String, max_score_str: String) -> void:
	Globals.sfx.play("YourTurnSfx")
	min_score_str_global = min_score_str
	max_score_str_global = max_score_str
	var min_score := int(min_score_str)
	var max_score := int(max_score_str)
	var buttons := get_node("VBoxContainer/HBoxContainer").get_children()
	for button in buttons:
		button.disabled = true
	for i in range(min_score - 7, max_score + 1 - 7):
		buttons[i].disabled = false
	show()

func _on_trumpcall(user_id: String, score_str: String) -> void:
	var player := Globals.player_manager.get_player_by_id(user_id)
	var panel := player.hand.score
	var label := panel.get_node("Label") as Label
	label.text = score_str


func _on_trump_button_up(score: String) -> void:
	var player := Globals.my_player
	var panel := player.hand.score
	var label := panel.get_node("Label") as Label
	label.text = score
	EventManager.send_request(
		EventManager.trumpcall_request(score),
		func(error: String) -> void:
			print_debug(error)
			_on_yourtrumpcall(min_score_str_global, max_score_str_global)
	)
	hide()
