class_name BattleSystem extends Node2D

signal battle_started()
signal battle_paused(value: bool)
signal battle_ended()

@export var playerData: BattleActorData # change to BattleActor later
@export var enemyData: BattleActorData # change to BattleActor later
@export var battleActorScene: Resource

var paused: bool: set = set_paused

enum Battle_Group {PLAYER, ENEMY}
var battle_actors_by_group = {}

func _init() -> void:
	var new_array: Array[BattleActor] = []
	battle_actors_by_group[Battle_Group.PLAYER] = new_array.duplicate(false)
	battle_actors_by_group[Battle_Group.ENEMY] = new_array.duplicate(false)


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


func _on_pause_button_pressed() -> void:
	paused = not paused
	print(get_battle_actors_by_group())
	print(get_battle_actors_from_group(Battle_Group.PLAYER))
	print(get_battle_actors_from_group(Battle_Group.ENEMY))


func generate_battle_actor(_data: BattleActorData, _left_side: bool) -> void:
	var instance = battleActorScene.instantiate() as BattleActor
	instance.data = _data
	instance.face_left(not _left_side)
	instance.generate_ability_nodes(self)
	instance.battleUI_ability_required.connect(on_battleUI_ability_required)
	battle_started.connect(instance.pick_ability)
	if _left_side:
		instance.battle_group = Battle_Group.PLAYER
		battle_actors_by_group[Battle_Group.PLAYER].push_back(instance)
		$LeftSide.add_child(instance)
	else:
		instance.battle_group = Battle_Group.ENEMY
		battle_actors_by_group[Battle_Group.ENEMY].push_back(instance)
		$RightSide.add_child(instance)


func on_battleUI_ability_required(actor: BattleActor) -> void:
	set_paused(true)
	print("need to pick ability and launch UI")
	$AbilitySelectorUI.generate_ability_buttons(actor)
	$AbilitySelectorUI.visible = true


func _on_ability_button_pressed(_ability: Ability) -> void:
	paused = false


func get_target_selected() -> BattleActor:
	return null


func get_battle_actors_from_group(_side: Battle_Group) -> Array[BattleActor]:
	return battle_actors_by_group[_side]


func get_battle_actors_by_group() -> Dictionary:
	return battle_actors_by_group.duplicate(true)


# signal for death?
# all loot to lootCollection
# onDeath check if all battleActors on one side is dead
# if so, then win/lose
