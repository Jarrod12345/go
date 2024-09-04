class_name Board
extends Node2D

const TILE_SIZE: int = 64

class Textures:
    const BORDER_CORNER: Texture2D = preload("res://assets/go_outer_corner.png")
    const BORDER_SIDE: Texture2D = preload("res://assets/go_outer_side.png")
    const CORNER: Texture2D = preload("res://assets/go_corner.png")
    const SIDE: Texture2D = preload("res://assets/go_side.png")
    const CENTRE: Texture2D = preload("res://assets/go_centre.png")
    const STAR_POINT: Texture2D = preload("res://assets/go_dot.png")

static var board_scene: PackedScene = load("res://scenes/board.tscn")
const tile_scene: PackedScene = preload("res://scenes/playable_tile.tscn")

var board_size: int
var star_points: Array[Vector2i]
var tile_manager: TileManager


## Create and instantiate a new Board.
static func create_board(_board_size: int) -> Board:
    assert(_board_size in [9, 13, 19], "Invalid board size: %s" % _board_size)

    var board: Board = board_scene.instantiate()
    board.board_size = _board_size
    board.star_points = calculate_star_points(_board_size, true)
    return board


func _ready() -> void:
    tile_manager = TileManager.new(board_size, place_tiles())

## Create and place all tiles (playable and border) on the board.
## Returns a matrix / 2D array of playable tiles.
func place_tiles() -> Array[Array]:
    var tiles: Array[Array] = []
    for i: int in range(board_size):
        tiles.append([])

    var length: int = board_size + 1
    for y: int in range(length + 1):
        for x: int in range(length + 1):
            if y % length and x % length:
                tiles[x - 1].append(place_playable_tile(x - 1, y - 1))
            else:
                place_border_tile(x, y, length)
    return tiles

## Create a playable tile at borderless position (x, y).
func place_playable_tile(x: int, y: int) -> Tile:
    var length: int = board_size - 1
    var tex: Texture2D

    # select texture depending on position
    if y % length and x % length:
        if Vector2i(x, y) in star_points:
            tex = Textures.STAR_POINT
        else:
            tex = Textures.CENTRE
    elif y % length or x % length:
        tex = Textures.SIDE
    else:
        tex = Textures.CORNER

    # add to scene tree before initialising to allow access to child nodes
    var tile: Tile = tile_scene.instantiate()
    add_child(tile)
    tile.init_board_tile(tex, x, y, -tile_rotation(y, x, length))
    return tile

## Place a border tile at bordered position (x, y).
func place_border_tile(x: int, y: int, length: int) -> void:
    # border tiles are sprites without extra behaviour
    var sprite: Sprite2D = Sprite2D.new()
    if y % length or x % length:
        sprite.texture = Textures.BORDER_SIDE
    else:
        sprite.texture = Textures.BORDER_CORNER
    sprite.rotation_degrees = tile_rotation(x, y, length)
    sprite.position = Vector2i(x * TILE_SIZE, y * TILE_SIZE)
    add_child(sprite)

## Determine tile rotation given coordinates and the inner board size.
func tile_rotation(x: int, y: int, length: int) -> int:
    if y == 0 and x > 0:
        return 90
    elif x == length:
        return 180
    elif y == length:
        return -90
    else:
        return 0


## Calculate star point positions depending on the board size.
## Can optionally add a centre point if one doesn't exist.
static func calculate_star_points(side_length: int, add_centre: bool) -> Array[Vector2i]:
    var divsize: int = ceili((side_length - 1) ** (1. / 3))
    var stars: Array[Vector2i] = []
    var r: Array = range(divsize, side_length, divsize * 2)
    for y: int in r:
        for x: int in r:
            stars.append(Vector2i(x, y))

    if add_centre:
        var centre_ord: int = (side_length - 1) / 2
        var centre: Vector2i = Vector2i(centre_ord, centre_ord)
        if centre not in stars:
            stars.append(centre)
    return stars
