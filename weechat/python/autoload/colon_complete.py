SCRIPT_NAME='coloncomplete'
SCRIPT_AUTHOR='Steve Losh <steve@stevelosh.com>'
SCRIPT_VERSION='1.0'
SCRIPT_LICENSE='MIT/X11'
SCRIPT_DESC='Add a colon after nick completion when all the previous words in the input are also nicks.'

import_ok=True

try:
    import weechat
except ImportError:
    print 'This script must be run under WeeChat'
    print 'You can obtain a copy of WeeChat, for free, at http://www.weechat.org'
    import_ok=False

weechat_version=0

def get_nicks(buffer, prefix=''):
    channel = weechat.buffer_get_string(buffer, 'localvar_channel')
    server = weechat.buffer_get_string(buffer, 'localvar_server')

    matches = []

    infolist = weechat.infolist_get('irc_nick', '', '%s,%s' % (server, channel))
    while weechat.infolist_next(infolist):
        nick = weechat.infolist_string(infolist, 'name')
        if nick != 'localhost' and nick.lower().startswith(prefix.lower()):
            matches.append(nick)
    weechat.infolist_free(infolist)

    return matches

def completer(data, buffer, command):
    cb = weechat.current_buffer()
    if command == "/input complete_next":
        line = weechat.buffer_get_string(cb, "input")
        words = line.split(' ')
        prefix = words[-1]
        if prefix and words and all([s.endswith(':') for s in words[:-1] if s]):
            nicks = get_nicks(cb, prefix)
            if len(nicks) == 1:
                for _ in range(len(prefix)):
                    weechat.command(buffer, "/input delete_previous_char")
                weechat.command(buffer, "/input insert " + nicks[-1] + ":\\x20")
            elif len(nicks) > 1:
                for nick in nicks:
                    weechat.prnt(cb, "==> " + nick)
                return weechat.WEECHAT_RC_OK_EAT

    return weechat.WEECHAT_RC_OK

if __name__ == "__main__" and import_ok:
    if weechat.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION, SCRIPT_LICENSE, SCRIPT_DESC, "", ""):
        weechat_version = weechat.info_get("version_number", "") or 0
        weechat.hook_command_run('/input complete*', 'completer', '')
