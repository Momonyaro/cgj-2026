extends CanvasLayer

func _ready():
	$AnimationPlayer.play("intro")
	SFX.play("money")
	
	var score = ScoreManager._score # We don't want the lerped value for this
	var money = score / 100.0 # 50 pts -> $0.5
	var money_str = str("$%.2f" % money)
	$Panel2/DollarPoints.text = money_str
	
	var last_highscore: int = floori(Save.read("highscore", 0))
	$Panel2/HIGHSCORE.visible = score > last_highscore
	
	if score > last_highscore:
		Save.write("highscore", score)
		Save.save_slot()
	

func _on_exit_to_menu():
	SFX.play("button_click")
	Stage.level_loader.load_main_menu()
	pass
