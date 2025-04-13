## 坦克创建器
class_name TankCreator
extends Node

## 创建位置为左边
const CREATE_LOCATION_LEFT = -1

## 创建位置为中心
const CREATE_LCOATION_CENTER = 0

## 创建位置为右边
const CREATE_LOCATION_RIGHT = 1

## 获取创建的位置
func _get_create_location(value: int):
	if value == CREATE_LOCATION_LEFT:
		return Vector2(Constants.WarMapTiledSize, Constants.WarMapTiledSize)
	elif value == CREATE_LOCATION_RIGHT:
		return Vector2(Constants.WarMapSize - Constants.WarMapTiledSize, Constants.WarMapTiledSize)
	return Vector2(Constants.WarMapSize / 2.0, Constants.WarMapTiledSize)

## 创建英雄坦克
func create_hero_tank():
	var tank: TankNode = preload("res://sprites/tank_node.scn").instantiate()
	tank.role = TankRoleType.Hero
	tank.current_direction = Vector2.UP
	tank.position = Vector2(Constants.WarMapTiledBigSize * 4.5, \
		Constants.WarMapSize - Constants.WarMapTiledBigSize/2.0)
	var boundary_min = Vector2.ZERO
	var boundary_max = Vector2(Constants.WarMapSize, Constants.WarMapSize)
	tank.boundary_min = boundary_min
	tank.boundary_max = boundary_max
	return tank

## 创建敌方坦克
func create_enemy_tank(role: int,create_location: int):
	assert(role != TankRoleType.Hero, "创建的坦克对象不能是英雄坦克")
	var position = _get_create_location(create_location)
	var tank: TankNode = preload("res://sprites/tank_node.scn").instantiate()
	tank.role = role
	match role:
		TankRoleType.Enemy1:
			tank.speed = 130
		TankRoleType.Enemy2:
			tank.speed = 180
		TankRoleType.Enemy3:
			tank.speed = 140
	tank.current_direction = Vector2.DOWN
	tank.position = position
	var boundary_min = Vector2.ZERO
	var boundary_max = Vector2(Constants.WarMapSize, Constants.WarMapSize)
	tank.boundary_min = boundary_min
	tank.boundary_max = boundary_max
	return tank
