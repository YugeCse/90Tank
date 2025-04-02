extends CanvasItem

## 视图矩形
var _viewport_rect: Rect2

## 战场矩形
var _war_map_rect: Rect2

## 关卡数
@export
var stage_level: int = 4

## 地图地砖的预制体
@onready
var _tiled_prefab = preload("res://sprites/map_tiled_node.scn")

## 坦克预制体
@onready
var _tank_prefab = preload("res://sprites/tank_node.scn")

func _ready() -> void:
	## 计算界面要绘制的矩形大小，确定战场边界等内容
	_viewport_rect = get_viewport() \
		.get_visible_rect()
	var viewport_size = _viewport_rect.size
	var war_offset_x = viewport_size.x/2.0 - Constants.WarMapSize/2.0
	var war_offset_y = viewport_size.y/2.0 - Constants.WarMapSize/2.0
	_war_map_rect = Rect2(war_offset_x, war_offset_y, \
		Constants.WarMapSize, Constants.WarMapSize)
	## 修改地图图层位置
	$WarRootMap.position = Vector2(war_offset_x, war_offset_y)
	$WarRootMap.set_size(_war_map_rect.size, false)
	## 修改草地图层位置
	$GrassMap.position = Vector2(war_offset_x, war_offset_y)
	$GrassMap.set_size(_war_map_rect.size, false)
	## 绘制游戏地图图层
	_draw_stage_map()
	## 修改坦克图层位置
	$TankLayer.position = Vector2(war_offset_x, war_offset_y)
	$TankLayer.set_size(_war_map_rect.size, false)
	
	## 设置坦克的可运动的边界
	var boundary_min = Vector2.ZERO
	var boundary_max = Vector2(Constants.WarMapSize, Constants.WarMapSize)
	
	var hero_tank: TankNode = _tank_prefab.instantiate()
	hero_tank.role = TankRoleType.VALUES.Hero
	hero_tank.boundary_min = boundary_min
	hero_tank.boundary_max = boundary_max
	hero_tank.position = Vector2(Constants.WarMapTiledBigSize * 4.5, \
		Constants.WarMapSize - Constants.WarMapTiledBigSize/2.0)
	$TankLayer.add_child(hero_tank);

	var hero_tank2: TankNode = _tank_prefab.instantiate()
	hero_tank2.role = TankRoleType.VALUES.Enemy2
	hero_tank2.boundary_min = boundary_min
	hero_tank2.boundary_max = boundary_max
	$TankLayer.add_child(hero_tank2);
	
func _draw() -> void:
	draw_rect(_viewport_rect, Color.GRAY)
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
			var tiled: MapTiledNode = _tiled_prefab.instantiate()
			tiled.tiled_type = tiled_type
			tiled.position = Vector2( \
				pos_x + Constants.WarMapTiledSize/2.0, \
				pos_y + Constants.WarMapTiledSize/2.0)
			if tiled_type != MapTiledType.VALUES.GRASS:
				$WarRootMap.add_child(tiled)
			else:
				$GrassMap.add_child(tiled)
