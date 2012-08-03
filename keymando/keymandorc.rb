# Basic -----------------------------------------------------------------------
start_at_login

disable "Remote Desktop Connection"
disable /VirtualBox/

map "<Ctrl-m>", "<Cmd-Shift-/>"
# map "<Ctrl-Shift-R>", lambda { reload() }

# Application Switching -------------------------------------------------------
map "<Ctrl-Shift-K>", lambda { activate('Firefox') }
map "<Ctrl-Shift-P>", lambda { activate('Pixelmator') }
map "<Ctrl-Shift-H>", lambda { activate('Pixen') }
map "<Ctrl-Shift-O>", lambda { activate('Rdio') }
map "<Ctrl-Shift-Y>", lambda { activate('Twitter') }

map "<Ctrl-Shift-J>" do
    activate('iTerm')
    send('<Cmd-Option-2>')
end
map "<Ctrl-Shift-M>" do
    activate('iTerm')
    send('<Cmd-Option-1>')
    send('<Ctrl-f>')
    send('2')
end
map "<Ctrl-Shift-I>" do
    activate('iTerm')
    send('<Cmd-Option-1><Ctrl-f>1')
end

# Refresh ---------------------------------------------------------------------

map "<Ctrl-Shift-R>" do
  activate('Firefox')
  send("<Cmd-r>")
  send("<Cmd-Tab>")
end

# Leader ----------------------------------------------------------------------
# map "<Ctrl-,>" do
#     input()
# end

# Abbreviations ---------------------------------------------------------------

# abbrev 'ldis' do
#   send('ಠ_ಠ')
# end
