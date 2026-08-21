#!/usr/bin/env bash
set -euo pipefail

readonly MOD_NONE=0
readonly MOD_SHIFT=131072
readonly MOD_CONTROL=262144
readonly MOD_OPTION=524288
readonly MOD_COMMAND=1048576
readonly MOD_FUNCTION=8388608

symbolic_hotkeys_plist="$(mktemp)"
trap 'rm -f "${symbolic_hotkeys_plist}"' EXIT
plutil -create xml1 "${symbolic_hotkeys_plist}"
/usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys dict" "${symbolic_hotkeys_plist}"

function set_symbolic_hotkey {
  local shortcut_id="$1"
  local enabled="$2"
  local description="$3"
  shift 3

  local plist_key=":AppleSymbolicHotKeys:${shortcut_id}"
  /usr/libexec/PlistBuddy -c "Add ${plist_key} dict" "${symbolic_hotkeys_plist}"
  /usr/libexec/PlistBuddy -c "Add ${plist_key}:enabled bool ${enabled}" "${symbolic_hotkeys_plist}"

  if [[ "$#" -eq 3 ]]; then
    local character_code="$1"
    local virtual_key_code="$2"
    local modifiers="$3"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value dict" "${symbolic_hotkeys_plist}"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value:parameters array" "${symbolic_hotkeys_plist}"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value:parameters:0 integer ${character_code}" "${symbolic_hotkeys_plist}"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value:parameters:1 integer ${virtual_key_code}" "${symbolic_hotkeys_plist}"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value:parameters:2 integer ${modifiers}" "${symbolic_hotkeys_plist}"
    /usr/libexec/PlistBuddy -c "Add ${plist_key}:value:type string standard" "${symbolic_hotkeys_plist}"
  elif [[ "$#" -ne 0 ]]; then
    printf "Invalid symbolic hotkey definition for ID %s\n" "${shortcut_id}" >&2
    return 1
  fi

  printf -- "- %-8s %s (ID %s)\n" "${enabled}" "${description}" "${shortcut_id}"
}

# Keyboard navigation
set_symbolic_hotkey 12 false "Turn keyboard access on or off" 65535 122 $((MOD_FUNCTION | MOD_CONTROL))
set_symbolic_hotkey 13 false "Change how Tab moves focus" 65535 98 $((MOD_FUNCTION | MOD_CONTROL))
set_symbolic_hotkey 159 false "Show the contextual menu" 65535 36 ${MOD_CONTROL}

# Accessibility display controls
set_symbolic_hotkey 15 false "Turn accessibility zoom on or off"
set_symbolic_hotkey 16 false "Turn accessibility zoom on or off slowly (legacy companion)"
set_symbolic_hotkey 17 false "Accessibility zoom in"
set_symbolic_hotkey 18 false "Accessibility zoom in slowly (legacy companion)"
set_symbolic_hotkey 19 false "Accessibility zoom out"
set_symbolic_hotkey 20 false "Accessibility zoom out slowly (legacy companion)"
set_symbolic_hotkey 21 false "Invert display colors"
set_symbolic_hotkey 22 false "Invert display colors slowly (legacy companion)"
set_symbolic_hotkey 23 false "Turn zoom image smoothing on or off"
set_symbolic_hotkey 24 false "Turn zoom image smoothing on or off slowly (legacy companion)"
set_symbolic_hotkey 25 false "Increase display contrast"
set_symbolic_hotkey 26 false "Decrease display contrast"

# Screenshots
set_symbolic_hotkey 28 true "Save the screen to a file with Control-Command-Shift-3" 51 20 $((MOD_COMMAND | MOD_CONTROL | MOD_SHIFT))
set_symbolic_hotkey 29 true "Copy the screen with Command-Shift-3" 51 20 $((MOD_COMMAND | MOD_SHIFT))
set_symbolic_hotkey 30 true "Save the selected area to a file with Control-Command-Shift-4" 52 21 $((MOD_COMMAND | MOD_CONTROL | MOD_SHIFT))
set_symbolic_hotkey 31 true "Copy the selected area with Command-Shift-4" 52 21 $((MOD_COMMAND | MOD_SHIFT))

# Dock, Mission Control, and Spaces
set_symbolic_hotkey 33 false "Show application windows" 65535 125 $((MOD_FUNCTION | MOD_CONTROL))
set_symbolic_hotkey 36 false "Show the desktop" 65535 103 ${MOD_FUNCTION}
set_symbolic_hotkey 52 false "Turn Dock hiding on or off" 100 2 $((MOD_COMMAND | MOD_OPTION))
set_symbolic_hotkey 79 true "Move to the previous Space"
set_symbolic_hotkey 80 true "Move to the previous Space slowly (companion)"
set_symbolic_hotkey 81 true "Move to the next Space"
set_symbolic_hotkey 82 true "Move to the next Space slowly (companion)"
set_symbolic_hotkey 175 false "Turn Do Not Disturb on or off" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 190 false "Create a Quick Note" 113 12 ${MOD_FUNCTION}
set_symbolic_hotkey 222 false "Turn Stage Manager on or off" 65535 65535 ${MOD_NONE}

# Input sources, search, and help
set_symbolic_hotkey 60 false "Select the previous input source" 32 49 ${MOD_CONTROL}
set_symbolic_hotkey 61 false "Select the next source in the Input menu" 32 49 $((MOD_CONTROL | MOD_OPTION))
set_symbolic_hotkey 65 false "Show a Finder search window" 32 49 $((MOD_COMMAND | MOD_OPTION))
set_symbolic_hotkey 98 false "Show the Help menu" 47 44 $((MOD_COMMAND | MOD_SHIFT))

# Accessibility, captions, speech, and presenter controls
set_symbolic_hotkey 59 false "Turn VoiceOver on or off" 65535 96 $((MOD_FUNCTION | MOD_COMMAND))
set_symbolic_hotkey 162 false "Show Accessibility controls" 65535 96 $((MOD_FUNCTION | MOD_COMMAND | MOD_OPTION))
set_symbolic_hotkey 164 false "Legacy or reserved Notification Center shortcut" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 215 false "Turn Live Captions on or off" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 216 false "Pause or resume Live Captions transcription" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 217 false "Turn Live Captions Type to Speak on or off" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 218 false "Switch Live Captions between computer audio and microphone" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 219 false "Keep Live Captions onscreen" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 223 false "Turn the large Presenter Overlay on or off" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 224 false "Turn the small Presenter Overlay on or off" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 225 false "Turn Live Speech on or off" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 226 false "Toggle Live Speech visibility" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 227 false "Pause or resume Live Speech" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 228 false "Cancel Live Speech" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 229 false "Hide or show Live Speech phrases" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 230 false "Turn Speak Selection on or off" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 231 false "Turn Speak Item Under the Pointer on or off" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 232 false "Turn typing feedback on or off" 65535 65535 ${MOD_NONE}

# Window management
set_symbolic_hotkey 233 false "Minimize the active window" 109 46 ${MOD_COMMAND}
set_symbolic_hotkey 235 false "Zoom the active window" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 237 false "Fill the active window" 102 3 $((MOD_COMMAND | MOD_OPTION))
set_symbolic_hotkey 238 false "Center the active window" 99 8 $((MOD_COMMAND | MOD_OPTION))
set_symbolic_hotkey 239 false "Return the active window to its previous size" 114 15 $((MOD_FUNCTION | MOD_CONTROL))
set_symbolic_hotkey 240 false "Tile the active window to the left half" 65535 123 $((MOD_FUNCTION | MOD_COMMAND | MOD_OPTION))
set_symbolic_hotkey 241 false "Tile the active window to the right half" 65535 124 $((MOD_FUNCTION | MOD_COMMAND | MOD_OPTION))
set_symbolic_hotkey 242 false "Tile the active window to the top half" 65535 126 $((MOD_FUNCTION | MOD_COMMAND | MOD_OPTION))
set_symbolic_hotkey 243 false "Tile the active window to the bottom half" 65535 125 $((MOD_FUNCTION | MOD_COMMAND | MOD_OPTION))
set_symbolic_hotkey 244 false "Tile the active window to the top-left quarter" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 245 false "Tile the active window to the top-right quarter" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 246 false "Tile the active window to the bottom-left quarter" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 247 false "Tile the active window to the bottom-right quarter" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 248 false "Arrange windows left and right" 65535 123 $((MOD_FUNCTION | MOD_CONTROL | MOD_SHIFT))
set_symbolic_hotkey 249 false "Arrange windows right and left" 65535 124 $((MOD_FUNCTION | MOD_CONTROL | MOD_SHIFT))
set_symbolic_hotkey 250 false "Arrange windows top and bottom" 65535 126 $((MOD_FUNCTION | MOD_CONTROL | MOD_SHIFT))
set_symbolic_hotkey 251 false "Arrange windows bottom and top" 65535 125 $((MOD_FUNCTION | MOD_CONTROL | MOD_SHIFT))
set_symbolic_hotkey 256 false "Arrange windows in quarters" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 257 false "Full-screen tile a window to the left" 65535 65535 ${MOD_NONE}
set_symbolic_hotkey 258 false "Full-screen tile a window to the right" 65535 65535 ${MOD_NONE}

if [[ -n "${SYMBOLIC_HOTKEYS_PLIST_OUTPUT:-}" ]]; then
  cp "${symbolic_hotkeys_plist}" "${SYMBOLIC_HOTKEYS_PLIST_OUTPUT}"
  printf "Generated %s symbolic keyboard shortcut definitions\n" "71"
else
  defaults import com.apple.symbolichotkeys "${symbolic_hotkeys_plist}"
  printf "Applied %s symbolic keyboard shortcut definitions\n" "71"
fi
