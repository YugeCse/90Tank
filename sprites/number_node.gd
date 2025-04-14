## 数字节点类
class_name NumberNode
extends HBoxContainer

## 要设置的数字
@export
var number: int = 0

## 数字图片资源路径
var number_atlas_path: String = \
	'res://assets/images/num_{num}.png'

func _ready() -> void:
	self.pivot_offset = Vector2(0.5, 0.5)
	self.set_number(number)
	size_flags_horizontal = Control.SIZE_EXPAND

## 设置数字
func set_number(value: int):
	_clear_children()
	var count = 0
	var value_str = str(value)
	for num_text in value_str:
		count += 1
		var num = int(num_text)
		self._add_number(num)
	self.number = value # 数字赋值
	self.size = Vector2(count * 14.0, 14.0)
	self.custom_minimum_size = Vector2(count * 14.0, 14.0)

## 添加数字字符
func _add_number(num: int):
	var num_sprite = TextureRect.new()
	num_sprite.size = Vector2(14, 14)
	num_sprite.texture = load(\
		number_atlas_path \
		.format({'num': num}))
	self.add_child(num_sprite)

## 清理所有子节点
func _clear_children():
	var children = get_children()
	for child in children:
		child.queue_free()
