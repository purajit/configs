cp ~/Library/Preferences/com.apple.Terminal.plist terminal.plist
python plist_to_yaml.py terminal-configs.plist >terminal.yaml
python yaml_to_plist.py terminal.yaml >new_terminal.plist
diff terminal.plist new_terminal.plist
