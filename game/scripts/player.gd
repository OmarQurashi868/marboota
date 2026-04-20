extends Node2D
class_name Player

var username := "Player"
var id := "123"

@onready var manager: PlayerManager = get_parent()
@onready var icon: Sprite2D = $"Cutout/Icon"
# go down one more level and add parent clipping

var state := manager.PLAYER_IDLE
var seat: Seat = null
var hand: Hand = null

func unseat() -> void:
	state = manager.PLAYER_IDLE
	seat = null
	hand = null
	# Move player back to player list
	manager.pin_player(self)
