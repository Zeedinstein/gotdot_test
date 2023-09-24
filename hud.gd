extends CanvasLayer

@onready var scores_collection : FirestoreCollection = Firebase.Firestore.collection('scores')

signal start_game

const uuid = preload("res://uuid.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	$HighScoreList.hide()
	$CloseHighScoreBtn.hide()
	scores_collection.error.connect(on_document_error)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func on_document_error(code, status, message):
	print("document error code: "+str(code))
	print("document error status: "+str(status))
	print("document error message: "+str(message))

func hide_save_score():
	$NameInput.hide()
	$NameLbl.hide()
	$SaveBtn.hide()
	$SkipBtn.hide()

func show_save_score():
	$NameInput.show()
	$NameLbl.show()
	$SaveBtn.show()
	$SkipBtn.show()

func hide_message():
	$Message.hide()
	$MessageTimer.stop()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout

	$Message.text = "Save Score"
	$Message.show()
	show_save_score()

	# Create delay
	# await get_tree().create_timer(1.0).timeout

func update_score(score):
	$ScoreLabel.text = str(score)


func _on_message_timer_timeout():
	$Message.hide()


func _on_start_button_pressed():
	$StartButton.hide()
	$ShowHighScoreBtn.hide()
	start_game.emit()


func _on_save_btn_pressed():
	var score = get_parent().score
	var player_name = $NameInput.text
	if player_name != "" and score != 0:
		var previous_score = await check_if_doc_exists(player_name)
		if previous_score != 0:
			print("document exists")
			if score > previous_score:
				var update_task: FirestoreTask = scores_collection.update(player_name,
					{
						'name': player_name,
						'score': score
					}
				)
				await update_task.task_finished
		else:
			print("document doesn't exist")
			var add_task: FirestoreTask = scores_collection.add(player_name,
				{
					'name': player_name,
					'score': score
				}
			)
			await add_task.task_finished
	$NameInput.clear()
	hide_save_score()
	$Message.text = "Dodge the\nCreeps!"
	$StartButton.show()
	$ShowHighScoreBtn.show()

func check_if_doc_exists(player_name) -> int:
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("scores").where("name", FirestoreQuery.OPERATOR.EQUAL, player_name)
	var document: Array = await Firebase.Firestore.query(query).result_query
	print(document)
	if document.size() > 0:
		return document[0].doc_fields.score
	return 0


func _on_skip_btn_pressed():
	$NameInput.clear()
	hide_save_score()
	$Message.text = "Dodge the\nCreeps!"
	$StartButton.show()
	$ShowHighScoreBtn.show()


func _on_show_high_score_pressed():
	hide_message()
	hide_save_score()
	$ShowHighScoreBtn.hide()
	$StartButton.hide()
	$HighScoreList.show()
	$CloseHighScoreBtn.show()
	# Create query
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("scores")
	query.order_by("score", FirestoreQuery.DIRECTION.DESCENDING)
	query.limit(10)
	var result: Array = await Firebase.Firestore.query(query).result_query
	print(result)

	for i in range(0, result.size()):
		var _name = result[i].doc_fields.name
		var score = result[i].doc_fields.score
		$HighScoreList.add_item(str(i+1)+". "+_name+" - "+str(score))


func _on_close_high_score_btn_pressed():
	$HighScoreList.clear()
	$HighScoreList.hide()
	$CloseHighScoreBtn.hide()
	show_message("Dodge the\nCreeps!")
	$ShowHighScoreBtn.show()
	$StartButton.show()
