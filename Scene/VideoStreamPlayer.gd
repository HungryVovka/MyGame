extends VideoStreamPlayer

var image = null

@onready
var bgTexture = $"../TextureRect"
	
func reset_image():
	image = null
	
func _process(_delta):
	if is_playing() && stream_position && !image:
		store_first_frame()
		set_process(false)

func _on_finished():
	play()

func store_first_frame():
	var newImage = self.get_video_texture()
	if newImage:
		var texture = ImageTexture.create_from_image(newImage.get_image())
		if texture:
			bgTexture.texture = texture
			image = newImage
