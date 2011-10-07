# Basic ----------------------------------------------------------------------------
start_at_login

disable "Remote Desktop Connection"
disable /VirtualBox/

map "<Ctrl-m>", "<Ctrl-F2>"
map "<Ctrl-Shift-R>", lambda { reload() }

# Application Switching ------------------------------------------------------------
map "<Ctrl-Shift-J>", lambda { activate('Firefox') }
map "<Ctrl-Shift-K>", lambda { activate('MacVim') }
map "<Ctrl-Shift-M>" do
    activate('iTerm')
    sleep(1)
    send('<Ctrl-f>')
    send('3')
end
map "<Ctrl-Shift-G>" do
    activate('iTerm')
    sleep(1)
    send('<Ctrl-f>')
    send('1')
end

# Leader ---------------------------------------------------------------------------
map "<Ctrl-,>" do
    input()
end

# Abbreviations --------------------------------------------------------------------

# abbrev 'ldis' do
#   pasteBoard = NSPasteboard.generalPasteboard
#   pasteBoard.declareTypes([NSStringPboardType], owner: nil)
#   pasteBoard.setString('ಠ_ಠ', forType: NSStringPboardType)
#   send('<Cmd-v>')
# end
