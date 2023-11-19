extends Node2D

var codeHandlers
var codeInput
var codes
var codeToId = {
	"catnip": 0,
	"pigeon":1,
	"rainbow rat":2,
	"rainbow jump":3,
	"ghost rat":4,
	"lab rat":5
}

signal close_settings

# Called when the node enters the scene tree for the first time.
func _ready():
	codeInput = $CheatCodes/CodeInput
	codeHandlers = [
		$CheatCodes/Codes/Catnip,
		$CheatCodes/Codes/InfiniteJump,
		$CheatCodes/Codes/RainbowRat,
		$CheatCodes/Codes/ChangeOnJump,
		$CheatCodes/Codes/Ghost,
		$CheatCodes/Codes/LabRat
	]
	
# close settings menus
func _on_Close_button_down():
	if $CheatCodes.visible:
		$CheatCodes.visible = false
		$Main.visible = true
	else:
		self.visible = false
		emit_signal("close_settings")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $CheatCodes.visible and Input.is_action_just_pressed("Enter"):
		codeInput.text = codeInput.text.substr(0,codeInput.text.length()-1)
		processCodeEntry()
	if Input.is_action_just_pressed("Pause"):
		self.visible = false;
		$CheatCodes.visible = false;
#	pass

# CHEAT CODES
# activate/deactivate code
func setCode(var id, var active):
	Globals.codes[id] = active
	if active:
		codeHandlers[id].get_child(0).text = "x"
	else:
		codeHandlers[id].get_child(0).text = ""

# enter current code
func processCodeEntry():
	var code = codeInput.text.to_lower()
	var index
	if code == "dev mode":
		for key in codeToId:
			index = codeToId[key]
			setCode(index, true)
			Globals.foundCodes[index] = true
			codeHandlers[index].text = key
			codeHandlers[index].get_child(0).visible = true
			codeHandlers[index].get_child(1).visible = true
		codeInput.text = ""
		return
		
	if !codeToId.has(code):
		codeInput.text = ""
		$CheatCodes/InvalidCode.visible = true
		return
		
	index = codeToId[code]
	
	if index != -1:
		setCode(index, true)
		Globals.foundCodes[index] = true
		codeHandlers[index].text = code
		codeHandlers[index].get_child(0).visible = true
		codeHandlers[index].get_child(1).visible = true
		
	codeInput.text = ""
func _on_EnterCode_button_down():
	processCodeEntry()
		
# clean text input
func _on_CodeInput_text_changed():
	$CheatCodes/InvalidCode.visible = false
	var text =  codeInput.text
	codeInput.text = text.substr(0,15)
	codeInput.cursor_set_column(text.length())
	$CheatCodes/TypeCode.visible = !$CheatCodes/InvalidCode.visible and codeInput.text==""

# toggle codes
func _on_Catnip_toggle_code():
	toggleCode(0)
func _on_InfiniteJump_toggle_code():
	toggleCode(1)
func _on_RainbowRat_toggle_code():
	toggleCode(2)
func _on_ChangeOnJump_toggle_code():
	toggleCode(3)
func _on_Ghost_toggle_code():
	toggleCode(4)
func _on_LabRat_toggle_code():
	toggleCode(5)

func toggleCode(var id):
	setCode(id, !Globals.codes[id])

# open cheat code menu
func _on_OpenCheatCodes_button_down():
	# set visibility
	$Main.visible = false
	codeInput.text = ""
	$CheatCodes/TypeCode.visible = true
	$CheatCodes/InvalidCode.visible = false
	for key in codeToId:
		setCodeHandler(key)
	
	# display menu
	$CheatCodes.visible = true;
func setCodeHandler(var code):
	var id = codeToId[code]
	# if found, code text and check box visible
	if Globals.foundCodes[id]:
		codeHandlers[id].get_child(0).visible = true
		codeHandlers[id].get_child(1).visible = true
		codeHandlers[id].text = code
	else:
		codeHandlers[id].get_child(0).visible = false
		codeHandlers[id].get_child(1).visible = false
		codeHandlers[id].text = "???"
	
	# if active, check box checked
	if Globals.codes[id]:
		codeHandlers[id].get_child(0).text= "x"
	else:
		codeHandlers[id].get_child(0).text= ""
	$CheatCodes.visible =false
