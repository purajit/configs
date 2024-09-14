import base64
import xml.etree.ElementTree as ET
import json
import sys
import uuid
import yaml


class UnexpectedElement(Exception):
    pass


def _parse_plist(element: ET) -> dict:
    # compound structures
    if element.tag == "dict":
        return {
            "type": "dict",
            "value": {
                # key and value pairs in a flat array
                element[i].text: _parse_plist(element[i + 1])
                for i in range(0, len(element), 2)
            },
        }
    elif element.tag == "array":
        return {"type": "list", "value": [_parse_plist(item) for item in element]}
    # remaining are kept as-is, as strings, with
    elif element.tag == "data":
        return {"type": "data", "value": element.text}
    elif element.tag == "string":
        return {"type": "string", "value": element.text}
    elif element.tag == "integer":
        return {"type": "integer", "value": element.text}
    elif element.tag == "real":
        return {"type": "real", "value": element.text}
    elif element.tag == "true":
        return {"type": "bool", "value": "true"}
    elif element.tag == "false":
        return {"type": "bool", "value": "false"}
    else:
        raise UnexpectedElement(element)


def plist_to_dict(plist_file: str) -> dict:
    tree = ET.parse(plist_file)
    root = tree.getroot()

    if root.tag != "plist":
        print("Not a valid plist file")
        return None

    return _parse_plist(root[0])["value"]


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python plist_to_dict.py <path_to_plist>")
        sys.exit(1)

    plist_dict = plist_to_dict(sys.argv[1])
    print(yaml.dump(plist_dict))
    # for cmd in generate_plistbuddy_commands(plist_dict):
    #     print(f"/usr/libexec/PlistBuddy -c '{cmd}' a1.plist")
