class_name BattleSystem extends Node2D

signal battle_started()
signal battle_paused(value: bool)
signal battle_ended()
signal battle_won()
signal battle_lost()

@export var playerData: BattleActorData # change to BattleActor later
@export var enemyData: BattleActorData # change to BattleActor later
@export var battleActorScene: Resource

@onready var combat_calculator = $"Combat Calculator"

var paused: bool: set = set_paused

enum Battle_Group {PLAYER, ENEMY}
var battle_actors_by_group = {}


func _init() -> void:
	battle_actors_by_group[Battle_Group.PLAYER] = [] as Array[BattleActor]
	battle_actors_by_group[Battle_Group.ENEMY] = [] as Array[BattleActor]


func _ready() -> void:
	# flash start banner and then emit
	$AbilitySelectorUI.visible = false
	generate_battle_actor(playerData, true)
	generate_battle_actor(enemyData, false)
	battle_started.emit()


func set_paused(value: bool) -> void:
	paused = value
	# print ("paused: " + ("True" if paused else "False"))
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
	instance.alias = instance.data.alias # add to name for multiple, i.e. Skeleton A, Skeleton B
	instance.battle_system = self
	instance.face_left(not _left_side)
	instance.generate_ability_nodes(self)
	instance.battleUI_ability_required.connect(on_battleUI_ability_required)
	instance.actor_died.connect(on_actor_died)
	battle_started.connect(instance.pick_ability)
	if _left_side:
		instance.battle_group = Battle_Group.PLAYER
		battle_actors_by_group[Battle_Group.PLAYER].push_back(instance)
		$LeftSide.add_child(instance)
	else:
		instance.battle_group = Battle_Group.ENEMY
		battle_actors_by_group[Battle_Group.ENEMY].push_back(instance)
		$RightSide.add_child(instance)


func on_actor_died(_actor: BattleActor) -> void:
	print("battle system knows that " + _actor.alias + " has died")
	# remove actor from list
	battle_actors_by_group[_actor.battle_group].erase(_actor)
	# if last actor on side, win/lose
	if battle_actors_by_group[_actor.battle_group].size() == 0:
		if _actor.battle_group == Battle_Group.PLAYER:
			_on_battle_loss()
		else:
			_on_battle_win()
	# have each actor check their targets
	else:
		for i in battle_actors_by_group:
			for j in battle_actors_by_group[i]:
				battle_actors_by_group[i][j].check_targets(_actor)


func on_battleUI_ability_required(_actor: BattleActor) -> void:
	set_paused(true)
	$AbilitySelectorUI.generate_ability_buttons(_actor)


func _on_ability_button_pressed(_ability: Ability) -> void:
	paused = false


func get_target_selected() -> BattleActor:
	return null


func get_battle_actors_from_group(_side: Battle_Group) -> Array[BattleActor]:
	return battle_actors_by_group[_side]


func get_battle_actors_by_group() -> Dictionary:
	return battle_actors_by_group.duplicate(true)


func _on_battle_win() -> void:
	battle_won.emit()
	print("Battle Won!")
	_on_battle_end()


func _on_battle_loss() -> void:
	battle_lost.emit()
	print("Battle Loss!")
	_on_battle_end()


func _on_battle_end() -> void:
	battle_ended.emit()
	battle_paused.emit(true)


# signal for death?
# all loot to lootCollection
# onDeath check if all battleActors on one side is dead
# if so, then win/lose
