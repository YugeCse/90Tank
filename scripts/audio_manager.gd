class_name AudioManager
extends Node

## 是否允许播放音效
@export
var allow_play_sound: bool = true

## 动态创建并播放音效
func play_sound(sound_path: String):
	var player = AudioStreamPlayer.new()
	player.stream = load(sound_path)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)  # 播放完成后自动删除

## 播放游戏开始的音效
func play_game_start():
	play_sound("res://assets/audios/start.mp3")

## 播放道具音效
func play_prop():
	play_sound("res://assets/audios/prop.mp3")

## 播放攻击音效
func play_attack_sound():
	play_sound("res://assets/audios/attack.mp3")

## 播放坦克移动的音效
func play_tank_move_sound():
	play_sound("res://assets/audios/move.mp3")

## 播放子弹碰撞的声音
func play_bullet_crack():
	play_sound("res://assets/audios/bulletCrack.mp3")

## 播放玩家被打击的音效
func play_player_crack():
	play_sound("res://assets/audios/playerCrack.mp3")

## 播放坦克被打击的音效
func play_tank_crack():
	play_sound("res://assets/audios/tankCrack.mp3")
