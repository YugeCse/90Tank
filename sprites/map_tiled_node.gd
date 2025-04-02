class_name MapTiledNode
extends Sprite2D

@export var tiled_type: MapTiledType.VALUES

func _ready() -> void:
	self.set_tiled_type(tiled_type)

## 获取地图帧
func _get_tiled_atlas(tiled_sheet: Resource, type: MapTiledType.VALUES) -> AtlasTexture:
	var x = MapTiledType.get_sprite_index(type)
	var atlas = AtlasTexture.new()
	atlas.atlas = tiled_sheet
	atlas.region = Rect2(x * 16, 0, 16, 16)
	return atlas

## 设置地砖类型
func set_tiled_type(type: MapTiledType.VALUES):
	tiled_type = type
	var tiled_sheet = load("res://assets/images/map_tiled.png")
	if type == MapTiledType.VALUES.NONE:
		remove_child($StaticBody2D)
		return
	elif type == MapTiledType.VALUES.GRASS:
		self.texture = _get_tiled_atlas(tiled_sheet, type)
		remove_child($StaticBody2D)
		return
	self.texture = _get_tiled_atlas(tiled_sheet, type)
	$StaticBody2D.collision_layer = MapTiledType.get_tiled_collision_layer(type)

## 获取碰撞层
func get_collision_layer() -> int:
	return $StaticBody2D.collision_layer
