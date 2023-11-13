extends Node2D
class_name BattleSystem

signal battle_started()
signal battle_paused(value: bool)
signal battle_ended()

@export var playerData: BattleActorData # change to BattleActor later
@export var enemyData: BattleActorData # change to BattleActor later
const battleActorScene = preload("res://BattleSystem/BattleActors/battle_actor.tscn")

var paused: bool: set = set_paused

enum Battle_Group {PLAYER, ENEMY}


func _ready() -> void:
	# flash start banner and then emit
	$AbilitySelectorUI.visible = false
	generate_battle_actor(playerData, true)
	generate_battle_actor(enemyData, false)
	battle_started.emit()


func set_paused(value: bool) -> void:
	paused = value
	print ("paused: " + ("True" if paused else "False"))
	# call signal to pause/unpause battle elements
	battle_paused.emit(paused)


func flip_paused() -> void:
	paused = not paused


func generate_battle_actor(_data: BattleActorData, _left_side: bool) -> void:
	var instance = battleActorScene.instantiate() as BattleActor
	instance.data = _data
	instance.face_left(not _left_side)
	instance.generate_ability_nodes(self)
	instance.battleUI_ability_required.connect(on_battleUI_ability_required)
	battle_started.connect(instance.pick_ability)
	if _left_side:
		instance.battle_group = Battle_Group.PLAYER
		$LeftSide.add_child(instance)
	else:
		instance.battle_group = Battle_Group.ENEMY
		$RightSide.add_child(instance)


func on_battleUI_ability_required(actor: BattleActor) -> void:
	flip_paused()
	print("need to pick ability and launch UI")
	$AbilitySelectorUI.generate_ability_buttons(actor)
	$AbilitySelectorUI.visible = true


func on_ability_button_pressed(_ability: Ability) -> void:
	paused = false


# signal for death?
# all loot to lootCollection
# onDeath check if all battleActors on one side is dead
# if so, then win/lose
