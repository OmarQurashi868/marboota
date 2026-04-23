extends Button


func _ready() -> void:
	visible = false
	EventManager.GAMEEND_received.connect(_on_gameend)


func _on_button_up() -> void:
	Globals.sfx.play("ClickSfx")
	var player := Globals.my_player
	var manager := Globals.player_manager
	var seat: Seat = player.seat
	var seat_ready_button: Button = $"../ReadyButton"

	if player.state == manager.PLAYER_READY or player.state == manager.PLAYER_WAITING:
		seat.unseat_player()
		self.hide()
		seat_ready_button.hide()
		seat_ready_button.button_pressed = false
		EventManager.send_request(EventManager.unsit_request()
		,func(error: String) -> void:
			print_debug(error)
			seat.seat_player(player.name)
			self.show()
			seat_ready_button.show()
		)

func _on_gameend(_1: String, _2: String) -> void:
	#button_pressed = false
	pass
