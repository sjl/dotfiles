###################################################################################################
# ConqueScreen is an extention of the vim.current.buffer object
# It restricts the working indices of the buffer object to the scroll region which pty is expecting
# It also uses 1-based indexes, to match escape sequence commands
#
# E.g.:
#   s = ConqueScreen()
#   ...
#   s[5] = 'Set 5th line in terminal to this line'
#   s.append('Add new line to terminal')
#   s[5] = 'Since previous append() command scrolled the terminal down, this is a different line than first cb[5] call'
#

import vim

class ConqueScreen(object):

    # CLASS PROPERTIES  {{{

    # the buffer
    buffer          = None

    # screen and scrolling regions
    screen_top      = 1

    # screen width
    screen_width    = 80
    screen_height    = 80

    # }}}

    def __init__(self): # {{{
        self.buffer = vim.current.buffer

        self.screen_top = 1
        self.screen_width = vim.current.window.width
        self.screen_height = vim.current.window.height
    # }}}

    ###############################################################################################
    # List overload {{{
    def __len__(self): # {{{
        return len(self.buffer)
    # }}}

    def __getitem__(self, key): # {{{
        real_line = self.get_real_idx(key)

        # if line is past buffer end, add lines to buffer
        if real_line >= len(self.buffer):
            for i in range(len(self.buffer), real_line + 1):
                self.append(' ' * self.screen_width)

        return self.buffer[ real_line ]
    # }}}

    def __setitem__(self, key, value): # {{{
        real_line = self.get_real_idx(key)

        # if line is past end of screen, append
        if real_line == len(self.buffer):
            self.buffer.append(value)
        else:
            self.buffer[ real_line ] = value
    # }}}

    def __delitem__(self, key): # {{{
        del self.buffer[ self.screen_top + key - 2 ]
    # }}}

    def append(self, value): # {{{
        if len(self.buffer) > self.screen_top + self.screen_height - 1:
            self.buffer[len(self.buffer) - 1] = value
        else:
            self.buffer.append(value)
        logging.debug('checking new line ' + str(len(self.buffer)) + ' against top ' + str(self.screen_top) + ' + height ' + str(self.screen_height) + ' - 1 = ' + str(self.screen_top + self.screen_height - 1))
        if len(self.buffer) > self.screen_top + self.screen_height - 1:
            self.screen_top += 1
        if vim.current.buffer.number == self.buffer.number:
            vim.command('normal G')
    # }}}

    def insert(self, line, value): # {{{
        logging.debug('insert at line ' + str(self.screen_top + line - 2))
        l = self.screen_top + line - 2
        self.buffer[l:l] = [ value ]
    
    # }}}
    # }}}

    ###############################################################################################
    # Util {{{
    def get_top(self): # {{{
        return self.screen_top
    # }}}

    def get_real_idx(self, line): # {{{
        return (self.screen_top + line - 2)
    # }}}

    def get_real_line(self, line): # {{{
        return (self.screen_top + line - 1)
    # }}}

    def set_screen_width(self, width): # {{{
        self.screen_width = width
    # }}}

    # }}}

    ###############################################################################################
    def clear(self): # {{{
        self.buffer.append(' ')
        vim.command('normal Gzt')
        self.screen_top = len(self.buffer)
    # }}}

    def set_cursor(self, line, column): # {{{
        # figure out line
        real_line =  self.screen_top + line - 1
        if real_line > len(self.buffer):
            for l in range(len(self.buffer) - 1, real_line):
                self.buffer.append('')

        # figure out column
        real_column = column
        if len(self.buffer[real_line - 1]) < real_column:
            self.buffer[real_line - 1] = self.buffer[real_line - 1] + ' ' * (real_column - len(self.buffer[real_line - 1]))

        # python version is occasionally grumpy
        try:
            vim.current.window.cursor = (real_line, real_column - 1)
        except:
            vim.command('call cursor(' + str(real_line) + ', ' + str(real_column) + ')')
    # }}}

    def reset_size(self, line): # {{{
        logging.debug('buffer len is ' + str(len(self.buffer)))
        logging.debug('buffer height ' + str(vim.current.window.height))
        logging.debug('old screen top was ' + str(self.screen_top))

        # save cursor line number
        real_line = self.screen_top + line

        # reset screen size
        self.screen_width = vim.current.window.width
        self.screen_height = vim.current.window.height
        self.screen_top = len(self.buffer) - vim.current.window.height + 1
        if self.screen_top < 1:
            self.screen_top = 1
        logging.debug('new screen top is  ' + str(self.screen_top))

        # align bottom of buffer to bottom of screen
        vim.command('normal ' + str(self.screen_height) + 'kG')

        # return new relative line number
        return (real_line - self.screen_top)
    # }}}

    def scroll_to_bottom(self): # {{{
        vim.current.window.cursor = (len(self.buffer) - 1, 1)
    # }}}
        
    def align(self): # {{{
        # align bottom of buffer to bottom of screen
        vim.command('normal ' + str(self.screen_height) + 'kG')
    # }}}


