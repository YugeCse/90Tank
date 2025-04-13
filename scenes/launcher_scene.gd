extends CanvasItem

## 准备方法
func _ready() -> void:
	self.set_process(true)
	get_viewport().size_changed\
		.connect(_adjust_nodes_location)
	_adjust_nodes_location()
	_show_menu_animation()

func _process(delta: float) -> void:
	if Input.is_action_pressed(&"ui_start_game"):
		_load_game_main_scene() # 加载主要游戏场景

func _draw() -> void:
	draw_rect(get_window().get_visible_rect(), Color.BLACK)

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
	tween.finished.connect(_show_player_select_indicator)

## 显示游戏选择器
func _show_player_select_indicator():
	var indicator = TextureRect.new()
	indicator.set_size(Vector2(28, 28))
	indicator.position = Vector2(130, 250)
	indicator.texture = load('res://assets/images/tank_select_indicator.png')
	$MenuClipContainer.add_child(indicator) # 添加tank的指示器

## 加载游戏主界面
func _load_game_main_scene():
	get_tree().change_scene_to_file("res://scenes/game_main_scene.tscn")
