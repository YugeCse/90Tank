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
	# 设置坦克不与自身发生碰撞
	if owner_role == TankRoleType.Hero:
		collision_layer = CollisionLayer.HeroBullet
		collision_mask &= ~CollisionLayer.HeroTank
	else:
		collision_layer = CollisionLayer.EnemyBullet
		collision_mask &= ~CollisionLayer.EnemyTank
	# 判断当坦克的方向为0是，则直接销毁子弹
	if current_direction == Vector2.ZERO:
		free() # 直接释放对象
		return
	# 根据方向的不同，设置不同的子弹图片精灵帧
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
		var parent = collider.get_parent()
		if parent is MapTiledNode: # 如果是地砖节点
			var map_tiled_node = parent as MapTiledNode
			if not map_tiled_node.body: return # 如果没有碰撞体，直接返回
			match map_tiled_node.body.collision_layer:
				CollisionLayer.Wall:
					_show_bomb_effect() # 显示爆炸效果
					collider.get_parent().queue_free() # 碰撞到墙壁，墙壁直接销毁
				CollisionLayer.Grid:
					_show_bomb_effect() # 显示爆炸效果
		elif parent is MasterNode: # 如果是玩家基地节点
			_show_bomb_effect() # 显示爆炸效果
			(parent as MasterNode).set_dead_state()
			GlobalEventBus.emit_signal(&'master_damaged')
	elif collider is CharacterBody2D: # 一般为坦克或者其他子弹
		if collider is TankNode:
			_show_bomb_effect() # 显示爆炸效果
			(collider as TankNode).hurt() # 坦克受伤处理
		elif collider is BulletNode:
			queue_free() # 子弹与子弹碰撞，直接销毁
			collider.queue_free() # 子弹与子弹碰撞，直接销毁
			$AudioManager.play_bullet_crack() # 播放子弹对撞声音

## 设置碰撞矩形大小
func _set_collision_shape(size: Vector2):
	var shape = RectangleShape2D.new()
	shape.size = size
	$CollisionShape2D.shape = shape

###################################
##  方法：显示爆炸特效
##  参数：
##    is_big_bomb: 是否为大炸弹
###################################
func _show_bomb_effect(is_big_bomb: bool = false) -> void:
	if $CollisionShape2D.disabled:
		return #已经是注销状态了，直接返回
	velocity = Vector2.ZERO
	$CollisionShape2D \
		.set_deferred("disabled", true)
	current_state = STATE_BOMB
	remove_child($Sprite2D)
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("bomb_tank" if is_big_bomb else "bomb")
	$AnimatedSprite2D.animation_finished \
		.connect(func(): queue_free())
