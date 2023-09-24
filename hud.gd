extends CanvasLayer

@onready var scores_collection : FirestoreCollection = Firebase.Firestore.collection('scores')

signal start_game

const uuid = preload("res://uuid.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	scores_collection.error.connect(on_document_error)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	start_game.emit()


func _on_save_btn_pressed():
	var score = get_parent().score
	var name = $NameInput.text
	if name != "" and score != 0:
		var previous_score = await check_if_doc_exists(name)
		if previous_score != 0:
			print("document exists")
			if score > previous_score:
				var update_task: FirestoreTask = scores_collection.update(name, 
					{
						'name': name, 
						'score': score
					}
				)
				var document = await update_task.task_finished
		else:
			print("document doesn't exist")
			var add_task: FirestoreTask = scores_collection.add(name, 
				{
					'name': name, 
					'score': score
				}
			)
			var document = await add_task.task_finished
	$NameInput.clear()
	hide_save_score()
	$Message.text = "Dodge the\nCreeps!"
	$StartButton.show()
	
func check_if_doc_exists(name) -> int:
	var document_task = scores_collection.get_doc(name)
	var document = await document_task.get_document
	print(document)
	if document != null:
		return document.doc_fields.score
	return 0


func _on_skip_btn_pressed():
	$NameInput.clear()
	hide_save_score()
	$Message.text = "Dodge the\nCreeps!"
	$StartButton.show()
