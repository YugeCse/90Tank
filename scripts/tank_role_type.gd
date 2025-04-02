class_name TankRoleType

## 枚举值
enum VALUES {
	## 英雄
	Hero = 0,
	## 敌人1
	Enemy1 = 1,
	## 敌人2
	Enemy2 = 2,
	## 敌人3
	Enemy3 = 3
}

## 获取角色对应的sprite表数据
static func get_role_sprite_sheet(role: VALUES):
	if role == VALUES.Hero :
		return load("res://assets/images/tank_hero.png")
	elif role == VALUES.Enemy1:
		return load("res://assets/images/tank_enemy_1.png")
	elif role == VALUES.Enemy2:
		return load("res://assets/images/tank_enemy_2.png")
	elif role == VALUES.Enemy3:
		return load("res://assets/images/tank_enemy_3.png")
	return load("res://assets/images/tank_hero_1.png")
