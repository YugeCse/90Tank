class_name TankRoleType

## 英雄
const Hero = 0
## 敌人1
const Enemy1 = 1
## 敌人2
const Enemy2 = 2
## 敌人3
const Enemy3 = 3

## 获取角色对应的sprite表数据
static func get_role_sprite_sheet(role: int):
	if role == Hero :
		return load("res://assets/images/tank_hero.png")
	elif role == Enemy1:
		return load("res://assets/images/tank_enemy_1.png")
	elif role == Enemy2:
		return load("res://assets/images/tank_enemy_2.png")
	elif role == Enemy3:
		return load("res://assets/images/tank_enemy_3.png")
	return load("res://assets/images/tank_hero_1.png")

## 根据坦克角色获取得分
static func get_score_by_role(role: int):
	if role == Enemy1:
		return 100
	elif role == Enemy2:
		return 200
	elif role == Enemy3:
		return 500
	return 100
