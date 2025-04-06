extends CanvasItem

## 视图矩形
var _viewport_rect: Rect2

## 战场矩形
var _war_map_rect: Rect2

## 关卡数
@export
var stage_level: int = 4

## 英雄坦克声明数
@export
var hero_tank_life: int = 3

## 英雄坦克
var hero_tank: TankNode

### 敌人总数
@export
var enemy_total_count: int = 20

### 敌人参战数
@export
var enemy_war_count: int = 5

## 玩机得分
var hero_win_score: int = 0

## 坦克加强道具
var _tank_strong_prop: PropNode

## 基地金砖节点，玩家拾取铁锹道具时拥有
var _master_grid_nodes: Array[MapTiledNode] = []

## 地图地砖的预制体
@onready
var _tiled_prefab = preload("res://sprites/map_tiled_node.scn")

## 坦克道具预制体
@onready
var _tank_prop_prefab = preload('res://sprites/prop_node.tscn')

## 玩家基地对象
@onready
var _player_master = preload("res://sprites/master_node.scn").instantiate()

func _ready() -> void:
	set_process(true)
	self._init_layout() # 初始化布局
	self._bind_event_bus() # 绑定事件通知
	self._create_hero_tank() # 创建英雄坦克

# 初始化布局
func _init_layout():
	# 计算界面要绘制的矩形大小，确定战场边界等内容
	_viewport_rect = get_viewport() \
		.get_visible_rect()
	var viewport_size = _viewport_rect.size
	var war_offset_x = viewport_size.x/2.0 - Constants.WarMapSize/2.0\
		- Constants.WarMapTiledBigSize
	var war_offset_y = viewport_size.y/2.0 - Constants.WarMapSize/2.0
	_war_map_rect = Rect2(war_offset_x, war_offset_y, \
		Constants.WarMapSize, Constants.WarMapSize)
	# 调整侧边栏的位置
	$SideBarContainer.position = Vector2(_war_map_rect.end.x +\
		Constants.WarMapTiledSize/4.0, war_offset_y)
	# 修改关卡幕布位置
	var stage_curtain_size = $StageCurtain.size
	$StageCurtain.position = viewport_size/2.0 - stage_curtain_size/2.0
	$StageCurtain/StageLevelContainer.size_flags_vertical = Control.SIZE_EXPAND
	$StageCurtain/StageLevelContainer.size_flags_horizontal = Control.SIZE_EXPAND
	# 修改地图图层位置
	$WarRootMap.position = Vector2(war_offset_x, war_offset_y)
	$WarRootMap.set_size(_war_map_rect.size, false)
	# 修改草地图层位置
	$GrassMap.position = Vector2(war_offset_x, war_offset_y)
	$GrassMap.set_size(_war_map_rect.size, false)
	# 创建道具图层
	$PropMap.position = Vector2(war_offset_x, war_offset_y)
	$PropMap.set_size(_war_map_rect.size, false)

	self._draw_stage_map() # 绘制游戏地图图层

	# 修改坦克图层位置
	$TankLayer.position = Vector2(war_offset_x, war_offset_y)
	$TankLayer.set_size(_war_map_rect.size, false)

	$AudioManager.play_game_start() # 播放游戏开始的音效
	$StageCurtain/AnimationPlayer.play('stage_curtain_slide_up') # 打开游戏关卡幕布

## 绑定事件通知
func _bind_event_bus():
	GlobalEventBus.master_damaged\
		.connect(func(): print('总部被摧毁'))
	GlobalEventBus.player_damaged\
		.connect(func(): print('玩家被消灭'); _create_hero_tank())
	GlobalEventBus.player_get_prop\
		.connect(func(): print('玩家获得道具'); _dismiss_strong_prop())
	GlobalEventBus.enemy_damaged\
		.connect(func(tank): \
			print('敌人被消灭： ', tank);\
			enemy_total_count -= 1)
	GlobalEventBus.show_strong_prop.connect(func(): _show_strong_prop())

@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	_create_enemy_tank_if_neccessary() #检测并创建地方坦克
	if hero_tank_life < 0:
		hero_tank_life = 0
	$SideBarContainer/Player1/NumberNode.set_number(hero_tank_life)
	$SideBarContainer/StageLevelFlag/NumberNode.set_number(stage_level + 1)

func _draw() -> void:
	draw_rect(_viewport_rect, Color(127, 127, 127, 255))
	draw_rect(_war_map_rect, Color.BLACK)

## 绘制关卡地址
func _draw_stage_map():
	var stage_level_map:Array = StageLevel.WarMaps[stage_level]
	for y in stage_level_map.size():
		for x in stage_level_map[y].size():
			var pos_x = x * Constants.WarMapTiledSize
			var pos_y = y * Constants.WarMapTiledSize
			var value = stage_level_map[y][x]
			var tiled_type = MapTiledType.get_tiled_type(value)
			var tiled_node: MapTiledNode = _tiled_prefab.instantiate()
			tiled_node.tiled_type = tiled_type
			tiled_node.position = Vector2(pos_x + Constants.WarMapTiledSize/2.0,\
				pos_y + Constants.WarMapTiledSize/2.0)
			if tiled_type == MapTiledType.GRASS:
				$GrassMap.add_child(tiled_node)
				continue
			var master_x = Constants.WarMapTiledCount/2-2
			var master_y = Constants.WarMapTiledCount-3
			if x >= master_x and x <= master_x + 3 \
				and y >= master_y and y <= master_y + 3:
					if x >= master_x+1 and x <= master_x+2 \
						and y >= master_y+1 and y <= master_y+2:
							continue
					# tiled.tiled_type = MapTiledType.GRID
					_master_grid_nodes.append(tiled_node) # 添加基地节点
			$WarRootMap.add_child(tiled_node) # 地砖添加到战场地图
	# 绘制玩家坦克基地
	var master_x = Constants.WarMapSize/2.0
	var master_y = Constants.WarMapSize - Constants.WarMapTiledSize
	_player_master.position = Vector2(master_x, master_y)
	$WarRootMap.add_child(_player_master)

	# self._show_master_grid_nodes() # 构建金砖节点，放置在玩家地址位置

## 构建金砖节点，放置在玩家基地
func _show_master_grid_nodes():
	var offset_x = Constants.WarMapTiledSize
	var offset_y = Constants.WarMapTiledSize
	var start_offset = Vector2(Constants.WarMapSize/2.0-2.5 * Constants.WarMapTiledSize,
		Constants.WarMapSize-3.5 * Constants.WarMapTiledSize) + Vector2(offset_x, offset_y)
	for node in _master_grid_nodes:
		node.set_tiled_type(MapTiledType.GRID)
		print(node.position)
		if node.get_parent():
			continue
		$WarRootMap.add_child(node)

## 显示加强道具
func _show_strong_prop():
	self._dismiss_strong_prop()
	var prop_type = PropNode.TYPE_HAT
	_tank_strong_prop = _tank_prop_prefab.instantiate()
	_tank_strong_prop.prop_type = prop_type
	_tank_strong_prop.position = Vector2(
		randi_range(Constants.WarMapTiledSize,\
			Constants.WarMapSize - Constants.WarMapTiledSize),
		randi_range(Constants.WarMapTiledSize,\
			Constants.WarMapSize - Constants.WarMapTiledSize))
	if prop_type == PropNode.TYPE_TANK:
		$AudioManager.play_prop() #播放坦克加人的道具音效
	$PropMap.add_child(_tank_strong_prop) # 添加道具地图

## 隐藏道具节点
func _dismiss_strong_prop():
	if _tank_strong_prop:
		_tank_strong_prop.free()
	_tank_strong_prop = null

## 创建英雄坦克
func _create_hero_tank():
	if hero_tank_life > 1:
		hero_tank_life -= 1
	if hero_tank_life == 0:
		print('游戏结束，玩家没有生命数了')
		return
	hero_tank = TankCreator.create_hero_tank()
	$TankLayer.add_child(hero_tank);

## 通过定时器添加敌方坦克
func _create_enemy_tank_if_neccessary():
	var children = $TankLayer.get_children()
	var total_enemy_count = 0
	var tanks: Array[TankNode] = []
	for child in children:
		if child is TankNode:
			total_enemy_count += 1
			tanks.append(child as TankNode)
	if not (total_enemy_count < enemy_war_count && enemy_total_count > 0): return
	var diff_count = abs(enemy_war_count - total_enemy_count)
	var locations = [TankCreator.CREATE_LCOATION_CENTER, TankCreator.CREATE_LOCATION_LEFT, TankCreator.CREATE_LOCATION_RIGHT]
	var locationRects = [
		Rect2(Constants.WarMapSize/2.0 - Constants.WarMapTiledSize, 0, Constants.WarMapTiledBigSize, Constants.WarMapTiledBigSize),
		Rect2(0, 0, Constants.WarMapTiledBigSize, Constants.WarMapTiledBigSize),
		Rect2(Constants.WarMapSize - Constants.WarMapTiledBigSize, 0, Constants.WarMapTiledBigSize, Constants.WarMapTiledBigSize),
	]
	for i in range(0, diff_count):
		var target_location: int = -100000
		for index in range(0, locationRects.size()):
			var rect = locationRects[index]
			var location = locations[index]
			if tanks.any(func(item): return _no_other_tank_in_location(rect, item)):
				target_location = location
				break
		if target_location != -100000:
			var rv = randf()
			var type = TankRoleType.Enemy1
			if rv < 0.6:
				type = TankRoleType.Enemy1
			elif type < 0.8:
				type = TankRoleType.Enemy2
			else:
				type = TankRoleType.Enemy3
			var tank = TankCreator.create_enemy_tank(type, target_location)
			tanks.append(tank) # 需要记录这个新添加的
			enemy_total_count -= 1 # 每次坦克总数减少1
			if enemy_total_count % 3 == 0 and\
				type != TankRoleType.Enemy3:
				tank.is_red_tank = true # 标记为红坦克
			$TankLayer.add_child(tank); # 添加创建的坦克到新节点中

## 判断这个位置是否有其他坦克存在
func _no_other_tank_in_location(target_rect: Rect2, tank: TankNode) -> bool:
	var tank_rect = Rect2(tank.position.x, tank.position.y, Constants.WarMapTiledBigSize, Constants.WarMapTiledBigSize)
	return not tank_rect.intersects(target_rect, true)
