class_name MapTiledType

## 泥墙
const WALL = 1
## 钢墙
const GRID = 2
## 草地
const GRASS = 3
## 河流
const RIVER = 4
## 冰地
const ICE = 5
## 无地块
const NONE = 0

## 根据取值得到地砖类型
static func get_tiled_type(value: int)-> int:
	if value == 1:
		return WALL
	elif value == 2:
		return GRID
	elif value == 3:
		return GRASS
	elif value == 4:
		return RIVER
	elif value == 5:
		return ICE
	return NONE

## 根据类型获取碰撞层
static func get_tiled_collision_layer(type: int) -> int:
	if type == WALL:
		return CollisionLayer.Wall
	elif type == GRID:
		return CollisionLayer.Grid
	elif type == GRASS:
		return CollisionLayer.Grass
	elif type == RIVER:
		return CollisionLayer.River
	elif type == ICE:
		return CollisionLayer.Ice
	return CollisionLayer.Default

## 根据精灵位置索引
static func get_sprite_index(type: int):
	return [WALL, GRID, GRASS, RIVER, ICE].find(type)
