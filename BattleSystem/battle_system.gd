extends Node2D
class_name BattleSystem

signal battle_started()
signal battle_paused(value: bool)
signal battle_ended()

@export var playerData: BattleActorData # change to BattleActor later
@export var enemyData: BattleActorData # change to BattleActor later
const battleActorScene = preload("res://BattleSystem/BattleActors/battle_actor.tscn")

var paused: bool: set = set_paused


func _ready() -> void:
	# flash start banner and then emit
	generate_battle_actor(playerData, true)
	generate_battle_actor(enemyData, false)
	battle_started.emit()


func set_paused(value: bool = true) -> void:
	paused = value
	# call signal to pause/unpause battle elements
	battle_paused.emit(paused)


func generate_battle_actor(_data: BattleActorData, _left_side: bool) -> void:
	var instance = battleActorScene.instantiate() as BattleActor
	instance.data = _data
	instance.face_left(not _left_side)
	instance.generate_ability_nodes(self)
	battle_started.connect(instance.pick_ability)
	if _left_side:
		$LeftSide.add_child(instance)
	else:
		$RightSide.add_child(instance)


# signal for death?
# all loot to lootCollection
# onDeath check if all battleActors on one side is dead
# if so, then win/lose
