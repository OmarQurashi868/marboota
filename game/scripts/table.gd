extends Node2D
class_name Table

enum TableState {TABLE_IDLE, TABLE_READY, TABLE_TRUMPING, TABLE_PLAYING}
var state: TableState = TableState.TABLE_IDLE
var play_started := false

func _ready() -> void:
	Globals.table = self
	EventManager.GAMESTART_received.connect(_on_gamestart)
	EventManager.TRUMPSTART_received.connect(_on_trumpstart)
	EventManager.PLAYSTART_received.connect(_on_playstart)
	EventManager.YOURPLAY_received.connect(_on_yourplay)
	EventManager.PLAY_received.connect(_on_play)
	EventManager.PLAYEND_received.connect(_on_playend)
	EventManager.ROUNDEND_received.connect(_on_roundend)
	EventManager.GAMEEND_received.connect(_on_gameend)

func _on_gamestart() -> void:
	Globals.sfx.play("GameStartSfx")
	state = TableState.TABLE_READY
	rotate_table()
	for i in range(4):
		var score := get_node("Score" + str(i))
		
		if i == 0:
			if Globals.my_player.state > Globals.player_manager.PLAYER_IDLE:
				score.position = Vector2(-51, 303)
			else:
				score.position = Vector2(92, 249)

		score.show()
	if Globals.my_player.state > Globals.player_manager.PLAYER_IDLE:
		var leaveButton := $"LeaveButton"
		leaveButton.hide()

		var readyButton := $"ReadyButton"
		readyButton.hide()

		Globals.my_player.hide()
		Globals.my_player.seat.hide()
		Globals.my_player.hand.scale = Vector2(1, 1)
		Globals.my_player.hand.position.y = 260


func _on_trumpstart() -> void:
	Globals.sfx.play("ShuffleSfx")
	play_started = false
	state = TableState.TABLE_TRUMPING
	for i in range(4):
		var score := get_node("Score" + str(i))
		score.get_node("Label").text = ""
		score.show()
	for i in range(4):
		var seat := get_node("Seat" + str(i)) as Seat
		if seat.sitter:
			seat.sitter.state = Globals.player_manager.PLAYER_TRUMPING

func _on_playstart() -> void:
	state = TableState.TABLE_PLAYING
	for i in range(4):
		var seat := get_node("Seat" + str(i)) as Seat
		if seat.sitter:
			seat.sitter.state = Globals.player_manager.PLAYER_PLAYING

func _on_yourplay(playable: String) -> void:
	Globals.sfx.play("YourTurnSfx")
	Globals.my_player.hand.playable = playable
	
	for cardStr in playable.split(","):
		Globals.my_player.hand.set_playable(cardStr)

func _on_play(user_id: String, card_str: String) -> void:
	Globals.sfx.play("PlaySfx")
	var player := Globals.player_manager.get_node(user_id) as Player
	var hand := player.hand
	if player != Globals.my_player:
		hand.on_play(card_str)

func _on_playend(winner_id: String) -> void:
	#var cards: Array[Card] = []
	var winning_hand := Globals.player_manager.get_player_by_id(winner_id).hand as Hand
	for i in range(4):
		if get_node("CardAnchor" + str(i)).get_child_count() == 0:
			continue

		var card := get_node("CardAnchor" + str(i)).get_child(-1) as Card

		for c in get_node("CardAnchor" + str(i)).get_children():
			if c != card:
				c.queue_free()

		# Show on last play
		var anchor := get_node("../LastAnchor" + str(i))
		for child in anchor.get_children():
			child.queue_free()

		var card_dupe := card.duplicate() as Card
		anchor.add_child(card_dupe)
		card_dupe.position = Vector2.ZERO
		card_dupe.rotation = 0
		card_dupe.is_played = true
		card_dupe.global_position = anchor.global_position
		card_dupe.scale = anchor.scale

		var tween := card.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "global_position", winning_hand.global_position, 0.25)
		tween.parallel().tween_property(card, "rotation", 0, 0.5)
		tween.tween_callback(func() -> void:
			card.queue_free()
		)
	var player := Globals.player_manager.get_player_by_id(winner_id)
	var panel := player.hand.score
	var label := panel.get_node("Label") as Label
	var score := int(label.text)
	score += 1
	label.text = str(score)

func _on_playerscore(user_id: String, score_str: String) -> void:
	var player := Globals.player_manager.get_player_by_id(user_id)
	var panel := player.hand.score
	var label := panel.get_node("Label") as Label
	var score := int(score_str)
	label.text = str(score)
	
func _on_roundend(_team_a_score: String, _team_b_score: String) -> void:
	state = TableState.TABLE_READY
	for i in range(4):
		var seat := get_node("Seat" + str(i)) as Seat
		if seat.sitter:
			seat.sitter.state = Globals.player_manager.PLAYER_READY
	
	# Delete last card play after 3 seconds on roundend
	get_tree().create_timer(3.0).timeout.connect(func() -> void: 
		for i in range(4):
			var anchor := get_node("../LastAnchor" + str(i))
			for child in anchor.get_children():
				child.queue_free()
		)

func _on_gameend(winner_1_id: String, winner_2_id: String) -> void:
	state = TableState.TABLE_IDLE

	un_rotate_table()
		
	if Globals.my_player.state > Globals.player_manager.PLAYER_IDLE:
		var leaveButton := $"LeaveButton"
		leaveButton.show()

		var readyButton := $"ReadyButton"
		readyButton.show()

		Globals.my_player.show()
		Globals.my_player.seat.show()
		Globals.my_player.hand.scale = Vector2(0.30, 0.30)
		Globals.my_player.hand.position.y = 225
	
	for i in range(4):
		var score := get_node("Score" + str(i))
		score.get_node("Label").text = ""
		score.hide()
		var seat := get_node("Seat" + str(i)) as Seat
		if seat.sitter:
			seat.sitter.state = Globals.player_manager.PLAYER_IDLE

func rotate_four_values(values: Array, offset: int) -> Array:
	offset = offset % 4  # Keep it within 0-3
	return values.slice(4 - offset, 4) + values.slice(0, 4 - offset)

func rotate_table() -> void:
	var _offset := 0
	if Globals.my_player.state > Globals.player_manager.PLAYER_IDLE:
		_offset = 4 - Globals.my_player.seat.seat_num
	var scores: Array[String] = []
	var cards: Array[Card] = []

	for i in range(4):
		var next_anchor_str := "Anchor" + str((i + _offset) % 4)
		var next_anchor := get_node(next_anchor_str) as Node2D

		var current_seat_str := "Seat" + str(i)
		var current_seat := get_node(current_seat_str) as Seat

		current_seat.global_position = next_anchor.global_position

		var score: Label = get_node("Hand" + str(i)).score.get_node("Label")
		var card_anchor := get_node("CardAnchor" + str(i))
		# var next_score: Label = get_node("Hand" + str((i + _offset) % 4)).score.get_node("Label")

		# Rotate score labels
		scores.append(score.text)
		# Rotate cards
		if card_anchor.get_child_count() > 0:
			var card: Card = card_anchor.get_child(-1)
			cards.append(card)
		else:
			cards.append(null)
		# if i == 0:
		# 	tmp_score = next_score.text
		# 	next_score.text = cur_score.text
		# elif i != 3:
		# 	next_score.text = cur_score.text
		# else:
		# 	next_score.text = tmp_score
		
		
		if current_seat.sitter:
			current_seat.sitter.global_position = current_seat.global_position
			var hand_str := "Hand" + str((i + _offset) % 4)
			var hand := get_node(hand_str) as Hand
			current_seat.sitter.hand = hand
			hand.player = current_seat.sitter
			if current_seat.sitter == Globals.my_player:
				hand.is_mine = true
				Globals.my_player.hand = hand
				hand.player = Globals.my_player
	
	for i in range(4):
		var new_index := (i - _offset) % 4

		var score: Label = get_node("Hand" + str(i)).score.get_node("Label")
		score.text = scores[new_index]

		if cards[new_index]:
			var card_anchor: Node2D = get_node("CardAnchor" + str(i))
			cards[new_index].reparent(card_anchor)
			cards[new_index].global_position = card_anchor.global_position
			cards[new_index].global_rotation = card_anchor.global_rotation

func un_rotate_table() -> void:
	for i in range(4):
		var current_seat_str := "Seat" + str(i)
		var current_seat := get_node(current_seat_str) as Seat

		var anchor_str := "Anchor" + str(i)
		var anchor := get_node(anchor_str) as Node2D

		current_seat.global_position = anchor.global_position

		if current_seat.sitter:
			current_seat.sitter.global_position = current_seat.global_position
