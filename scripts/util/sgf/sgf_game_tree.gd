class_name SGFGameTree
extends SGFComponent

var parent: SGFGameTree
var sequence: Array[SGFNode] # non-empty
var subtrees: Array[SGFGameTree]

func _init(_parent: SGFGameTree = null) -> void:
    parent = _parent


func serialise() -> String:
    return "(" + "".join(sequence.map(
        func(n: SGFNode) -> String:
            return n.serialise()
    )) + "".join(subtrees.map(
        func(t: SGFGameTree) -> String:
            return t.serialise()
    )) + ")"

func pretty_print(tabs: int) -> String:
    var result: String = TAB_STR.repeat(tabs) + "sequence: ["
    for node: SGFNode in sequence:
        result += "\n" + node.pretty_print(tabs + 1)
    result += ("]" if sequence.is_empty() else "\n" + TAB_STR.repeat(tabs) + "]") + ",\n" + TAB_STR.repeat(tabs) + "subtrees: ["
    for subtree: SGFGameTree in subtrees:
        result += "\n" + TAB_STR.repeat(tabs + 1) + "{\n" + subtree.pretty_print(tabs + 2) + "\n" + TAB_STR.repeat(tabs + 1) + "}"
    return result + ("]" if subtrees.is_empty() else "\n" + TAB_STR.repeat(tabs) + "]")


func add_node(_node: SGFNode) -> SGFGameTree:
    sequence.append(_node)
    return self

func add_nodes(_nodes: Array[SGFNode]) -> SGFGameTree:
    sequence.append_array(_nodes)
    return self

func add_subtree(_subtree: SGFGameTree) -> SGFGameTree:
    subtrees.append(_subtree)
    return self
