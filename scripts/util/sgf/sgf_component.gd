class_name SGFComponent

const TAB_STR: String = "  "

func serialise() -> String:
    push_error("UNIMPLEMENTED ERROR: SGFComponent.serialise()")
    return ""

func pretty_print(_tabs: int) -> String:
    push_error("UNIMPLEMENTED ERROR: SGFComponent.pretty_print()")
    return ""

func _to_string() -> String:
    return pretty_print(0)
