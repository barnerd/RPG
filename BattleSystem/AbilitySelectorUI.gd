extends PanelContainer

@export var ability_button_scene: Resource
var current_actor: BattleActor
var enabled: bool

signal ability_selected(ability: Ability)


func generate_ability_buttons(actor: BattleActor) -> void:
	if enabled:
		current_actor = actor
		for i in actor.abilities:
			var instance = ability_button_scene.instantiate() as AbilityButtonUI
			instance.update_ability_data(i)
			instance.ability_button_pressed.connect(_on_ability_button_pressed)
			$HBoxContainer.add_child(instance)
		visible = true


func _on_ability_button_pressed(ability: Ability) -> void:
	current_actor.active_ability = ability
	# TODO: set targets via UI
	var battle_system = $".." as BattleSystem
	current_actor.active_ability.set_targets(battle_system.get_battle_actors_from_group(battle_system.Battle_Group.ENEMY))
	
	current_actor.start_ability()
	# destroy ability_buttons
	for i in $HBoxContainer.get_children():
		i.queue_free()
	visible = false
	ability_selected.emit(ability)


func enable_UI(_enable: bool) -> void:
	enabled = _enable
