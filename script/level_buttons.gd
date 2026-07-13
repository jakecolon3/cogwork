extends ColorRect

signal exit
signal level_selected(level: String)

var levels: PackedStringArray
var level_button := load("res://scenes/level_button.tscn")


func _ready() -> void:
    $ScrollContainer/VBoxContainer/LevelButton.pressed_.connect(start_level)
    var level_dir := DirAccess.open("res://scenes/levels")
    levels = level_dir.get_files()
    for level in levels:
        if level == "level_0.tscn": continue
        var basename := level.split(".")[0]
        var number := basename.split("_")[1]
        if !number.is_valid_int():
            continue
        var button: LevelButton = level_button.instantiate()
        button.text = "\n" + number + "\n "
        button.level = level
        button.pressed_.connect(start_level)
        $ScrollContainer/VBoxContainer/ButtonsContainer.add_child(button)


func _process(_delta: float) -> void:
    if visible and Input.is_action_just_pressed("pause"):
        exit.emit()


func start_level(level: String) -> void:
    print("Loading level " + level)
    level_selected.emit(level)
