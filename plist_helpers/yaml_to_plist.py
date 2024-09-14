import base64
import sys
import uuid
import yaml


def generate_plistbuddy_commands(entry_type: str, data: dict, path: str = "") -> None:
    commands = []
    path_for_writing = path.replace(" ", "\\ ")
    if entry_type == "dict":
        if path:
            commands.append(f"Add {path_for_writing} dict")
        for key, value in data.items():
            full_path = f"{path}:{key}" if path else key
            commands.extend(
                generate_plistbuddy_commands(value["type"], value["value"], full_path)
            )
    elif entry_type == "list":
        commands.append(f"Add {path_for_writing} array")
        for i, item in enumerate(data):
            commands.extend(
                generate_plistbuddy_commands(item["type"], item["value"], f"{path}:{i}")
            )
    elif entry_type == "data":
        file_id = uuid.uuid4()
        with open(f"/tmp/{file_id}", "bw") as f:
            f.write(base64.b64decode(data))
        commands.append(f"Import {path_for_writing} /tmp/{file_id}")
    elif entry_type == "bool":
        commands.append(f"Add {path_for_writing} bool {data}")
    elif entry_type == "string":
        commands.append(f'Add {path_for_writing} string "{data}"')
    elif entry_type == "real" and not path.endswith(":ProfileCurrentVersion"):
        commands.append(f"Add {path_for_writing} real {data}")
    elif entry_type == "integer":
        commands.append(f"Add {path_for_writing} integer {data}")

    return commands


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python plistdict_to_plistbuddy.py <path_to_yaml>")
        sys.exit(1)

    with open(sys.argv[1]) as f:
        configs = yaml.safe_load(f.read())

    commands = generate_plistbuddy_commands("dict", configs)

    for cmd in commands:
        print(f"/usr/libexec/PlistBuddy -c '{cmd}' a1.plist")
