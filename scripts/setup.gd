class_name Setup
extends Control

const SAVE_DIR: String = "saves/"

var board_size: int

@onready var file_dialog: FileDialog = %FileDialog
var absolute_save_dir: String = ProjectSettings.globalize_path("user://" + SAVE_DIR)


## Get values from UI components and set internal values.
func set_values() -> void:
    if (%CheckBox9x9 as CheckBox).button_pressed:
        board_size = 9
    elif (%CheckBox13x13 as CheckBox).button_pressed:
        board_size = 13
    elif (%CheckBox19x19 as CheckBox).button_pressed:
        board_size = 19

## Start a new game and hide this scene.
func _on_start_button_pressed() -> void:
    set_values()
    get_tree().root.add_child(Game.create(self))
    visible = false


func _init() -> void:
    # create saves subfolder if it doesn't exist
    if not DirAccess.dir_exists_absolute(absolute_save_dir):
        DirAccess.make_dir_recursive_absolute(absolute_save_dir)

func _ready() -> void:
    file_dialog.access = FileDialog.ACCESS_USERDATA
    file_dialog.root_subfolder = SAVE_DIR


# Load Game
func _on_load_button_pressed() -> void:
    file_dialog.popup()

func _on_file_dialog_file_selected(path: String) -> void:
    var collection: Array[SGFGameTree] = SGFParser.new().load_sgf(path)
    if collection[0].sequence[0].has_prop("SZ"):
        board_size = int(collection[0].sequence[0].get_prop("SZ")[0])
    else:
        board_size = 19

    var game: Game = Game.create(self)
    get_tree().root.add_child(game)
    visible = false

    # iterate through each node in the sequence and place stones
    var tile_manager: TileManager = game.board.tile_manager
    tile_manager.paused = true
    # TODO: disable buttons in Game until all stones are placed
    for node: SGFNode in collection[0].sequence.slice(1):
        await get_tree().create_timer(0.03).timeout

        var move: String
        if node.has_prop("B"):
            move = node.get_prop("B")[0]
            tile_manager.black_move = true
        elif node.has_prop("W"):
            move = node.get_prop("W")[0]
            tile_manager.black_move = false
        else:
            continue

        if move.is_empty():
            tile_manager.pass_turn()
        else:
            var x: int = move.unicode_at(0) - 97
            var y: int = move.unicode_at(1) - 97
            tile_manager.tiles[x][y].place_stone()
    tile_manager.paused = false


# View/Manage Save Files
func _on_open_dir_button_pressed() -> void:
    OS.shell_show_in_file_manager(absolute_save_dir)
