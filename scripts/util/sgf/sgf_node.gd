class_name SGFNode
extends SGFComponent

var properties: Array[SGFProperty]


func has_prop(id: String) -> bool:
    return not properties.filter(
        func(p: SGFProperty) -> bool:
            return p.identifier == id
    ).is_empty()

func get_prop(id: String) -> Array[String]:
    return properties.filter(
        func(p: SGFProperty) -> bool:
            return p.identifier == id
    )[0].values

func serialise() -> String:
    return ";" + "".join(properties.map(
        func(p: SGFProperty) -> String:
            return p.serialise()
    ))

func pretty_print(tabs: int) -> String:
    if properties.size() <= 1:
        return TAB_STR.repeat(tabs) + "props: " + str(properties)

    var result: String = TAB_STR.repeat(tabs) + "props: ["
    for prop: SGFProperty in properties:
        result += "\n" + prop.pretty_print(tabs + 1)
    return result + ("]" if properties.is_empty() else "\n" + TAB_STR.repeat(tabs) + "]")


func add_prop(_property: SGFProperty) -> SGFNode:
    properties.append(_property)
    return self

func add_props(_properties: Array[SGFProperty]) -> SGFNode:
    properties.append_array(_properties)
    return self
