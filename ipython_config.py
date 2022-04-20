c = get_config()

# Disable the initial welcome banner text
c.TerminalIPythonApp.display_banner = False

# Exit immediately without confirmation
c.InteractiveShell.confirm_exit = False

# Enable automatic code reloading
c.InteractiveShellApp.extensions = ['autoreload']
c.InteractiveShellApp.exec_lines = ['%autoreload 2']
