class_name PropNode
extends Sprite2D

const TYPE_BOMB = 0

const TYPE_HAT = 1

const TYPE_MASTER = 2

const TYPE_STAR = 3

const TYPE_TANK = 4

const TYPE_TIMER = 5

## 道具类型
var prop_type: int = TYPE_HAT

## 道具得分
var prop_score: int = 100

func _ready() -> void:
	match prop_type:
		TYPE_BOMB:
			prop_score = 500
			self.texture = load('res://assets/images/prop_bomb.png')
		TYPE_HAT:
			prop_score = 100
			self.texture = load('res://assets/images/prop_hat.png')
		TYPE_MASTER:
			prop_score = 200
			self.texture = load('res://assets/images/prop_master.png')
		TYPE_STAR:
			prop_score = 200
			self.texture = load('res://assets/images/prop_star.png')
		TYPE_TANK:
			prop_score = 200
			self.texture = load('res://assets/images/prop_tank.png')
		TYPE_TIMER:
			prop_score = 100
			self.texture = load('res://assets/images/prop_timer.png')
