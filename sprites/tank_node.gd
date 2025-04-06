## 坦克精灵
class_name TankNode
extends CharacterBody2D

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

## 当前的坦克状态
var current_state = TankState.BORN

## 坦克道具库
var props: Array[PropNode] = []

## 是否是红坦克
var is_red_tank: bool = false

## 上次发射子弹的时间
var _shoot_time: float = 0.0

## 保护模式的持续时间，一般为15s
var protect_hold_time: float = 0.0

## 移动用的Timer对象
var _move_timer: Timer = Timer.new()

## 闪烁动画对象
var _red_tank_blink_tween: Tween

## 坦克帧集合
var _tank_sprite_frames: Dictionary = {}

## 最小边界
@export
var boundary_min: Vector2 = Vector2.ZERO

## 最大边界
@export
var boundary_max: Vector2 = Vector2(100, 100)

## 子弹预制体
@onready
var _tank_bullet_prefab = preload("res://sprites/bullet_node.scn")

## 准备方法
func _ready() -> void:
	self._initialize() #初始化
	self._show_born_effect() #显示出生特效

## 初始化
func _initialize():
	if role != TankRoleType.Hero:
		if role == TankRoleType.Enemy3:
			hits_of_received = 3 # 如果是Enemy3，抗击打能力设置为3
		_add_auto_move_timer()
		self.collision_layer = CollisionLayer.EnemyTank
		self.collision_mask &= ~CollisionLayer.EnemyTank
		self.collision_mask &= ~CollisionLayer.EnemyBullet
		if is_red_tank: # 如果是红色坦克
			self._start_blink() # 是红坦克，就开始闪烁
	else:
		self.collision_layer = CollisionLayer.HeroTank
		self.collision_mask &= ~CollisionLayer.HeroBullet
	var tank_sprite_sheet = TankRoleType\
		.get_role_sprite_sheet(role)
	_tank_sprite_frames = \
		_get_sprite_frames(tank_sprite_sheet)
	self.change_direction(directions.keys()[0]) #设置初始方向

## 处理每帧的事件
func _process(delta: float) -> void:
	if current_state == TankState.STRONG:
		protect_hold_time += delta
		if protect_hold_time > 15.0: # 如果是无敌模式，就持续15s，15s后就还原状态
			current_state = TankState.ALIVE
			protect_hold_time = 0.0 # 还原保护特效时间
			if $ProtectedAnimation.is_playing():
				$ProtectedAnimation.stop() # 停止动画输出
			$ProtectedAnimation.visible = false
	if role == TankRoleType.Hero:
		if current_state != TankState.ALIVE and\
			current_state != TankState.STRONG:
			return # 非正常状态，无法移动
		handle_input(delta) # 处理输入事件
	else:
		if current_state != TankState.ALIVE and\
			current_state != TankState.STRONG:
			return # 非正常状态，无法移动，无法发射子弹
		if _shoot_time < 1.0:
			_shoot_time += delta # 每次时间累加
		else:
			shoot() # 发送子弹
			_shoot_time = 0.0 # 还原状态值
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
				# $AudioManager.play_tank_move_sound()
		else:
			velocity = Vector2.ZERO
	## 处理发射子弹
	if Input.is_action_pressed("ui_shoot"):
		if _shoot_time < 0.3:
			_shoot_time += delta #计算发射时间
			return
		_shoot_time = 0.0
		self.shoot() #发射子弹

## 设置坦克方向
func change_direction(dir_key: String):
	current_direction = directions[dir_key]
	$TankSprite.texture = _tank_sprite_frames[dir_key]
	# 立即检测新方向是否可行
	#if has_collision_in_direction(current_direction):
		#velocity = Vector2.ZERO

# 碰撞预检测
#func has_collision_in_direction(dir: Vector2) -> bool:
	#var params = PhysicsTestMotionParameters2D.new()
	#params.from = global_transform
	#params.motion = dir * ($TankCollisionShape.shape\
		#.get_rect().size.x / 2 + 2)
	#return PhysicsServer2D.body_test_motion(get_rid(), params)

# 防卡墙增强逻辑
func _safe_move(delta: float, direction: Vector2):
	var target_velocity = direction * speed
	var collider = move_and_collide(target_velocity * delta)
	if collider: # 如果有发生碰撞，则判断碰撞的是什么内容
		collider = collider.get_collider()
		if collider is StaticBody2D: # 如果与静态刚体节点碰撞
			collider = collider.get_parent()
			if collider is PropNode: # 如果是道具节点，则执行下面逻辑
				var prop_type = (collider as PropNode).prop_type
				if prop_type == PropNode.TYPE_HAT: # 如果保护帽，则显示特效
					self._append_protected_effect()
				elif prop_type == PropNode.TYPE_STAR: # 如果是五角星，拾取五角星
					self.props.append(collider)
				GlobalEventBus.emit_signal('player_get_prop') # 发送获得道具的通知

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
	var direction = directions.keys()[randi() % 4]
	self.change_direction(direction) #修改新的移动方向

## 发送子弹
func shoot():
	var bullet: BulletNode = _tank_bullet_prefab.instantiate()
	bullet.owner_role = role
	if role == TankRoleType.Enemy2: # 这种坦克速度快，因此子弹速度要快
		bullet.speed *= 1.50
	var bullet_position = self.position + \
		bullet.current_direction * Constants.WarMapTiledSize
	bullet.position = bullet_position
	bullet.current_direction = current_direction.normalized()
	if role == TankRoleType.Hero:
		$AudioManager.play_attack_sound() # 播放攻击的声音
	get_parent().add_child(bullet) # 把子弹添加到父节点中去

## 坦克受伤
func hurt():
	if current_state == TankState.STRONG:
		# 坦克处于无敌模式，无法被攻击
		return
	if is_red_tank: # 如果是红坦克，需要展示道具
		is_red_tank = false # 设置红色坦克属性取消
		self._stop_blink() # 停止红坦克闪烁
		GlobalEventBus.emit_signal('show_strong_prop')
		return
	hits_of_received -= 1 # 抗击打能力每次减少1
	if hits_of_received <= 0: # 为0时坦克爆炸
		_show_bomb_effect() # 显示爆炸效果

## 显示出生特效
func _show_born_effect():
	current_state = TankState.BORN
	if role == TankRoleType.Hero: # 如果是玩家，出生时，追加保护效果
		_append_protected_effect()
	var on_animation_finished = func(): \
			$BornAndDeadAnimation.visible = false; \
			$TankSprite.visible = true; \
			if current_state == TankState.BORN:\
				current_state = TankState.ALIVE
	$TankSprite.visible = false
	$BornAndDeadAnimation.visible = true
	$BornAndDeadAnimation.play("Born")
	$BornAndDeadAnimation.animation_finished.connect(on_animation_finished)

## 追加保护特效，无敌模式
func _append_protected_effect():
	protect_hold_time = 0.0 # 持续时间归零
	current_state = TankState.STRONG
	$ProtectedAnimation.visible = true
	$ProtectedAnimation.play('Protected')

## 显示爆炸特效，摧毁坦克节点
func _show_bomb_effect():
	current_state = TankState.DEAD
	if role != TankRoleType.Hero:
		_remove_auto_move_timer() # 需要删除自动移动的逻辑
	velocity = Vector2.ZERO
	current_direction = Vector2.ZERO
	$TankCollisionShape\
		.set_deferred('disabled', true)
	$BornAndDeadAnimation.visible = true
	$BornAndDeadAnimation.play("Bomb")
	$BornAndDeadAnimation.connect('animation_finished', _on_tank_damaged)
	if role != TankRoleType.Hero:
		$AudioManager.play_tank_crack()
		GlobalEventBus.emit_signal('enemy_damaged', self)
	else:
		$AudioManager.play_player_crack()
		GlobalEventBus.emit_signal('player_damaged')

## 敌人坦克被摧毁
func _on_tank_damaged():
	if role == TankRoleType.Hero:
		queue_free()
		return
	var score = TankRoleType.get_score_by_role(role)
	if score == 100:
		$TankSprite.texture = load('res://assets/images/score_100.png')
	elif score == 200:
		$TankSprite.texture = load('res://assets/images/score_200.png')
	else:
		$TankSprite.texture = load('res://assets/images/score_500.png')
	await get_tree().create_timer(1.2).timeout
	queue_free() # 延时1.2s后，执行节点删除

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

## 开始闪烁
func _start_blink():
	_red_tank_blink_tween = create_tween().set_loops()
	_red_tank_blink_tween.tween_property($TankSprite, 'modulate', Color.WHITE, 0.3)
	_red_tank_blink_tween.tween_property($TankSprite, 'modulate', Color.CRIMSON, 0.3)

# 停止闪烁
func _stop_blink():
	_red_tank_blink_tween.kill()
