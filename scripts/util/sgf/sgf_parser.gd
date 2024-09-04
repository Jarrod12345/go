class_name SGFParser

var wspc: RegEx = RegEx.new()
var value_wspc: RegEx = RegEx.new()
var content: String


func load_sgf(filename: String) -> Array[SGFGameTree]:
    # load file
    var file: FileAccess = FileAccess.open(filename, FileAccess.READ)
    if file == null:
        printerr("could not open file: " + filename)
        return []
    content = file.get_as_text(true)
    file.close()

    wspc.compile(r"\s")
    value_wspc.compile(r"[^\S\n]")

    # GameTree
    var collection: Array[SGFGameTree] = []
    var current_parent: SGFGameTree = null
    var i: int = 0
    while i < content.length():
        i = consume_whitespace(i)
        if content[i] == "(":
            var tree: SGFGameTree = SGFGameTree.new(current_parent)
            i = parse_sequence(i + 1, tree)
            if current_parent == null:
                collection.append(tree)
            else:
                current_parent.add_subtree(tree)
            current_parent = tree
        else:
            if content[i] == ")" and current_parent != null:
                current_parent = current_parent.parent
            i += 1

    return collection


func consume_whitespace(i: int) -> int:
    while i < content.length() - 1 and wspc.search(content[i]) != null:
        i += 1
    return i


# Sequence
func parse_sequence(i: int, tree: SGFGameTree) -> int:
    while i < content.length():
        i = consume_whitespace(i)
        if content[i] in "()":
            break
        elif content[i] == ";":
            var node: SGFNode = SGFNode.new()
            i = parse_node(i + 1, node)
            tree.add_node(node)
        else:
            i += 1
    return i


# Node
func parse_node(i: int, node: SGFNode) -> int:
    while i < content.length():
        i = consume_whitespace(i)
        if content[i] in ";()":
            return i
        var prop: SGFProperty = SGFProperty.new()
        i = parse_prop(i, prop)
        node.add_prop(prop)
    return i


# Property
func parse_prop(i: int, prop: SGFProperty) -> int:
    var id: String = ""
    var id_set: bool = false

    while i < content.length():
        i = consume_whitespace(i)

        if content[i] == "[":
            if not id_set:
                id_set = true
                prop.identifier = id
            i = parse_value(i + 1, prop)
        elif id_set or content[i] in ";()":
            break
        else:
            id += content[i]
            i += 1

    return i


# PropValue
func parse_value(i: int, prop: SGFProperty) -> int:
    var escape_next: bool = false
    var value: String = ""

    while i < content.length():
        if escape_next:
            escape_next = false
            if content[i] != "\n":
                value += value_wspc.sub(content[i], " ")
        else:
            if content[i] == "]":
                prop.add_value(value)
                break
            else:
                if content[i] == "\\":
                    escape_next = true
                else:
                    value += value_wspc.sub(content[i], " ")
        i += 1

    return i + 1
