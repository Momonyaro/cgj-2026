extends Node

func _enter_tree():
	SFX.play("murmur_looping") # Audience sounds


func _ready():
	if OS.has_feature("web"):
		$TextureButton.queue_free()
	Stage.reset_spotlights.call_deferred()


func _unhandled_input(event):
	if event.is_pressed() and event is InputEventKey:
		if event.keycode == KEY_L:
			if FileAccess.file_exists("user://save0.dat"):
				DirAccess.remove_absolute("user://save0.dat")
				Save.clear()
				print("Save Forgorgen... Whomstd've could've done this")


func play():
	ScoreManager.clear_score()
	Stage.level_loader.load_next()
	$LogoTransitionOut.play("trans_out")
	SFX.play("button_click")
	SFX.fade_out("murmur_looping") # Fade out audience talking


func _on_exit_game():
	get_tree().quit()
