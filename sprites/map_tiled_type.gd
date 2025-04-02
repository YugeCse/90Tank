class_name MapTiledType
extends Node

## 枚举值
enum VALUES {
	## 泥墙
	WALL = 1,
	## 钢墙
	GRID = 2,
	## 草地
	GRASS = 3,
	## 河流
	RIVER = 4,
	## 冰地
	ICE = 5,
	## 无地块
	NONE = 0
}

## 根据取值得到地砖类型
static func get_tiled_type(value: int)-> VALUES:
	if value == 1:
		return VALUES.WALL
	elif value == 2:
		return VALUES.GRID
	elif value == 3:
		return VALUES.GRASS
	elif value == 4:
		return VALUES.RIVER
	elif value == 5:
		return VALUES.ICE
	return VALUES.NONE

## 根据类型获取碰撞层
static func get_tiled_collision_layer(type: VALUES) -> int:
	if type == VALUES.WALL:
		return Constants.CollisionLayer.Wall
	elif type == VALUES.GRID:
		return Constants.CollisionLayer.Grid
	elif type == VALUES.GRASS:
		return Constants.CollisionLayer.Grass
	elif type == VALUES.RIVER:
		return Constants.CollisionLayer.River
	elif type == VALUES.ICE:
		return Constants.CollisionLayer.Ice
	return Constants.CollisionLayer.Default

## 根据精灵位置索引
static func get_sprite_index(type: VALUES):
	if type == VALUES.WALL:
		return 0
	elif type == VALUES.GRID:
		return 1
	elif type == VALUES.GRASS:
		return 2
	elif type == VALUES.RIVER:
		return 3
	elif type == VALUES.ICE:
		return 4
	return -1
