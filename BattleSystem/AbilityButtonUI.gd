extends Button
class_name AbilityButtonUI

var ability: Ability

signal ability_button_pressed(ability: Ability)


func update_ability_data(_ability: Ability) -> void:
	ability = _ability
	set_text(ability.data.alias)
	visible = true
	disabled = ability.state != AbilityData.State.IDLE


func _on_pressed() -> void:
	ability_button_pressed.emit(ability)

