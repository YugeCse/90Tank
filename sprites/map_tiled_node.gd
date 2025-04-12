class_name MapTiledNode
extends Sprite2D

## 地砖类型
@export
var tiled_type: int

@onready
var body: StaticBody2D = $TiledStaticBody

@onready
var collisionShape: CollisionShape2D = $TiledStaticBody/CollisionShape2D

## 初始化方法
func _ready() -> void:
	self.set_tiled_type(tiled_type)

## 设置地砖类型
func set_tiled_type(type: int):
	tiled_type = type
	var tiled_sheet = load("res://assets/images/map_tiled.png")
	if type == MapTiledType.NONE:
		remove_child($TiledStaticBody)
		return
	elif type == MapTiledType.GRASS:
		remove_child($TiledStaticBody)
		self.texture = _get_tiled_atlas(tiled_sheet, type)
		return
	self.texture = _get_tiled_atlas(tiled_sheet, type)
	if not body: return # 如果body为空时，不能设置下面的数据
	if type == MapTiledType.ICE or type == MapTiledType.RIVER:
		body.collision_mask = CollisionLayer.HeroTank | CollisionLayer.EnemyTank
	body.collision_layer = MapTiledType.get_tiled_collision_layer(type)

## 获取地图帧
func _get_tiled_atlas(tiled_sheet: Resource, type: int) -> AtlasTexture:
	var x = MapTiledType.get_sprite_index(type)
	var atlas = AtlasTexture.new()
	atlas.atlas = tiled_sheet
	atlas.region = Rect2(x * 16, 0, 16, 16)
	return atlas
