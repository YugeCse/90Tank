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
var owner_role: TankRoleType.VALUES

### 子弹帧集合
@export
var bullet_frames: Array[CompressedTexture2D] = []

## 子弹方向
var current_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	if current_direction == Vector2.ZERO:
		free() #直接释放对象
		return
	if current_direction == Vector2.UP:
		$Sprite2D.texture = bullet_frames[0]
		self._set_collision_shape(Vector2(4,5))
	elif current_direction == Vector2.DOWN:
		$Sprite2D.texture = bullet_frames[1]
		self._set_collision_shape(Vector2(4,5))
	elif current_direction == Vector2.LEFT:
		$Sprite2D.texture = bullet_frames[2]
		self._set_collision_shape(Vector2(5, 4))
	elif current_direction == Vector2.RIGHT:
		$Sprite2D.texture = bullet_frames[3]
		self._set_collision_shape(Vector2(5, 4))
	velocity = current_direction * speed
	
func _process(delta: float) -> void:
	if current_state == STATE_BOMB:
		velocity = Vector2.ZERO
		return
	var collider = move_and_collide(velocity * delta)
	if collider:
		print('与什么发生碰撞: {0}', collider)
		_show_bomb_effect() #显示爆炸效果
		return
	if position.x <= 2.5 or \
		position.x >= Constants.WarMapSize + 2.5 or\
		position.y <= 2.5 or \
		position.y >= Constants.WarMapSize + 2.5:
		_show_bomb_effect() #与边界发生交集，直接爆炸
	
	
## 设置碰撞矩形大小
func _set_collision_shape(size: Vector2):
	var shape = RectangleShape2D.new()
	shape.size = size
	$CollisionShape2D.shape = shape

## 显示爆炸特效
func _show_bomb_effect():
	velocity = Vector2.ZERO
	$CollisionShape2D\
		.set_deferred("disabled", true)
	current_state = STATE_BOMB
	remove_child($Sprite2D)
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("bomb")
	$AnimatedSprite2D.animation_finished\
		.connect(func (): queue_free())
