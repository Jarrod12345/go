class_name Tile
extends Area2D

enum TileState { EMPTY, BLACK, WHITE }

const BLACK_STONE: Texture2D = preload("res://assets/go_black.png")
const WHITE_STONE: Texture2D = preload("res://assets/go_white.png")

@onready var board_tile: Sprite2D = %BoardTile
@onready var stone: Sprite2D = %Stone

var manager: TileManager
var chain: Chain

var grid_pos: Vector2i
var adj_tiles: Array[Tile]
var tile_state: TileState = TileState.EMPTY
var is_preview: bool = false


## Initialise the board tile with a texture, position and rotation
func init_board_tile(tex: Texture2D, x: int, y: int, rot_deg: int) -> void:
    board_tile.texture = tex
    grid_pos = Vector2i(x, y)
    position = Vector2i(x + 1, y + 1) * Board.TILE_SIZE
    board_tile.rotation_degrees = rot_deg


func _ready() -> void:
    # set collider size for mouse detection
    var collider: CollisionShape2D = %Collider
    (collider.shape as RectangleShape2D).size = Vector2(Board.TILE_SIZE, Board.TILE_SIZE)

    # mouse events
    connect("mouse_entered", on_mouse_enter)
    connect("mouse_exited", on_mouse_exit)

## Displays a preview stone if this tile does not have a stone placed,
## and is a valid placement in the current turn.
func on_mouse_enter() -> void:
    if is_placed() or not manager.can_place(self):
        return

    is_preview = true
    stone.self_modulate.a = 0.8
    stone.texture = BLACK_STONE if manager.black_move else WHITE_STONE

## Removes the preview stone if a stone is not placed on this tile.
func on_mouse_exit() -> void:
    if is_placed():
        return

    is_preview = false
    stone.texture = null

## Returns `true` if a stone is placed on this tile, otherwise `false`.
func is_placed() -> bool:
    return tile_state != TileState.EMPTY

func _input(event: InputEvent) -> void:
    if not is_preview:
        return

    # left-clicking on a preview stone places it
    if event is InputEventMouseButton:
        var e: InputEventMouseButton = event
        if not e.pressed or e.button_index != MOUSE_BUTTON_LEFT:
            return

        place_stone()


## Place a stone on this tile. Colour is determined by tile manager state.
func place_stone() -> void:
    is_preview = false
    stone.texture = BLACK_STONE if manager.black_move else WHITE_STONE
    stone.self_modulate.a = 1
    manager.place_stone(self)

## Remove the stone from this tile. Updates any adjacent enemy chains.
func remove_stone() -> void:
    for adj: Tile in adj_tiles:
        if adj.is_placed() and adj.tile_state != tile_state:
            adj.chain.add_liberty(grid_pos)

    tile_state = TileState.EMPTY
    stone.texture = null
