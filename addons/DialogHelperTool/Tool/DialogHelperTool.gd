@tool
extends Control

@export var interface_scale: float = 1.0
@export var bus_list: Array[String] = []

var scene_config_data = {}
var timelines_list = {}
@onready var scene_folder = $VBoxContainer/TabContainer/Scene/MarginContainer/VBoxContainer/GridContainer/SceneFolder
@onready var scene_file = $VBoxContainer/TabContainer/Scene/MarginContainer/VBoxContainer/GridContainer/SceneFile
@onready var timelines_combobox = $VBoxContainer/TabContainer/Scene/MarginContainer/VBoxContainer/GridContainer/TimelineList

@onready var transitionsModal = $TransitionsModal
@onready var scriptModal = $ScriptModal
@onready var rootsModal = $RootsEditorModal
@onready var choicesModal = $ChoicesModal

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
@onready var timeline_list_combobox = $VBoxContainer/TabContainer/Timeline/MarginContainer/VBoxContainer/ScrollContainer2/HBoxContainer/TimelinesList
var timeline_children_list = []
var current_timeline: Dictionary = {}
var current_timeline_filename: String = ""

@onready var root_list = $VBoxContainer/TabContainer/Timeline/MarginContainer/VBoxContainer/ScrollContainer2/HBoxContainer/RootList

var _file_dialog
var JSONHelper = preload("res://addons/DialogHelperTool/Shared/JSONHelper.gd").new()
var current_root: String = ""
var state_context: Dictionary = {}



signal event_selected(data: Dictionary)
signal reimport(filename)

func _ready():
	_on_scene_folder_changed("res://Resources/Scene1/")
	JSONHelper.connect("reimport", reimport_slot)
	if interface_scale > 1:
		$VBoxContainer/TabContainer/Timeline/MarginContainer/VBoxContainer/ScrollContainer2.custom_minimum_size = Vector2i(0, 40.0 * interface_scale)
	root_list.setScale(interface_scale)
	
func reimport_slot(filename):
	reimport.emit(filename)
	
	
func _on_scene_folder_changed(path):
	var config_path = path + "config.json"
	if !FileAccess.file_exists(config_path):
		JSONHelper.save_json(config_path, {})
		_on_scene_folder_changed(path)
	timelines_list = {}
	timelines_combobox.clear()
	timeline_list_combobox.clear()
	scene_config_data = JSONHelper.read_json(config_path)
	scene_folder.text = path
	
	var timelines: Array[String] = get_filelist(path + "timelines", ["json"])
	for k in timelines:
		timelines_list[k.get_file().get_basename()] = k
		timelines_combobox.add_item(k.get_file().get_basename())
		timeline_list_combobox.add_item(k.get_file().get_basename())
	timelines_combobox.selected = timelines_list.keys().find(scene_config_data.start)
	timeline_list_combobox.selected = timelines_list.keys().find(scene_config_data.start)
	scene_file.text = scene_config_data.scene
	
	background_dict = JSONHelper.read_json(path + "configs/backgrounds.json")
	clear_backgrounds_objects()
	render_background_objects(background_dict, background_dict)
	
	videos_dict = JSONHelper.read_json(path + "configs/videos.json")
	clear_videos_objects()
	render_videos_objects(videos_dict, videos_dict)
	
	audios_dict = JSONHelper.read_json(path + "configs/sounds.json")
	clear_audios_objects()
	render_audios_objects(audios_dict, audios_dict)
	
	characters_dict = JSONHelper.read_json(path + "configs/characters.json")
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
		var class_obj = preload("res://addons/DialogHelperTool/Tool/BackgroundConfigItem/BackgroundConfigItem.tscn")
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
		var class_obj = preload("res://addons/DialogHelperTool/Tool/VideoConfigItem/VideoConfigItem.tscn")
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
		var class_obj = preload("res://addons/DialogHelperTool/Tool/AudioConfigItem/AudioConfigItem.tscn")
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
		var class_obj = preload("res://addons/DialogHelperTool/Tool/CharacterConfigItem/CharacterConfigItem.tscn")
		var obj = class_obj.instantiate()
		obj.set_source(source.characters, k)
		characters_grid.add_child(obj)
		characters_children_list.push_back(obj)

func _on_scene_entry_changed(path):
	scene_file.text = path

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
	JSONHelper.save_json(scene_folder.text + "configs/backgrounds.json", background_dict)


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
	JSONHelper.save_json(scene_folder.text + "configs/videos.json", videos_dict)

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
	JSONHelper.save_json(scene_folder.text + "configs/sounds.json", audios_dict)


	
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
	JSONHelper.save_json(scene_folder.text + "configs/characters.json", characters_dict)


func _on_load_timeline_button_pressed():
	current_timeline_filename = timelines_list[timeline_list_combobox.text]
	current_timeline = JSONHelper.read_json(current_timeline_filename)
	load_root("")
	
	root_list.items = root_list.fixTypes([""] + current_timeline.roots.keys())
	root_list.text = ""

func load_root(root_name): 
	for c in timeline_children_list:
		timeline_box.remove_child(c)
		c.queue_free()
	timeline_children_list.clear()
	current_root = root_name
	if !current_timeline.has("roots"):
		current_timeline["roots"] = {}
	var context: Dictionary = update_context()
	load_root_contents(context, root_name)
	
func update_context(context: Dictionary = {"ids": [], "characters": [], "roots": [""]}) -> Dictionary:
	context.ids.clear()
	context.characters.clear()
	context.roots.clear()
	for e in get_current_root_events():
		if e.has("id") && !context.ids.has(e.id):
			context.ids.push_back(e.id)
		if e.has("character") && !context.characters.has(e.character):
			context.characters.push_back(e.character)
	for c in characters_dict.characters:
		if !context.characters.has(c):
			context.characters.push_back(c)
	if current_timeline.has("roots"):
		for r in current_timeline.roots.keys():
			context.roots.push_back(r)
	state_context = context
	return context
	
func reup_context():
	update_context(state_context)
	for t in timeline_children_list:
		t.setContext(state_context)
		
func load_root_contents(context: Dictionary, name: String = ""):
	if name != "" && (!current_timeline.has("roots") || !current_timeline.roots.has(name)):
		print("no such root: ", name)
		return
	var path = current_timeline if name == "" else current_timeline.roots[name]
	for e in path.events:
		create_timeline_event(e, context)

func create_timeline_event(e: Dictionary, context: Dictionary):
	var class_obj = preload("res://addons/DialogHelperTool/Tool/TimelineItem/TimelineItem.tscn")
	var obj = class_obj.instantiate()
	obj.context = context
	obj.data = e
	obj.backgrounds = background_store
	obj.sounds = audios_dict
	obj.videos = videos_dict
	obj.connect("was_selected", _on_timeline_item_selected)
	obj.connect("show_script", showScriptWindow)
	obj.connect("show_transitions", showTransitionsWindow)
	obj.connect("show_choices", showChoicesWindow)
	obj.connect("id_created", reup_context)
	obj.bus_list = bus_list
	timeline_box.add_child(obj)
	timeline_children_list.push_back(obj)
	obj.custom_minimum_size = obj.custom_minimum_size * interface_scale
	obj.rescale_fonts(interface_scale)
	return obj



func _on_save_timeline_button_pressed():
	JSONHelper.save_json(current_timeline_filename, current_timeline)
	
func _on_timeline_item_selected(obj):
	event_selected.emit(obj.data)
	
func get_current_root_events():
	if current_root == "":
		return current_timeline.events
	else:
		return current_timeline.roots[current_root].events
	
func move_down():
	var selected_list: Array[Node] = []
	for t in timeline_children_list:
		if t.selected:
			selected_list.push_front(t)
	selected_list.sort_custom(func(a, b): return a.get_index() > b.get_index())
	var events = get_current_root_events()
	for t in selected_list:
		var ix = t.get_index()
		if ix < timeline_children_list.size() - 1:
			t.get_parent().move_child(t, t.get_index() + 1)
			var next = events[ix + 1]
			events[ix + 1] = events[ix]
			events[ix] = next
			
func move_up():
	var selected_list: Array[Node] = []
	for t in timeline_children_list:
		if t.selected:
			selected_list.push_back(t)
	selected_list.sort_custom(func(a, b): return a.get_index() < b.get_index())
	var events = get_current_root_events()
	for t in selected_list:
		var ix = t.get_index()
		if ix > 0:
			t.get_parent().move_child(t, t.get_index() - 1)
			var prev = events[ix - 1]
			events[ix - 1] = events[ix]
			events[ix] = prev
			
func add_new_event():
	var max_index: int = -1
	for t in timeline_children_list:
		if t.selected:
			max_index = max(max_index, t.get_index())
	var event: Dictionary = {"text": ""}
	var list: Array = get_current_root_events()
	var should_insert: bool = max_index > -1 && max_index < timeline_children_list.size() - 1
	
	if should_insert:
		list.insert(max_index + 1, event)
	else:
		list.push_back(event)
	var obj = create_timeline_event(event, state_context)
	if should_insert:
		obj.get_parent().move_child(obj, max_index + 1)

func remove_selected():
	var indexes: Array = []
	for t in timeline_children_list:
		if t.selected:
			indexes.push_back(t.get_index())
	var new_t: Array = timeline_children_list.filter(func(t): return !t.selected)
	for t in timeline_children_list:
		if t.selected:
			t.get_parent().remove_child(t)
			t.queue_free()
	timeline_children_list = new_t
	
	indexes.sort()
	indexes.reverse()
	
	var list: Array = get_current_root_events()
	for ix in indexes:
		list.remove_at(ix)
	
	
func showScriptWindow(sender, text, data):
	scriptModal.sender = sender
	scriptModal.text = text
	scriptModal.src = data
	scriptModal.popup_size = Vector2(0.8, 0.8)
	scriptModal.show_modal()
	
func showTransitionsWindow(sender, data):
	transitionsModal.sender = sender
	transitionsModal.src = data
	transitionsModal.popup_size = Vector2(0.7, 0.8)
	transitionsModal.show_modal()

func showChoicesWindow(sender, data):
	choicesModal.sender = sender
	choicesModal.setRoot(current_root)
	choicesModal.setRootList(root_list.fixTypes([""] + state_context.ids + current_timeline.roots.keys()))
	choicesModal.src = data
	choicesModal.popup_size = Vector2(0.7, 0.8)
	choicesModal.show_modal()

func _on_script_window_text_saved(data: Dictionary):
	scriptModal.sender.updateScriptText(data.script)
	scriptModal.sender.scriptPopupHidden()

func _on_script_window_popup_hide():
	scriptModal.sender.scriptPopupHidden()

func _on_transitions_modal_back_clicked():
	transitionsModal.sender.transitionsPopupHidden()


func _on_move_down_timeline_item_button_pressed():
	move_down()


func _on_roots_editor_modal_back_clicked():
	var roots: Array[String] = root_list.fixTypes([""] + current_timeline.roots.keys())
	root_list.items = roots
	root_list.text = current_root if roots.has(current_root) else ""
	reup_context()


func _on_roots_editor_button_pressed():
	rootsModal.src = current_timeline
	rootsModal.popup_size = Vector2(0.4, 0.6)
	rootsModal.show_modal()


func _on_root_list_item_selected(text):
	if root_list.text != text:
		root_list.text = text
	if (text == "" || current_timeline.roots.has(text)) && current_root != text:
		load_root(text)
		reup_context()


func _on_roots_editor_modal_root_name_changed(old, new):
	var oldItems : Array[String] = root_list.items
	oldItems[oldItems.find(old)] = new
	root_list.items = oldItems
	if current_root == old:
		root_list.text = old 
	if current_root == new:
		root_list.text = new
		current_root = new
	reup_context()

func _on_choices_modal_back_clicked():
	choicesModal.sender.choicesPopupHidden()
	
func create_root(_name: String):
	if !current_timeline.roots.has(_name):
		current_timeline.roots[_name] = {"events": []}
	
	var roots: Array[String] = root_list.fixTypes([""] + current_timeline.roots.keys())
	root_list.items = roots
	root_list.text = current_root if roots.has(current_root) else ""
	reup_context()
