extends Node
## 常量Constants
class_name Constants

## 地图地块的大小: 16
const WarMapTiledSize = 16

## 地图地砖2倍的大小: 32
const WarMapTiledBigSize = 32

## 战场地图地砖数量: 26
const WarMapTiledCount: int = 26

## 战场地图的大小: 26 x 16
const WarMapSize = WarMapTiledCount * WarMapTiledSize

## 敌方坦克总数
const ENEMY_TOTAL_COUNT = 20

## 玩家定时器道具的限制时间 - 15s
const PLAYER_PROP_TIMER_LIMIT_TIMER = 15

## 玩家基地被保护的限制时间 - 20s
const PLAYER_MASTER_PROTECT_LIMIT_TIME = 20

## 方向枚举
enum Direction {
	UP = 1,
	DOWN = 2,
	LEFT = 3,
	RIGHT = 4,
	ZERO = 0
}

## 通过方向获取Vector2
static func get_vec2_by_direction(dir: Direction) -> Vector2:
	if dir == Direction.UP:
		return Vector2.UP
	elif dir == Direction.DOWN:
		return Vector2.DOWN
	elif dir == Direction.LEFT:
		return Vector2.LEFT
	elif dir == Direction.RIGHT:
		return Vector2.RIGHT
	return Vector2.ZERO

## 通过Vector2获取方向
static func get_direction_by_vec2(dir: Vector2) -> Direction:
	if dir == Vector2.UP:
		return Direction.UP
	elif dir == Vector2.DOWN:
		return Direction.DOWN
	elif dir == Vector2.LEFT:
		return Direction.LEFT
	elif dir == Vector2.RIGHT:
		return Direction.RIGHT
	return Direction.ZERO
