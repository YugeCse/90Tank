## 玩家基地节点
class_name MasterNode
extends Sprite2D

## 被摧毁状态
const STATE_DEAD = 0

## 活着状态
const STATE_ALIVE = 1

## 当前的状态
var current_state: int = MasterNode.STATE_ALIVE

func _ready() -> void:
	self.set_alive_state()

## 设置基地存活状态
func set_alive_state():
	if current_state != MasterNode.STATE_ALIVE:
		current_state = MasterNode.STATE_ALIVE
	texture = load('res://assets/images/master_alive.png')

## 设置被摧毁后的状态
func set_dead_state():
	$StaticBody2D/CollisionShape2D\
		.set_deferred('disabled', true)
	if current_state != MasterNode.STATE_DEAD:
		current_state = MasterNode.STATE_DEAD
	texture = load("res://assets/images/master_dead.png")
