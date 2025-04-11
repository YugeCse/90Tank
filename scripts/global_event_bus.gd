extends Node
## 总部被摧毁
signal master_damaged()
## 玩家被击毙
signal player_damaged()
## 敌人被击毙
signal enemy_damaged(TankNode)
## 显示加强道具
signal show_strong_prop()
## 坦克获得道具
signal tank_get_prop(tank: TankNode, prop_type: int)

func _ready():
	pass # Replace with function body

# 应用信号玩家基地被摧毁
func apply_master_damage():
	emit_signal("master_damaged")

# 应用信号玩家被击毙
func apply_player_damage():
	emit_signal("player_damaged")

# 应用信号敌人被击毙
func apply_enemy_damage(tank: TankNode):
	emit_signal("enemy_damaged", tank)

# 应用信号显示加强道具
func apply_show_strong_prop():
	emit_signal("show_strong_prop")

# 应用信号坦克获得道具
func apply_tank_get_prop(tank: TankNode, prop_type: int):
	emit_signal("tank_get_prop", tank, prop_type)
