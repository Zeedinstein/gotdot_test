extends Control

signal logged_in

func _ready():
	Firebase.Auth.login_succeeded.connect(_on_FirebaseAuth_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(_on_FirebaseAuth_login_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)

func _on_login_pressed():
	var email = $email.text
	var password = $password.text
	Firebase.Auth.login_with_email_and_password(email, password)

func _on_register_pressed():
	var email = $email.text
	var password = $password.text
	Firebase.Auth.signup_with_email_and_password(email, password)

func _on_FirebaseAuth_login_succeeded(_auth):
	print(_auth)
	var user = await Firebase.Auth.get_user_data()
	print(user)
	logged_in.emit()
	
func on_login_failed(error_code, message):
	print("error code: " + str(error_code))
	print("message: " + str(message))

func on_signup_failed(error_code, message):
	print("error code: " + str(error_code))
	print("message: " + str(message))
