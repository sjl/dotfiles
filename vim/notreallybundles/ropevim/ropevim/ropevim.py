"""ropevim, a vim mode for using rope refactoring library"""
import os
import tempfile

import ropemode.decorators
import ropemode.environment
import ropemode.interface
import vim


class VimUtils(ropemode.environment.Environment):

    def ask(self, prompt, default=None, starting=None):
        if starting is None:
            starting = ''
        if default is not None:
            prompt = prompt + ('[%s] ' % default)
        result = call('input("%s", "%s")' % (prompt, starting))
        if default is not None and result == '':
            return default
        return result

    def ask_values(self, prompt, values, default=None,
                   starting=None, show_values=None):
        if show_values or (show_values is None and len(values) < 14):
            self._print_values(values)
        if default is not None:
            prompt = prompt + ('[%s] ' % default)
        starting = starting or ''
        _completer.values = values
        answer = call('input("%s", "%s", "customlist,RopeValueCompleter")' %
                      (prompt, starting))
        if answer is None:
            if 'cancel' in values:
                return 'cancel'
            return
        if default is not None and not answer:
            return default
        if answer.isdigit() and 0 <= int(answer) < len(values):
            return values[int(answer)]
        return answer

    def _print_values(self, values):
        numbered = []
        for index, value in enumerate(values):
            numbered.append('%s. %s' % (index, str(value)))
        echo('\n'.join(numbered) + '\n')

    def ask_directory(self, prompt, default=None, starting=None):
        return call('input("%s", ".", "dir")' % prompt)

    def ask_completion(self, prompt, values, starting=None):
        if self.get('vim_completion') and 'i' in call('mode()'):
            col = int(call('col(".")'))
            if starting:
                col -= len(starting)
            vim.command('call complete(%s, %s)' % (col, values))
            return None
        return self.ask_values(prompt, values, starting=starting,
                               show_values=False)

    def message(self, message):
        echo(message)

    def yes_or_no(self, prompt):
        return self.ask_values(prompt, ['yes', 'no']) == 'yes'

    def y_or_n(self, prompt):
        return self.yes_or_no(prompt)

    def get(self, name, default=None):
        vimname = 'g:ropevim_%s' % name
        if str(vim.eval('exists("%s")' % vimname)) == '0':
            return default
        result = vim.eval(vimname)
        if result.isdigit():
            return int(result)
        return result

    def get_offset(self):
        result = self._position_to_offset(*vim.current.window.cursor)
        return result

    def _position_to_offset(self, lineno, colno):
        result = min(colno, len(self.buffer[lineno -1]) + 1)
        for line in self.buffer[:lineno-1]:
            result += len(line) + 1
        return result

    def get_text(self):
        return '\n'.join(self.buffer) + '\n'

    def get_region(self):
        start = self._position_to_offset(*self.buffer.mark('<'))
        end = self._position_to_offset(*self.buffer.mark('>'))
        return start, end

    @property
    def buffer(self):
        return vim.current.buffer

    def filename(self):
        return self.buffer.name

    def is_modified(self):
        return vim.eval('&modified')

    def goto_line(self, lineno):
        vim.current.window.cursor = (lineno, 0)

    def insert_line(self, line, lineno):
        self.buffer[lineno - 1:lineno - 1] = [line]

    def insert(self, text):
        lineno, colno = vim.current.window.cursor
        line = self.buffer[lineno - 1]
        self.buffer[lineno - 1] = line[:colno] + text + line[colno:]
        vim.current.window.cursor = (lineno, colno + len(text))

    def delete(self, start, end):
        lineno1, colno1 = self._offset_to_position(start - 1)
        lineno2, colno2 = self._offset_to_position(end - 1)
        lineno, colno = vim.current.window.cursor
        if lineno1 == lineno2:
            line = self.buffer[lineno1 - 1]
            self.buffer[lineno1 - 1] = line[:colno1] + line[colno2:]
            if lineno == lineno1 and colno >= colno1:
                diff = colno2 - colno1
                vim.current.window.cursor = (lineno, max(0, colno - diff))

    def _offset_to_position(self, offset):
        text = self.get_text()
        lineno = text.count('\n', 0, offset) + 1
        try:
            colno = offset - text.rindex('\n', 0, offset) - 1
        except ValueError:
            colno = offset
        return lineno, colno

    def filenames(self):
        result = []
        for buffer in vim.buffers:
            if buffer.name:
                result.append(buffer.name)
        return result

    def save_files(self, filenames):
        vim.command('wall')

    def reload_files(self, filenames, moves={}):
        initial = self.filename()
        for filename in filenames:
            self.find_file(moves.get(filename, filename), force=True)
        if initial:
            self.find_file(initial)

    def find_file(self, filename, readonly=False, other=False, force=False):
        if filename != self.filename() or force:
            if other:
                vim.command('new')
            vim.command('e %s' % filename)
            if readonly:
                vim.command('set nomodifiable')

    def create_progress(self, name):
        return VimProgress(name)

    def current_word(self):
        pass

    def push_mark(self):
        vim.command('mark `')

    def prefix_value(self, prefix):
        return prefix

    def show_occurrences(self, locations):
        self._quickfixdefs(locations)

    def _quickfixdefs(self, locations):
        filename = os.path.join(tempfile.gettempdir(), tempfile.mktemp())
        try:
            self._writedefs(locations, filename)
            vim.command('let old_errorfile = &errorfile')
            vim.command('let old_errorformat = &errorformat')
            vim.command('set errorformat=%f:%l:\ %m')
            vim.command('cfile ' + filename)
            vim.command('let &errorformat = old_errorformat')
            vim.command('let &errorfile = old_errorfile')
        finally:
            os.remove(filename)

    def _writedefs(self, locations, filename):
        tofile = open(filename, 'w')
        try:
            for location in locations:
                err = '%s:%d: - %s\n' % (location.filename,
                                         location.lineno, location.note)
                echo(err)
                tofile.write(err)
        finally:
            tofile.close()

    def show_doc(self, docs, altview=False):
        if docs:
            echo(docs)

    def preview_changes(self, diffs):
        echo(diffs)
        return self.y_or_n('Do the changes? ')

    def local_command(self, name, callback, key=None, prefix=False):
        self._add_command(name, callback, key, prefix,
                          prekey=self.get('local_prefix'))

    def global_command(self, name, callback, key=None, prefix=False):
        self._add_command(name, callback, key, prefix,
                          prekey=self.get('global_prefix'))

    def add_hook(self, name, callback, hook):
        mapping = {'before_save': 'FileWritePre,BufWritePre',
                   'after_save': 'FileWritePost,BufWritePost',
                   'exit': 'VimLeave'}
        self._add_function(name, callback)
        vim.command('autocmd %s *.py call %s()' %
                    (mapping[hook], _vim_name(name)))

    def _add_command(self, name, callback, key, prefix, prekey):
        self._add_function(name, callback, prefix)
        vim.command('command! -range %s call %s()' %
                    (_vim_name(name), _vim_name(name)))
        if key is not None:
            key = prekey + key.replace(' ', '')
            vim.command('map %s :call %s()<cr>' % (key, _vim_name(name)))

    def _add_function(self, name, callback, prefix=False):
        globals()[name] = callback
        arg = 'None' if prefix else ''
        vim.command('function! %s()\n' % _vim_name(name) +
                    'python ropevim.%s(%s)\n' % (name, arg) +
                    'endfunction\n')


def _vim_name(name):
    tokens = name.split('_')
    newtokens = ['Rope'] + [token.title() for token in tokens]
    return ''.join(newtokens)


class VimProgress(object):

    def __init__(self, name):
        self.name = name
        self.last = 0
        echo('%s ... ' % self.name)

    def update(self, percent):
        try:
            vim.eval('getchar(0)')
        except vim.error:
            raise KeyboardInterrupt('Task %s was interrupted!' % self.name)
        if percent > self.last + 4:
            echo('%s ... %s%%%%' % (self.name, percent))
            self.last = percent

    def done(self):
        echo('%s ... done' % self.name)


def echo(message):
    vim.command('echo "%s"' % message.replace('\n', '\\n').replace('"', '\\"'))

def call(command):
    return vim.eval(command)


class _ValueCompleter(object):

    def __init__(self):
        self.values = []
        vim.command('python import vim')
        vim.command('function! RopeValueCompleter(A, L, P)\n'
                    'python args = [vim.eval("a:" + p) for p in "ALP"]\n'
                    'python ropevim._completer(*args)\n'
                    'return s:completions\n'
                    'endfunction\n')

    def __call__(self, arg_lead, cmd_line, cursor_pos):
        result = [value for value in self.values if value.startswith(arg_lead)]
        vim.command('let s:completions = %s' % result)


variables = {'ropevim_enable_autoimport': 1,
             'ropevim_autoimport_underlineds': 0,
             'ropevim_codeassist_maxfixes' : 1,
             'ropevim_enable_shortcuts' : 1,
             'ropevim_autoimport_modules': '[]',
             'ropevim_confirm_saving': 0,
             'ropevim_local_prefix': '"<C-c>r"',
             'ropevim_global_prefix': '"<C-x>p"',
             'ropevim_vim_completion': 0,
             'ropevim_guess_project': 0}

shortcuts = {'code_assist': '<M-/>',
             'lucky_assist': '<M-?>',
             'goto_definition': '<C-c>g',
             'show_doc': '<C-c>d',
             'find_occurrences': '<C-c>f'}

insert_shortcuts = {'code_assist': '<M-/>',
                    'lucky_assist': '<M-?>'}

def _init_variables():
    for variable, default in variables.items():
        vim.command('if !exists("g:%s")\n' % variable +
                    '  let g:%s = %s\n' % (variable, default))

def _enable_shortcuts(env):
    if env.get('enable_shortcuts'):
        for command, shortcut in shortcuts.items():
            vim.command('map %s :call %s()<cr>' %
                        (shortcut, _vim_name(command)))
        for command, shortcut in insert_shortcuts.items():
            command_name = _vim_name(command) + 'InsertMode'
            vim.command('func! %s()\n' % command_name +
                        'call %s()\n' % _vim_name(command) +
                        'return ""\n'
                        'endfunc')
            vim.command('imap %s <C-R>=%s()<cr>' % (shortcut, command_name))

def _add_menu(env):
    project = ['open_project', 'close_project', 'find_file', 'undo', 'redo']
    refactor = ['rename', 'extract_variable', 'extract_method', 'inline',
                'move', 'restructure', 'use_function', 'introduce_factory',
                'change_signature', 'rename_current_module',
                'move_current_module', 'module_to_package']
    assists = ['code_assist', 'goto_definition', 'show_doc', 'find_occurrences',
               'lucky_assist', 'jump_to_global', 'show_calltip']
    vim.command('silent! aunmenu Ropevim')
    for index, items in enumerate([project, assists, refactor]):
        if index != 0:
            vim.command('amenu <silent> &Ropevim.-SEP%s- :' % index)
        for name in items:
            item = '\ '.join(token.title() for token in name.split('_'))
            for command in ['amenu', 'vmenu']:
                vim.command('%s <silent> &Ropevim.%s :call %s()<cr>' %
                            (command, item, _vim_name(name)))


ropemode.decorators.logger.message = echo
ropemode.decorators.logger.only_short = True
_completer = _ValueCompleter()

_init_variables()
_env = VimUtils()
_interface = ropemode.interface.RopeMode(env=_env)
_interface.init()
_enable_shortcuts(_env)
_add_menu(_env)
