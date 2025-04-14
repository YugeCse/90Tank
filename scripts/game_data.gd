## 游戏数据类声明
class_name GameData

## 默认关卡，数值：1
static var stage_level: int = 1

## 玩家生命数
static var player_life: int = 3

## 重置数据
static func resetData():
	player_life = 3  # 重置玩家生命数
