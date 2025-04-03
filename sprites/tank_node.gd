## 坦克精灵
class_name TankNode
extends CharacterBody2D

## 最小边界
@export
var boundary_min: Vector2 = Vector2.ZERO

## 最大边界
@export
var boundary_max: Vector2 = Vector2(100, 100)

## 坦克类型
@export
var role: int = TankRoleType.Hero

## 坦克速度
@export
var speed: float = 160

## 坦克抗击数
@export
var hits_of_received: int = 1

## 方向合集
var directions := {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}

## 当前的方向
@export
var current_direction := Vector2.DOWN

## 上次发射子弹的时间
var _shoot_time: float = 0.0

## 移动用的Timer对象
var _move_timer: Timer = Timer.new()

## 坦克帧集合
var _tank_sprite_frames: Dictionary = {}

## 子弹预制体
@onready
var _tank_bullet_prefab = preload("res://sprites/bullet_node.scn")

## 准备方法
func _ready() -> void:
	_initialize() #初始化
	if role != TankRoleType.Hero:
		_add_auto_move_timer()
		self.collision_layer = CollisionLayer.EnemyTank
	else:
		self.collision_layer = CollisionLayer.HeroTank
	self._show_born_effect() #显示出生特效

## 初始化
func _initialize():
	var tank_sprite_sheet = TankRoleType\
		.get_role_sprite_sheet(role)
	_tank_sprite_frames = \
		_get_sprite_frames(tank_sprite_sheet)
	self.change_direction(directions.keys()[0]) #设置初始方向

## 处理每帧的事件
func _process(delta: float) -> void:
	if role == TankRoleType.Hero:
		handle_input(delta)
	else:
		self._safe_move(delta, current_direction)
		# 限制运动范围，只能在世界范围内
	var offset_tank = Vector2(Constants.WarMapTiledSize, Constants.WarMapTiledSize)
	position = position.clamp(boundary_min + offset_tank, boundary_max - offset_tank)

## 处理输入事件
func handle_input(delta: float):
	## 处理移动
	for action in directions.keys():
		if Input.is_action_pressed(action):
			var new_dir = directions[action]
			if new_dir != current_direction:
				change_direction(action)
			else:
				self._safe_move(delta, new_dir)
		else:
			velocity = Vector2.ZERO
	## 处理发射子弹
	if Input.is_action_pressed("ui_shoot"):
		if _shoot_time < 0.4:
			_shoot_time += delta #计算发射时间
			return
		_shoot_time = 0.0
		self.shoot() #发射子弹

## 设置坦克方向
func change_direction(dir_key: String):
	$TankSprite.texture = _tank_sprite_frames[dir_key]
	current_direction = directions[dir_key]
	# 立即检测新方向是否可行
	if has_collision_in_direction(current_direction):
		velocity = Vector2.ZERO

# 碰撞预检测
func has_collision_in_direction(dir: Vector2) -> bool:
	var params = PhysicsTestMotionParameters2D.new()
	params.from = global_transform
	params.motion = dir * ($TankCollisionShape.shape\
		.get_rect().size.x / 2 + 2)
	return PhysicsServer2D.body_test_motion(get_rid(), params)

# 防卡墙增强逻辑
func _safe_move(delta: float, direction: Vector2):
	var target_velocity = direction * speed
	if move_and_collide(target_velocity * delta, true):
		return
	move_and_collide(target_velocity * delta)

## 退出树节点事件
func _exit_tree() -> void:
	if role != TankRoleType.Hero:
		_remove_auto_move_timer()

## 添加自动移动的定时器
func _add_auto_move_timer():
	add_child(_move_timer)
	_move_timer.wait_time = 1
	_move_timer.one_shot = false
	_move_timer.start()
	_move_timer.timeout.connect(_change_direction_by_timer)

## 删除自动移动的定时器
func _remove_auto_move_timer():
	if _move_timer != null:
		if not _move_timer.is_stopped():
			_move_timer.stop()
		remove_child(_move_timer)
	_move_timer = null

## 通过定时器的智能移动
func _change_direction_by_timer():
	var rand_int = randi() % 4
	var dirs = directions.keys()
	self.change_direction(dirs[rand_int])
	shoot() ## 发送子弹

## 发送子弹
func shoot():
	var bullet = _tank_bullet_prefab.instantiate()
	bullet.owner_role = role
	bullet.current_direction = current_direction.normalized()
	bullet.position = position + \
		bullet.current_direction * Constants.WarMapTiledSize
	get_parent().add_child(bullet)

## 显示出生特效
func _show_born_effect():
	$TankSprite.visible = false
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("Born")
	$AnimatedSprite2D.animation_finished\
		.connect(func(): \
			$AnimatedSprite2D.visible = false; \
			$TankSprite.visible = true)

## 显示爆炸特效
func _show_bomb_effect():
	$TankCollisionShape\
		.set_deferred(&"disabled", true)
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("Bomb")
	$AnimatedSprite2D.animation_finished\
		.connect(func(): free())

## 获取精灵帧
func _get_sprite_frames(sprite_sheet: Resource):
	var sprite_frames: Dictionary = {}
	var dirs = directions.keys()
	for i in range(0, 4):
		var atlas = AtlasTexture.new()
		atlas.atlas = sprite_sheet
		atlas.region = Rect2(i * 32, 0, 32, 32)
		sprite_frames[dirs[i]] = atlas
	return sprite_frames
