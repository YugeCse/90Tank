class_name BulletNode
extends CharacterBody2D

## 常规状态，具有碰撞效果
const STATE_ALIVE = 0

## 爆炸状态，再无碰撞效果
const STATE_BOMB = -1

## 默认常规状态
var current_state: int = STATE_ALIVE

## 移动速度
@export
var speed: float = 200.0

## 子弹所属坦克类型
@export
var owner_role: int

### 子弹帧集合
@export
var bullet_frames: Array[CompressedTexture2D] = []
#
## 子弹方向
var current_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	if owner_role == TankRoleType.Hero:
		collision_layer = CollisionLayer.HeroBullet
	else:
		collision_layer = CollisionLayer.EnemyBullet
	if current_direction == Vector2.ZERO:
		free() # 直接释放对象
		return
	if current_direction == Vector2.UP:
		$Sprite2D.texture = bullet_frames[0]
		self._set_collision_shape(Vector2(4, 5))
	elif current_direction == Vector2.DOWN:
		$Sprite2D.texture = bullet_frames[1]
		self._set_collision_shape(Vector2(4, 5))
	elif current_direction == Vector2.LEFT:
		$Sprite2D.texture = bullet_frames[2]
		self._set_collision_shape(Vector2(5, 4))
	elif current_direction == Vector2.RIGHT:
		$Sprite2D.texture = bullet_frames[3]
		self._set_collision_shape(Vector2(5, 4))
	velocity = current_direction * speed #子弹节点的速度配置

func _process(delta: float) -> void:
	if current_state == STATE_BOMB:
		velocity = Vector2.ZERO
		return
	var collider = move_and_collide(velocity * delta)
	if collider: # 如果有碰撞发生
		collider = collider.get_collider() # 获取碰撞体
		_handle_collision_with(collider)
		return
	# 检查是否与边界发生交集，如果有，直接爆炸
	if position.x <= 2.5 or \
		position.x >= Constants.WarMapSize + 2.5 or \
		position.y <= 2.5 or \
		position.y >= Constants.WarMapSize + 2.5:
		_show_bomb_effect() # 与边界发生交集，直接爆炸

## 处理碰撞逻辑
func _handle_collision_with(collider: Object) -> void:
	if collider is StaticBody2D: # 一般为墙一类的，这里为地砖
		var mapTiledNode = collider.get_parent() as MapTiledNode
		if not mapTiledNode.body: return # 如果没有碰撞体，直接返回
		match mapTiledNode.body.collision_layer:
			CollisionLayer.Wall:
				_show_bomb_effect() # 显示爆炸效果
				collider.get_parent().queue_free() # 碰撞到墙壁，墙壁直接销毁
			CollisionLayer.Grid:
				_show_bomb_effect() # 显示爆炸效果
	elif collider is CharacterBody2D: # 一般为坦克或者其他子弹
		if collider is TankNode:
			print('与坦克发生碰撞')
			_show_bomb_effect() #显示爆炸效果
		elif collider is BulletNode:
			print('与子弹发生碰撞')
			queue_free() # 子弹与子弹碰撞，直接销毁
			collider.queue_free() # 子弹与子弹碰撞，直接销毁

## 设置碰撞矩形大小
func _set_collision_shape(size: Vector2):
	var shape = RectangleShape2D.new()
	shape.size = size
	$CollisionShape2D.shape = shape

###################################
# 方法：显示爆炸特效
# 参数：
#   is_big_bomb: 是否为大炸弹
###################################
func _show_bomb_effect(is_big_bomb: bool = false) -> void:
	velocity = Vector2.ZERO
	$CollisionShape2D \
		.set_deferred("disabled", true)
	current_state = STATE_BOMB
	remove_child($Sprite2D)
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("bom_tank" if is_big_bomb else "bomb")
	$AnimatedSprite2D.animation_finished \
		.connect(func(): queue_free())
