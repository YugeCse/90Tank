## 道具创建类，放置在主场景中
class_name PropCreator
extends Node

## 坦克加强道具
var _tank_strong_prop: PropNode

## 坦克道具预制体
@onready
var _tank_prop_prefab = preload('res://sprites/prop_node.tscn')

## 显示玩家道具
func show_player_prop(parentNode: Node):
	self.dismiss_player_prop(true)
	var prop_type = [\
		PropNode.TYPE_MASTER, \
		PropNode.TYPE_TANK, \
		PropNode.TYPE_HAT, \
		PropNode.TYPE_BOMB, \
		PropNode.TYPE_TIMER, \
		PropNode.TYPE_STAR][randi() % 6]
	_tank_strong_prop = _tank_prop_prefab.instantiate() as PropNode
	_tank_strong_prop.prop_type = prop_type
	_tank_strong_prop.position = Vector2(
		randi_range(Constants.WarMapTiledSize, \
			Constants.WarMapSize - Constants.WarMapTiledSize),
		randi_range(Constants.WarMapTiledSize, \
			Constants.WarMapSize - Constants.WarMapTiledSize))
	parentNode.add_child(_tank_strong_prop) # 添加道具地图


## 隐藏玩家道具节点
func dismiss_player_prop(is_directly_free: bool = false):
	if _tank_strong_prop: # 如果这个对象存在
		if not is_directly_free:
			_tank_strong_prop.show_score_then_dispose()
		else:
			_tank_strong_prop.free() # 直接注销节点
	_tank_strong_prop = null # 置空对象
