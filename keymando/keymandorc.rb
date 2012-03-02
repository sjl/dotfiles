# Basic ----------------------------------------------------------------------------
start_at_login

disable "Remote Desktop Connection"
disable /VirtualBox/

map "<Ctrl-m>", "<Cmd-Shift-/>"
map "<Ctrl-Shift-R>", lambda { reload() }

# Application Switching ------------------------------------------------------------
map "<Ctrl-Shift-J>", lambda { activate('Firefox') }
map "<Ctrl-Shift-P>", lambda { activate('Pixelmator') }
map "<Ctrl-Shift-B>", lambda { activate('Pixen') }
map "<Ctrl-Shift-K>", lambda { activate('MacVim') }
map "<Ctrl-Shift-H>", lambda { activate('iTerm') }
map "<Ctrl-Shift-O>", lambda { activate('Rdio') }
map "<Ctrl-Shift-Y>", lambda { activate('Twitter') }

map "<Ctrl-Shift-M>" do
    activate('iDvtm')
    send('<Ctrl-f>2')
end
map "<Ctrl-Shift-I>" do
    activate('iDvtm')
    send('<Ctrl-f>1')
end

# Leader ---------------------------------------------------------------------------
# map "<Ctrl-,>" do
#     input()
# end

# Abbreviations --------------------------------------------------------------------

# abbrev 'ldis' do
#   pasteBoard = NSPasteboard.generalPasteboard
#   pasteBoard.declareTypes([NSStringPboardType], owner: nil)
#   pasteBoard.setString('ಠ_ಠ', forType: NSStringPboardType)
#   send('<Cmd-v>')
# end
