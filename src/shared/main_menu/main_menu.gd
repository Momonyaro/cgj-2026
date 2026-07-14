extends Node

func _enter_tree():
	SFX.play("murmur_looping") # Audience sounds

func play():
	Stage.level_loader.load_next()
	$LogoTransitionOut.play("trans_out")
	SFX.play("button_click")
	SFX.fade_out("murmur_looping") # Fade out audience talking
