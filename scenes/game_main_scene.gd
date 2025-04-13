## 游戏主场景
class_name GameMainScene
extends CanvasItem

## 游戏状态 - 开始
const GAME_STATE_START = "game_start"

## 游戏状态 - 暂停
const GAME_STATE_PAUSE = "game_pause"

## 游戏状态 - 结束
const GAME_STATE_OVER = "game_over"

## 游戏视窗矩形
var _viewport_rect: Rect2

## 战场矩形
var _war_map_rect: Rect2

## 游戏状态
var game_state: String = GAME_STATE_START

## 关卡数
@export
var stage_level: int = 0

## 英雄坦克生命数目：3
@export
var hero_tank_life: int = 3

## 英雄坦克
var hero_tank: TankNode

### 敌人总数, 数值：20
var enemy_total_count: int = Constants.ENEMY_TOTAL_COUNT

## 敌人参战数，数值：5
@export
var enemy_war_count: int = 5

## 玩家得分，默认：0
var hero_win_score: int = 0

## 敌方坦克的出生数量
var _enemy_born_count: int = 0

## 玩家定时器道具计时，默认：0
var _player_prop_timer_time: float = 0

## 玩家定时器是否可用，默认：false
var _player_prop_timer_enable: bool = false

## 玩家基地是否被保护起来了，默认：false
var _master_protected: bool = false

## 玩家基地被保护了的时长，默认：0
var _master_protected_time: float = 0

## 临时标记玩家基地变化的时间
var _tmp_map_tiled_change_time: float = 0

## 临时的地砖类型标记字段
var _tmp_map_tiled_type: int = MapTiledType.WALL

## 基地金砖节点，玩家拾取铁锹道具时拥有, 存储格式：x,y = MapTiledNode
var _master_grid_nodes: Dictionary[String, MapTiledNode] = {}

## 地图地砖的预制体
@onready
var _tiled_prefab = preload("res://sprites/map_tiled_node.scn")

## 玩家基地对象
@onready
var _player_master = preload("res://sprites/master_node.scn").instantiate()

## 敌人计数容器
@onready
var _enemy_counter_container: GridContainer = $SideBarContainer/EnemyCounterContainer

## 准备方法
func _ready() -> void:
	self.set_process(true)
	self._init_layout() # 初始化布局
	self._bind_event_bus() # 绑定事件通知
	self._create_hero_tank() # 创建英雄坦克

# 初始化布局
func _init_layout():
	# 计算界面要绘制的矩形大小，确定战场边界等内容
	_viewport_rect = get_viewport().get_visible_rect()
	var viewport_size = _viewport_rect.size
	var war_offset_x = viewport_size.x / 2.0 - Constants.WarMapSize / 2.0 \
		- Constants.WarMapTiledBigSize
	var war_offset_y = viewport_size.y / 2.0 - Constants.WarMapSize / 2.0
	_war_map_rect = Rect2(war_offset_x, war_offset_y, \
		Constants.WarMapSize, Constants.WarMapSize)
	stage_level = GameData.stage_level # 获取全局的关卡等级
	$Background.set_size(get_window().size)
	# 调整侧边栏的位置
	$SideBarContainer.position = Vector2(_war_map_rect.end.x + 2.0, war_offset_y)
	# 设置侧边栏敌人计数
	for index in range(enemy_total_count):
		var tex_rect = TextureRect.new()
		tex_rect.size = Vector2(14, 14)
		tex_rect.texture = load("res://assets/images/enemy_tank_tag.png") # 设置纹理
		_enemy_counter_container.add_child(tex_rect)
	# 修改关卡幕布位置
	var stage_curtain_size = $StageCurtain.size
	$StageCurtain.position = viewport_size / 2.0 - stage_curtain_size / 2.0
	$StageCurtain/StageLevelContainer.size_flags_vertical = Control.SIZE_EXPAND
	$StageCurtain/StageLevelContainer.size_flags_horizontal = Control.SIZE_EXPAND
	$StageCurtain/StageLevelContainer/NumberNode.set_number(stage_level) # 设置关卡等级数据
	# 修改地图图层位置
	$WarRootMap.position = Vector2(war_offset_x, war_offset_y)
	$WarRootMap.set_size(_war_map_rect.size, false)
	# 修改草地图层位置
	$GrassMap.position = Vector2(war_offset_x, war_offset_y)
	$GrassMap.set_size(_war_map_rect.size, false)
	# 创建道具图层
	$PropMap.position = Vector2(war_offset_x, war_offset_y)
	$PropMap.set_size(_war_map_rect.size, false)
	# 游戏结束的显示图层
	$GameOverContainer.position = $WarRootMap.position
	$GameOverContainer/GameOverPic.position = Vector2(\
		Constants.WarMapSize / 2.0 - \
		$GameOverContainer/GameOverPic.get_rect().size.x / 2.0, \
		Constants.WarMapSize + Constants.WarMapTiledSize)

	# 修改坦克图层位置
	$TankLayer.position = Vector2(war_offset_x, war_offset_y)
	$TankLayer.set_size(_war_map_rect.size, false)

	$AudioManager.play_game_start() # 播放游戏开始的音效
	$StageCurtain/AnimationPlayer.play(&'stage_curtain_slide_up') # 打开游戏关卡幕布

	self._draw_war_stage_map() # 绘制游戏地图图层
	self._create_enenmy_by_timer() # 通过定时器创建敌方坦克

## 绑定事件通知
func _bind_event_bus():
	GlobalEventBus.tank_get_prop.connect(_tank_get_prop)
	GlobalEventBus.player_damaged.connect(_player_damaged)
	GlobalEventBus.enemy_damaged.connect(_enemy_damaged)
	GlobalEventBus.master_damaged.connect(_player_master_damaged)
	GlobalEventBus.show_strong_prop.connect(_show_player_prop)

## 游戏进度渲染方法
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	if Input.is_action_pressed(&'ui_pause_resume'):
		if game_state == GAME_STATE_START:
			game_state = GAME_STATE_PAUSE
			set_all_tanks_move_state(false)
		elif game_state == GAME_STATE_PAUSE:
			game_state = GAME_STATE_START
			set_all_tanks_move_state(true)
	if game_state == GAME_STATE_PAUSE: return # 如果游戏是暂停状态，不处理以下逻辑
	_handle_master_state(delta) # 处理玩家总部状态
	_handle_prop_timer_state(delta) # 处理定时器道具状态
	$SideBarContainer/StageLevelFlag/NumberNode.set_number(stage_level)
	$SideBarContainer/Player1/NumberNode.set_number(hero_tank_life if hero_tank_life >= 0 else 0)

## 处理定时器道具状态
func _handle_prop_timer_state(delta: float)->void:
	if not _player_prop_timer_enable:
		_player_prop_timer_time = 0.0
		return
	_player_prop_timer_time += delta # 累积计算时间
	if _player_prop_timer_time > Constants.PLAYER_PROP_TIMER_LIMIT_TIMER:
		_player_prop_timer_time = 0.0
		_player_prop_timer_enable = false # 设置定时器道具不可用

## 处理玩家总部状态
func _handle_master_state(delta: float) -> void:
	if not _master_protected:
		_master_protected_time = 0.0
		return # 如果基地属于被保护状态，那么会执行下面的逻辑
	_master_protected_time += delta # 累积计算被保护的时长
	if _master_protected_time >= Constants.PLAYER_MASTER_PROTECT_LIMIT_TIME:
		_master_protected = false
		_master_protected_time = 0.0
		_tmp_map_tiled_change_time = 0.0
		_show_master_protect_nodes(MapTiledType.WALL)
	elif _master_protected_time >= Constants.PLAYER_MASTER_PROTECT_LIMIT_TIME - 5:
		_tmp_map_tiled_change_time += delta
		if _tmp_map_tiled_change_time <= 0.3: return # 每0.3秒切换一次地图地砖
		if _tmp_map_tiled_type == MapTiledType.GRID:
			_tmp_map_tiled_type = MapTiledType.WALL
		else:
			_tmp_map_tiled_type = MapTiledType.GRID
		_tmp_map_tiled_change_time = 0.0
		_show_master_protect_nodes(_tmp_map_tiled_type)

## 绘制关卡地址
func _draw_war_stage_map():
	var stage_level_map = StageLevel.get_stage_map(stage_level) # 关卡等级设置地图
	for y in stage_level_map.size():
		for x in stage_level_map[y].size():
			var pos_x = x * Constants.WarMapTiledSize
			var pos_y = y * Constants.WarMapTiledSize
			var value = stage_level_map[y][x]
			var tiled_type = MapTiledType.get_tiled_type(value)
			var tiled_node: MapTiledNode = _tiled_prefab.instantiate()
			tiled_node.tiled_type = tiled_type
			tiled_node.position = Vector2(pos_x + Constants.WarMapTiledSize / 2.0, \
				pos_y + Constants.WarMapTiledSize / 2.0)
			if tiled_type == MapTiledType.GRASS:
				$GrassMap.add_child(tiled_node)
				continue
			var master_py = Constants.WarMapTiledCount - 3
			var master_px = int(float(Constants.WarMapTiledCount) / 2) - 2
			if x >= master_px and x <= master_px + 3 \
				and y >= master_py and y <= master_py + 3:
					if x >= master_px + 1 and x <= master_px + 2 \
						and y >= master_py + 1 and y <= master_py + 2:
							continue
					# tiled.tiled_type = MapTiledType.GRID
					_master_grid_nodes.set('%f-%f' % [tiled_node.position.x, \
						tiled_node.position.y], tiled_node) # 添加基地节点
			$WarRootMap.add_child(tiled_node) # 地砖添加到战场地图
	# 绘制玩家坦克基地
	var master_x = Constants.WarMapSize / 2.0
	var master_y = Constants.WarMapSize - Constants.WarMapTiledSize
	_player_master.position = Vector2(master_x, master_y)
	$WarRootMap.add_child(_player_master) # 地图添加玩家基地节点

## 构建金砖节点，放置在玩家基地
## <pre>type - 节点类型</pre>
func _show_master_protect_nodes(type: int):
	for key in _master_grid_nodes:
		var node = _master_grid_nodes[key]
		if not node or not node.body:
			if node:
				node.queue_free()
			var position = Array(key.split('-'));
			node = _tiled_prefab.instantiate() as MapTiledNode
			node.set_tiled_type(type)
			node.position = Vector2(float(position[0]), float(position[1]))
			_master_grid_nodes.set(key, node) # 重新设置key-value信息
		else:
			node.set_tiled_type(type)
		if node.get_parent():
			continue
		$WarRootMap.add_child(node)

## 敌人被消灭
func _enemy_damaged(tank: TankNode):
	print('敌人被消灭： ', tank)
	enemy_total_count -= 1 # 敌人数量减少1
	if enemy_total_count <= 0:
		enemy_total_count = 0
		print('敌人已经被完全消灭！')
		GameData.stage_level = StageLevel.get_next_level(GameData.stage_level)
		get_tree().change_scene_to_file('res://scenes/game_main_scene.tscn')
		return # 敌人已经被完全消灭
	print('当前还有敌方坦克数： %d' % enemy_total_count)

## 玩家被消灭
func _player_damaged():
	print('玩家被消灭！')
	_create_hero_tank() # 创建新的玩家

## 玩家基地被摧毁
func _player_master_damaged():
	print('玩家总部被摧毁！')
	_show_game_over_animation() # 显示游戏结束的动画

# 坦克获得道具
func _tank_get_prop(tank: TankNode, prop_type: int):
	if tank.role == TankRoleType.Hero and \
		prop_type == PropNode.TYPE_TANK:
		hero_tank_life += 1 # 玩家生命+1
		$AudioManager.play_prop() # 播放坦克加人的音乐
	elif prop_type == PropNode.TYPE_MASTER: # 如果坦克敌机加固
		_master_protected = true # 标记总部被保护
		_master_protected_time = 0 # 标记总部被保护的时长
		_tmp_map_tiled_change_time = 0 # 清空时间
		_tmp_map_tiled_type = MapTiledType.GRID
		_show_master_protect_nodes(MapTiledType.GRID) # 加固玩家基地
	elif prop_type == PropNode.TYPE_BOMB: # 如果是炸弹道具
		var children = $TankLayer.get_children()
		for child in children:
			if child is TankNode and \
				child.role != TankRoleType.Hero:
				child.bomb() # 坦克直接爆炸
	elif prop_type == PropNode.TYPE_TIMER: # 如果是定时器道具
		set_all_tanks_move_state(false) # 设置敌方坦克不可移动
	$PropCreator.dismiss_player_prop() # 隐藏玩家道具

## 显示玩家道具
func _show_player_prop():
	$PropCreator.show_player_prop($PropMap)

## 创建英雄坦克
func _create_hero_tank():
	if hero_tank_life >= 0:
		hero_tank_life -= 1
	if hero_tank_life < 0:
		self._show_game_over_animation()
		return # 玩家没有生命，直接结束游戏
	hero_tank = $TankCreator.create_hero_tank()
	if game_state == GAME_STATE_OVER and hero_tank:
		hero_tank.allow_move = false # 游戏结束，坦克无法移动
	$TankLayer.add_child(hero_tank);

## 通过定时器创建敌方坦克
func _create_enenmy_by_timer():
	var create_enemy_timer = Timer.new()
	create_enemy_timer.wait_time = 1.0
	create_enemy_timer.one_shot = false
	create_enemy_timer.name = "EnemyCreateTimer"
	create_enemy_timer.connect('timeout', _create_enemy_tank_if_neccessary)
	create_enemy_timer.autostart = true
	self.add_child(create_enemy_timer)

## 按需通过定时器添加敌方坦克
func _create_enemy_tank_if_neccessary():
	var total_enemy_count = 0 # 当前渲染界面中敌方坦克的数量
	var tanks: Array[TankNode] = []
	tanks.assign($TankLayer.get_children() \
		.filter(func(v): return v is TankNode and (v as TankNode).role != TankRoleType.Hero))
	total_enemy_count = tanks.size() # 战场地方坦克的数量
	# 当战场上的坦克总数小于等于0或者当战场上的坦克数等于战场上应该显示的坦克数时，就不应该创建新的坦克
	if _enemy_born_count >= Constants.ENEMY_TOTAL_COUNT or \
		total_enemy_count == enemy_war_count: return
	var diff_count = abs(enemy_war_count - total_enemy_count)
	var locations = [TankCreator.CREATE_LCOATION_CENTER, \
		TankCreator.CREATE_LOCATION_LEFT, \
		TankCreator.CREATE_LOCATION_RIGHT]
	var locationRects = [
		Rect2(Constants.WarMapSize / 2.0 - Constants.WarMapTiledSize, 0, \
			Constants.WarMapTiledBigSize, Constants.WarMapTiledBigSize),
		Rect2(0, 0, Constants.WarMapTiledBigSize, Constants.WarMapTiledBigSize),
		Rect2(Constants.WarMapSize - Constants.WarMapTiledBigSize, 0, \
			Constants.WarMapTiledBigSize, Constants.WarMapTiledBigSize),
	]
	for i in range(diff_count):
		if _enemy_born_count > Constants.ENEMY_TOTAL_COUNT:
			return # 防止敌方坦克总数超限
		var target_location: int = -100000
		for index in range(locationRects.size()):
			var rect = locationRects[index]
			var location = locations[index]
			if tanks.is_empty() or \
				tanks.all(func(v): return _no_other_tank_in_location(rect, v)):
				target_location = location
				break
		if target_location == -100000: return # 不满足条件，直接返回
		var rv = randf()
		var type = TankRoleType.Enemy1
		if rv < 0.6:
			type = TankRoleType.Enemy1
		elif rv < 0.8:
			type = TankRoleType.Enemy2
		else:
			type = TankRoleType.Enemy3
		var tank = $TankCreator.create_enemy_tank(type, target_location)
		if tanks.size() % 3 == 0 and \
			type != TankRoleType.Enemy3:
			tank.red_tank_count = randi() % 2 + 1 # 标记为红坦克
		_enemy_born_count += 1 # 统计坦克出生数量
		$TankLayer.add_child(tank); # 添加创建的坦克到新节点中
		tanks.append(tank) # 需要记录这个新添加的
		remove_enemy_counter_container_last_child() # 移除敌人计数器中最后一个child

## 判断这个位置是否有其他坦克存在
func _no_other_tank_in_location(target_rect: Rect2, tank: TankNode) -> bool:
	var tank_rect = Rect2(tank.position.x, tank.position.y, \
		Constants.WarMapTiledBigSize, Constants.WarMapTiledBigSize)
	return not tank_rect.intersects(target_rect, true)

## 移除敌人计数器中最后一个child
func remove_enemy_counter_container_last_child():
	var children = _enemy_counter_container.get_children()
	if children.is_empty(): return
	# 开始删除最后一个child
	var last_child = children.back()
	_enemy_counter_container.remove_child(last_child)
	last_child.queue_free() # 消除最后一个child
	_enemy_counter_container.queue_redraw() # 重新绘制界面

## 设置所有坦克的运行状态
func set_all_tanks_move_state(allow_move: bool):
	var children = $TankLayer.get_children()
	for child in children:
		if child is TankNode:
			child.allow_move = allow_move

## 显示游戏结束动画
func _show_game_over_animation():
	if game_state == GAME_STATE_OVER:
		return # 游戏已经是结束的状态，直接返回
	game_state = GAME_STATE_OVER # 游戏状态设置为结束
	$GameOverContainer.visible = true # 游戏结束容器变得可见
	var tween = get_tree().create_tween()
	tween.tween_property($GameOverContainer/GameOverPic, "position:y", \
		Constants.WarMapSize / 2.0 - Constants.WarMapTiledSize, 1.2)
	if hero_tank: hero_tank.allow_move = false # 游戏结束，坦克无法移动
