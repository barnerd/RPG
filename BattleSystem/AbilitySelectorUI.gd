extends PanelContainer

@export var ability_button_scene: Resource
var current_actor: BattleActor

signal ability_selected(ability: Ability)


func generate_ability_buttons(actor: BattleActor) -> void:
	print("creating UI buttons for abilities for " + actor.data.alias)
	print("the player has " + str(actor.abilities.size()) + " abilities")
	current_actor = actor
	for i in actor.abilities:
		var instance = ability_button_scene.instantiate() as AbilityButtonUI
		instance.update_ability_data(i)
		instance.ability_button_pressed.connect(_on_ability_button_pressed)
		$HBoxContainer.add_child(instance)


func _on_ability_button_pressed(ability: Ability) -> void:
	current_actor.active_ability = ability
	current_actor.start_ability()
	# destory ability_buttons
	for i in $HBoxContainer.get_children():
		i.queue_free()
	visible = false
	ability_selected.emit(ability)
