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

# Vim ------------------------------------------------------------------------------
class Vim < Plugin
  @oldmode = 'n'
  @mode = 'n'
  @maps = {}

  class << self; attr_accessor :mode, :maps, :oldmode; end

  def before
  end

  def fire(key)
      fn = Vim.maps[Vim.mode][key]
      if fn
          fn.call()
      else
          send(key)
      end
  end

  def tomode(m)
      oldmap = Vim.maps[Vim.mode]
      newmap = Vim.maps[m]

      oldmap.keys.each do |k|
          #unmap k
      end

      newmap.keys.each do |k|
          #map(k, lambda { self.fire(k) })
      end
  end

  def toggle()
      if Vim.mode == 'disabled'
          Vim.mode = Vim.oldmode
          system '/usr/local/bin/growlnotify -m "" -a Keymando Vim mode enabled.'
      else
          Vim.oldmode = Vim.mode
          Vim.mode = 'disabled'
          system '/usr/local/bin/growlnotify -m "" -a Keymando Vim mode disabled.'
      end
  end

  def after
      except /iTerm/, /MacVim/, /Firefox/, /PeepOpen/, /Quicksilver/, /1Password/ do
          Vim.maps['disabled'] = {}
          Vim.maps['n'] = {
              'h' => lambda { send("<Left>") },
              'j' => lambda { send("<Down>") },
              'k' => lambda { send("<Up>") },
              'l' => lambda { send("<Right>") },

              'w' => lambda { send("<Alt-Right><Alt-Right><Alt-Left>") },
              'b' => lambda { send("<Alt-Left>") },
              'e' => lambda { send("<Alt-Right>") },
              '0' => lambda { send("<Cmd-Left>") },

              'i' => lambda { Vim.mode = 'i' },
              'a' => lambda { Vim.mode = 'i'; send("<Right>") },
              'A' => lambda { Vim.mode = 'i'; send("<Ctrl-e>") },
              'I' => lambda { Vim.mode = 'i'; send("<Ctrl-a>") },
              'o' => lambda { Vim.mode = 'i'; send("<Cmd-Right><Return>") },
              'O' => lambda { Vim.mode = 'i'; send("<Cmd-Left><Return><Up>") },

              'd' => lambda { Vim.mode = 'od' },
              'c' => lambda { Vim.mode = 'oc' },

              'p' => lambda { send("<Cmd-Left><Down><Cmd-v>") },
              'P' => lambda { send("<Cmd-Left><Cmd-v>") },

              'u' => lambda { send("<Cmd-z>") },
              '<Ctrl-R>' => lambda { send("<Shift-Cmd-z>") },

              'x' => lambda { send("<Shift-Right><Cmd-x>") },

              '<Escape>' => lambda { send("<Escape>") },
          }
          Vim.maps['i'] = {
              '<Ctrl-[>' => lambda { Vim.mode = 'n' },
              '<Escape>' => lambda { Vim.mode = 'n' },
          }
          Vim.maps['od'] = {
              'w'  => lambda { send("<Shift-Alt-Right><Cmd-x>"); Vim.mode = 'n' },
              'b'  => lambda { send("<Shift-Alt-Left><Cmd-x>"); Vim.mode = 'n' },
              'd'  => lambda { send("<Cmd-Left><Shift-Down><Cmd-x>"); Vim.mode = 'n' },

              #'iw' => lambda { send("<Alt-Right><Shift-Alt-Left><Delete>"); Vim.mode = 'n' },

              '<Escape>' => lambda { Vim.mode = 'n' },
          }
          Vim.maps['oc'] = {
              'w' => lambda { send("<Shift-Alt-Right><Cmd-x>"); Vim.mode = 'i' },
              'b'  => lambda { send("<Shift-Alt-Left><Cmd-x>"); Vim.mode = 'i' },
              'c' => lambda { send("<Cmd-Left><Shift-Down><Cmd-x><Return><Up>"); Vim.mode = 'i' },

              #'iw' => lambda { send("<Alt-Right><Shift-Alt-Left><Delete>"); Vim.mode = 'i' },

              '<Escape>' => lambda { Vim.mode = 'n' },
          }

          keys = Vim.maps.values.reduce([]) do |l, m|
              l = l + m.keys
          end
          keys.uniq.each do |k|
              map(k, lambda { self.fire(k) })
          end
      end

      map "<Alt-Escape>", lambda { self.toggle }
  end
end


