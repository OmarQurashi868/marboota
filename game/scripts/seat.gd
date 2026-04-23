extends Node2D
class_name Seat

@export var seat_num := 0
var sitter: Player
@onready var table: Table = get_parent()
@onready var seat_ready_button : Button = $"../ReadyButton"
@onready var seat_leave_button : Button = $"../LeaveButton"
var is_taken := false


func _disable_button() -> void:
	is_taken = true
	$Button.disabled = true

func _enable_button() -> void:
	is_taken = false
	$Button.disabled = false

func seat_player(id: String) -> void:
	var player_manager := Globals.player_manager
	var player := player_manager.get_node(id) as Player

	if player.seat != null:
		var old_seat := player.seat as Seat
		old_seat.unseat_player()

	player_manager.unpin_player(player)
	player_manager.move_player(id, global_position)

	# Change player state depending on game state
	player.state = player_manager.PLAYER_WAITING
	if Globals.table.state == Globals.table.TableState.TABLE_TRUMPING:
		player.state = player_manager.PLAYER_TRUMPING
	if Globals.table.state == Globals.table.TableState.TABLE_PLAYING:
		player.state = player_manager.PLAYER_PLAYING

	player.seat = self

	sitter = player
	_disable_button()

func unseat_player() -> void:
	if sitter != null:
		sitter.unseat()
	
	sitter = null
	_enable_button()


func _on_button_button_up() -> void:
	if Globals.my_player.state != Globals.player_manager.PLAYER_IDLE && Globals.my_player.state != Globals.player_manager.PLAYER_WAITING:
		return
	Globals.sfx.play("SitSfx")
	seat_player(Globals.my_player.id)
	seat_ready_button.show()
	seat_leave_button.show()

	EventManager.send_request(
		EventManager.sit_request(seat_num)
	,func(err: String) -> void:
		var me := Globals.my_player
		seat_ready_button.hide()
		seat_leave_button.hide()
		if sitter == me:
			unseat_player()
		else:
			me.unseat()
		push_error(err)
	)
