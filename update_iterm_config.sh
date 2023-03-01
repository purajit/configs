#!/bin/bash
# copies current iterm config, converts to xml, and removes the username so that setup.sh can reuse it
# as expected
command cp ~/Library/Preferences/com.googlecode.iterm2.plist com.googlecode.iterm2.xml
plutil -convert xml1 com.googlecode.iterm2.xml
sed -i '' "s/$USER/{}/g" com.googlecode.iterm2.xml
