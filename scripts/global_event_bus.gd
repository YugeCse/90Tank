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
