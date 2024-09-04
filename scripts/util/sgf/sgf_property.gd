class_name SGFProperty
extends SGFComponent

var identifier: String # all uppercase, non-empty string
var values: Array[String] # non-empty

func _init(_identifier: String = "") -> void:
    identifier = _identifier


func serialise() -> String:
    return identifier + "".join(values.map(
        func(v: String) -> String:
            return "[" + v + "]"
    ))

func pretty_print(tabs: int) -> String:
    return TAB_STR.repeat(tabs) + identifier + ": " + str(values)


func add_value(_value: String) -> SGFProperty:
    values.append(_value)
    return self

func add_values(_values: Array[String]) -> SGFProperty:
    values.append_array(_values)
    return self
