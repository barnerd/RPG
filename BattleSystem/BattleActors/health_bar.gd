extends RichTextLabel

func _on_battle_actor_health_changed(old_value, new_value) -> void:
	set_text("Health: " + str(new_value))
