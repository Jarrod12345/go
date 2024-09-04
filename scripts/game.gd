class_name Game
extends Node

static var game_scene: PackedScene = load("res://scenes/game.tscn")

@onready var score_black: Label = %ScoreBlack
@onready var score_white: Label = %ScoreWhite
@onready var file_dialog: FileDialog = %FileDialog
@onready var save_button: Button = %SaveButton

var setup: Setup
var board: Board


## Create and instantiate a new Game.
static func create(_setup: Setup) -> Game:
    var game: Game = game_scene.instantiate()
    game.setup = _setup
    return game

func _ready() -> void:
    file_dialog.access = FileDialog.ACCESS_USERDATA
    file_dialog.root_subfolder = Setup.SAVE_DIR

    board = Board.create_board(setup.board_size)
    add_child(board)
    update_score(0, 0)

    board.tile_manager.territory_manager.update_score.connect(update_score)

    # (temporary) scaling depending on board size
    match board.board_size:
        13: board.scale /= 1.4
        19: board.scale /= 2


func update_score(black: int, white: int) -> void:
    score_black.text = "Black: " + str(black)
    score_white.text = "White: " + str(white)
    enable_save_btn()

func enable_save_btn() -> void:
    save_button.text = "Save Game"
    save_button.disabled = false


# Pass
func _on_pass_button_pressed() -> void:
    board.tile_manager.pass_turn()
    enable_save_btn()


# Save Game
func _on_save_button_pressed() -> void:
    file_dialog.popup()
    board.tile_manager.paused = true

func _on_file_dialog_file_selected(path: String) -> void:
    # serialise timeline and prepend a node for the board size
    var save_string: String = SGFGameTree.new().add_node(
        SGFNode.new().add_prop(
            SGFProperty.new("SZ").add_value(str(board.board_size))
        )
    ).add_nodes(board.tile_manager.timeline).serialise()

    var savefile: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    savefile.store_string(save_string)
    savefile.close()

    board.tile_manager.paused = false
    # disable save button
    save_button.text = "Game Saved!"
    save_button.disabled = true

func _on_file_dialog_canceled() -> void:
    board.tile_manager.paused = false


# Exit to Menu
func _on_exit_button_pressed() -> void:
    # TODO: confirm if state has changed since last save
    setup.visible = true
    queue_free()
