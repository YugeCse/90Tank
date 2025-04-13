## 道具节点
class_name PropNode
extends Sprite2D

## 炸弹道具
const TYPE_BOMB = 0

## 帽子道具
const TYPE_HAT = 1

## 金砖基地的道具
const TYPE_MASTER = 2

## 五角星道具，达到3颗星可以消除草地
const TYPE_STAR = 3

## 增加玩家人数的道具
const TYPE_TANK = 4

## 定时器道具
const TYPE_TIMER = 5

## 道具类型
var prop_type: int = TYPE_HAT

## 道具得分
var prop_score: int = 100

## 闪烁动画对象
var blink_tween: Tween

func _ready() -> void:
	self._initialize()
	self._start_blink()

## 初始化
func _initialize():
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

## 开始闪烁
func _start_blink():
	blink_tween = create_tween().set_loops()
	blink_tween.tween_property(self, "modulate:a", 0, 0.3)
	blink_tween.tween_property(self, "modulate:a", 1.0, 0.3)

## 停止闪烁
func _stop_blink():
	blink_tween.kill()

## 停止闪烁
func _exit_tree() -> void:
	self._stop_blink()

## 显示分数然后注销
func show_score_then_dispose():
	if blink_tween and blink_tween.is_running():
		_stop_blink()
		self.set_deferred(&'mudulate', Color(1, 1, 1, 1))
	$StaticBody2D/CollisionShape2D.set_deferred('disabled', true)
	self.texture = load('res://assets/images/score_%d.png' % [prop_score])
	await get_tree().create_timer(1.2).timeout
	queue_free() # 从树节点中删除
