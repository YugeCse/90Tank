class_name TankState extends Resource
enum { BORN, ALIVE, STRONG, DEAD }

@export var value: int = ALIVE:
	set(v):
		if v in [BORN, ALIVE, STRONG, DEAD]:
			value = v
		else:
			push_error("无效状态值")
