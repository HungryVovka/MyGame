@tool
extends Control

var scene_config_data = {}
var timelines_list = {}
@onready var scene_folder = $VBoxContainer/TabContainer/Scene/MarginContainer/VBoxContainer/GridContainer/SceneFolder
@onready var scene_file = $VBoxContainer/TabContainer/Scene/MarginContainer/VBoxContainer/GridContainer/SceneFile
@onready var timelines_combobox = $VBoxContainer/TabContainer/Scene/MarginContainer/VBoxContainer/GridContainer/TimelineList
@onready var scale_slider = $VBoxContainer/HSlider

@onready var background_grid = $VBoxContainer/TabContainer/Backgrounds/MarginContainer/ScrollContainer/GridContainer
var background_children_list = []
var background_dict : Dictionary
var background_store: Dictionary

@onready var videos_grid = $VBoxContainer/TabContainer/Videos/MarginContainer/ScrollContainer/GridContainer
var videos_children_list = []
var videos_dict: Dictionary

@onready var audios_grid = $VBoxContainer/TabContainer/Audios/MarginContainer/ScrollContainer/GridContainer
var audios_children_list = []
var audios_dict: Dictionary

@onready var characters_grid = $VBoxContainer/TabContainer/Characters/MarginContainer/ScrollContainer/GridContainer
var characters_children_list = []
var characters_dict: Dictionary

@onready var timeline_box = $VBoxContainer/TabContainer/Timeline/MarginContainer/VBoxContainer/ScrollContainer/TimeLine
@onready var timeline_list_combobox = $VBoxContainer/TabContainer/Timeline/MarginContainer/VBoxContainer/HBoxContainer/TimelinesList
var timeline_children_list = []
var current_timeline: Dictionary = {}
var current_timeline_filename: String = ""

var _file_dialog

func add_custom_project_setting(name: String, default_value, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:
	if ProjectSettings.has_setting(name): return
	var setting_info: Dictionary = {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	}
	ProjectSettings.set_setting(name, default_value)
	ProjectSettings.add_property_info(setting_info)
	ProjectSettings.set_initial_value(name, default_value)

func _ready():
	_on_scene_folder_changed("res://Resources/Scene1/")
	add_custom_project_setting("dialogsystem/scale", 100.0, TYPE_FLOAT)

	restore_scale()

func restore_scale():
	var t = Timer.new()
	t.one_shot = true
	add_child(t)
	t.timeout.connect(func():
		var value = ProjectSettings.get("dialogsystem/scale")
		self.scale = Vector2(value * 1.00 / 100.0, value * 1.00 / 100.0)
		scale_slider.value = value
		)
	t.start(0.01)
	
	
func _on_scene_folder_changed(path):
	var config_path = path + "config.json"
	if !FileAccess.file_exists(config_path):
		save_json(config_path, {})
		_on_scene_folder_changed(path)
	timelines_list = {}
	timelines_combobox.clear()
	timeline_list_combobox.clear()
	scene_config_data = read_json(config_path)
	scene_folder.text = path
	
	var timelines: Array[String] = get_filelist(path + "timelines", ["json"])
	for k in timelines:
		timelines_list[k.get_file().get_basename()] = k
		timelines_combobox.add_item(k.get_file().get_basename())
		timeline_list_combobox.add_item(k.get_file().get_basename())
	timelines_combobox.selected = timelines_list.keys().find(scene_config_data.start)
	scene_file.text = scene_config_data.scene
	
	background_dict = read_json(path + "configs/backgrounds.json")
	clear_backgrounds_objects()
	render_background_objects(background_dict, background_dict)
	
	videos_dict = read_json(path + "configs/videos.json")
	clear_videos_objects()
	render_videos_objects(videos_dict, videos_dict)
	
	audios_dict = read_json(path + "configs/sounds.json")
	clear_audios_objects()
	render_audios_objects(audios_dict, audios_dict)
	
	characters_dict = read_json(path + "configs/characters.json")
	clear_characters_objects()
	render_characters_objects(characters_dict, characters_dict)
	
	
func clear_backgrounds_objects():
	for i in background_children_list:
		i.queue_free()
	background_children_list.clear()
	background_store.clear()
	
func render_background_objects(dict: Dictionary, source: Dictionary):
	for k in dict.keys():
		background_store[k] = load(dict[k])
		var class_obj = preload("res://addons/DialogHelperTool/BackgroundConfigItem/BackgroundConfigItem.tscn")
		var obj = class_obj.instantiate()
		obj.set_source(source, k, background_store)
		background_grid.add_child(obj)
		background_children_list.push_back(obj)
		
func clear_videos_objects():
	for i in videos_children_list:
		i.queue_free()
	videos_children_list.clear()
	
func render_videos_objects(dict: Dictionary, source: Dictionary):
	for k in dict.keys():
		var class_obj = preload("res://addons/DialogHelperTool/VideoConfigItem/VideoConfigItem.tscn")
		var obj = class_obj.instantiate()
		obj.set_source(source, k)
		videos_grid.add_child(obj)
		videos_children_list.push_back(obj)

func clear_audios_objects():
	for i in audios_children_list:
		i.queue_free()
	audios_children_list.clear()
	
func render_audios_objects(dict: Dictionary, source: Dictionary):
	for k in dict.keys():
		var class_obj = preload("res://addons/DialogHelperTool/AudioConfigItem/AudioConfigItem.tscn")
		var obj = class_obj.instantiate()
		obj.set_source(source, k)
		audios_grid.add_child(obj)
		audios_children_list.push_back(obj)

func clear_characters_objects():
	for i in characters_children_list:
		i.queue_free()
	characters_children_list.clear()
	
func render_characters_objects(dict: Dictionary, source: Dictionary):
	for k in dict.characters.keys():
		var class_obj = preload("res://addons/DialogHelperTool/CharacterConfigItem/CharacterConfigItem.tscn")
		var obj = class_obj.instantiate()
		obj.set_source(source.characters, k)
		characters_grid.add_child(obj)
		characters_children_list.push_back(obj)

func _on_scene_entry_changed(path):
	scene_file.text = path
	

func read_json(filename):
	var file = FileAccess.open(filename, FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	return data
	
func save_json(filename, dict):
	var txt = JSON.stringify(dict)
	var file = FileAccess.open(filename, FileAccess.WRITE)
	file.store_string(txt)
	file.flush()
	file.close()

func get_filelist(scan_dir : String, filter_exts : Array = []) -> Array[String]:
	var my_files : Array[String] = []
	var dir = DirAccess.open(scan_dir)
	if dir.list_dir_begin() != OK:
		printerr("Warning: could not list contents of: ", scan_dir)
		return []
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			my_files += get_filelist(dir.get_current_dir() + "/" + file_name, filter_exts)
		else:
			if filter_exts.size() == 0:
				my_files.append(dir.get_current_dir() + "/" + file_name)
			else:
				for ext in filter_exts:
					if file_name.get_extension() == ext:
						my_files.append(dir.get_current_dir() + "/" + file_name)
		file_name = dir.get_next()
	return my_files

func _on_h_slider_drag_ended(value_changed):
	ProjectSettings.set("dialogsystem/scale", scale_slider.value)
	var value = scale_slider.value
	self.scale = Vector2(value * 1.00 / 100.0, value * 1.00 / 100.0)


func _on_folder_picked_pressed():
	if _file_dialog:
		_file_dialog.queue_free()
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.title = "Select scene folder"
	
	add_child(_file_dialog)
	
	_file_dialog.dir_selected.connect(_scene_folder_selected)
	_file_dialog.popup_centered(Vector2i(1080, 640))
	
func _scene_folder_selected(dir):
	_on_scene_folder_changed(dir + "/")
	_file_dialog.queue_free()


func _on_scene_start_pressed():
	if _file_dialog:
		_file_dialog.queue_free()
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.title = "Select starting tscn file"
	_file_dialog.filters = ["*.tscn"]
	
	add_child(_file_dialog)
	
	_file_dialog.file_selected.connect(_scene_entry_selected)
	_file_dialog.popup_centered(Vector2i(1080, 640))
	
func _scene_entry_selected(path):
	_on_scene_entry_changed(path)
	_file_dialog.queue_free()

func _on_remove_background_button_2_pressed():
	var to_remove = []
	for i in background_children_list:
		if i.selected:
			background_dict.erase(i.element_id)
			to_remove.push_back(i)
	for i in to_remove:
		background_children_list.remove_at(background_children_list.find(i))
		i.queue_free()

func _on_add_background_button_pressed():
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.title = "Select images"
	_file_dialog.filters = ["*.png", "*.jpg", "*.jpeg", "*.webp"]
	add_child(_file_dialog)
	
	_file_dialog.files_selected.connect(_on_backgrounds_selected)
	_file_dialog.popup_centered(Vector2i(1080, 640))

func _on_backgrounds_selected(paths: PackedStringArray):
	var newDict = {}
	for p in paths:
		var k = p.get_file().replace("." + p.get_extension(), "")
		if !background_dict.has(k):
			background_dict[k] = p
			newDict[k] = p
	render_background_objects(newDict, background_dict)
	_file_dialog.queue_free()

func _on_margin_container_dropped_data(paths):
	var newDict = {}
	for p in paths:
		var k = p.get_file().replace("." + p.get_extension(), "")
		if !background_dict.has(k):
			background_dict[k] = p
			newDict[k] = p
	render_background_objects(newDict, background_dict)


func _on_save_backgrounds_button_pressed():
	save_json(scene_folder.text + "configs/backgrounds.json", background_dict)


func _on_videos_dropped_data(paths):
	var newDict = {}
	for p in paths:
		if !videos_dict.has(p.get_file()):
			videos_dict[p.get_file()] = p
			newDict[p.get_file()] = p
	render_videos_objects(newDict, videos_dict)

func _on_remove_videos_button_2_pressed():
	var to_remove = []
	for i in videos_children_list:
		if i.selected:
			videos_dict.erase(i.element_id)
			to_remove.push_back(i)
	for i in to_remove:
		videos_children_list.remove_at(videos_children_list.find(i))
		i.queue_free()

func _on_add_videos_button_pressed():
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.title = "Select videos"
	_file_dialog.filters = ["*.ogv"]
	add_child(_file_dialog)
	
	_file_dialog.files_selected.connect(_on_videos_selected)
	_file_dialog.popup_centered(Vector2i(1080, 640))

func _on_videos_selected(paths: PackedStringArray):
	var newDict = {}
	for p in paths:
		var k = p.get_file().replace("." + p.get_extension(), "")
		if !videos_dict.has(k):
			videos_dict[k] = p
			newDict[k] = p
	render_videos_objects(newDict, videos_dict)
	_file_dialog.queue_free()

func _on_save_videos_button_pressed():
	save_json(scene_folder.text + "configs/videos.json", videos_dict)

func _on_reload_button_pressed():
	_on_scene_folder_changed(scene_folder.text)
	
	
func _on_audios_dropped_data(paths):
	var newDict = {}
	for p in paths:
		if !audios_dict.has(p.get_file()):
			audios_dict[p.get_file()] = p
			newDict[p.get_file()] = p
	render_videos_objects(newDict, audios_dict)
	
func _on_remove_audios_button_2_pressed():
	var to_remove = []
	for i in audios_children_list:
		if i.selected:
			audios_dict.erase(i.element_id)
			to_remove.push_back(i)
	for i in to_remove:
		audios_children_list.remove_at(audios_children_list.find(i))
		i.queue_free()

func _on_add_audios_button_pressed():
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.title = "Select audios"
	_file_dialog.filters = ["*.mp3", "*.ogg", "*.wav"]
	add_child(_file_dialog)
	
	_file_dialog.files_selected.connect(_on_audios_selected)
	_file_dialog.popup_centered(Vector2i(1080, 640))

func _on_audios_selected(paths: PackedStringArray):
	var newDict = {}
	
	for p in paths:
		var k = p.get_file().replace("." + p.get_extension(), "")
		if !audios_dict.has(k):
			audios_dict[k] = p
			newDict[k] = p
	render_audios_objects(newDict, audios_dict)
	_file_dialog.queue_free()

func _on_save_audios_button_pressed():
	save_json(scene_folder.text + "configs/sounds.json", audios_dict)


	
func _on_remove_characters_button_2_pressed():
	var to_remove = []
	for i in characters_children_list:
		if i.selected:
			characters_dict.characters.erase(i.element_id)
			to_remove.push_back(i)
	for i in to_remove:
		characters_children_list.remove_at(characters_children_list.find(i))
		i.queue_free()

func _on_add_characters_button_pressed():
	if !characters_dict.characters.has("new character"):
		characters_dict.characters["new character"] = {
			"name": "Character Name",
			"portrait": ""
		}
		render_characters_objects({
			"characters": {
				"new character": {
					"name": "Character Name",
					"portrait": ""
				}
			}
		}, characters_dict)
	pass

func _on_save_characters_button_pressed():
	save_json(scene_folder.text + "configs/characters.json", characters_dict)


func _on_load_timeline_button_pressed():
	current_timeline_filename = timelines_list[timeline_list_combobox.text]
	current_timeline = read_json(current_timeline_filename)
	for c in timeline_children_list:
		timeline_box.remove_child(c)
		c.queue_free()
	timeline_children_list.clear()
	var context: Dictionary = {"ids": [], "characters": []}
	for e in current_timeline.events:
		if e.has("id") && !context.ids.has(e.id):
			context.ids.push_back(e.id)
		if e.has("character") && !context.characters.has(e.character):
			context.characters.push_back(e.character)
	for c in characters_dict.characters:
		if !context.characters.has(c):
			context.characters.push_back(c)
	for e in current_timeline.events:
		var class_obj = preload("res://addons/DialogHelperTool/TimelineItem/TimelineItem.tscn")
		var obj = class_obj.instantiate()
		obj.context = context
		obj.data = e
		obj.backgrounds = background_store
		timeline_box.add_child(obj)
		timeline_children_list.push_back(obj)
