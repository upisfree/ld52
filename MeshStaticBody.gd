extends MeshInstance

# этот скрипт генерирует статитечское физическое тело для коллизий из геометрии модели на лету,
# а не в редакторе. нужно чтобы не дублировать геометрию дважды. в этом проекте получилось -27 мб 
func _ready():
	create_trimesh_collision()
