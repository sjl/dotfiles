# Basic -----------------------------------------------------------------------
start_at_login

disable "Remote Desktop Connection"
disable /VirtualBox/

map "<Ctrl-m>", "<Cmd-Shift-/>"
# map "<Ctrl-Shift-R>", lambda { reload() }

# Application Switching -------------------------------------------------------
map "<Ctrl-Shift-J>", lambda { activate('Firefox') }
map "<Ctrl-Shift-P>", lambda { activate('Pixelmator') }
map "<Ctrl-Shift-H>", lambda { activate('Pixen') }
map "<Ctrl-Shift-K>", lambda { activate('iTerm') }
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
