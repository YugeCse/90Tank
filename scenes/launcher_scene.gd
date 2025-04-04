extends CanvasItem

## 准备方法
func _ready() -> void:
	get_viewport().size_changed\
		.connect(_adjust_nodes_location)
	_adjust_nodes_location()
	_show_menu_animation()
	_load_game_main_scene()

func _draw() -> void:
	draw_rect(get_viewport()\
		.get_visible_rect(), Color.BLACK)

## 调整节点位置
func _adjust_nodes_location():
	var game_size = get_viewport().get_visible_rect().size
	var menu_size = $MenuClipContainer.size
	$MenuClipContainer.position = (game_size - menu_size) / 2.0

## 显示菜单的动画
func _show_menu_animation():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($MenuClipContainer/Menu, "position:y", 0, 1.5)
	tween.finished.connect(_load_game_main_scene)

## 加载游戏主界面
func _load_game_main_scene():
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://scenes/game_main_scene.tscn")
