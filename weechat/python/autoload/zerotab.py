# -*- coding: utf-8 -*-
#
# Script Name: Zerotab.py
# Script Author: Lucian Adamson <lucian.adamson@yahoo.com>
# Script License: GPL
# Alternate Contact: Freenode IRC nick i686
#
# 2011-09-20, Nils GÃ¶rs <weechatter@arcor.de>:
#     version 1.4: fixed: latest nick from join/part messages were used.
# 2010-12-04, Sebastien Helleu <flashcode@flashtux.org>:
#     version 1.3: use tag "nick_xxx" (WeeChat >= 0.3.4 only)
# 2010-08-03, Sebastien Helleu <flashcode@flashtux.org>:
#     version 1.2: fix bug with nick prefixes (op/halfop/..)
# 2010-08-03, Sebastien Helleu <flashcode@flashtux.org>:
#     version 1.1: fix bug with self nick


SCRIPT_NAME='zerotab'
SCRIPT_AUTHOR='Lucian Adamson <lucian.adamson@yahoo.com>'
SCRIPT_VERSION='1.4'
SCRIPT_LICENSE='GPL'
SCRIPT_DESC='Will tab complete the last nick in channel without typing anything first. This is good for rapid conversations.'

import_ok=True

try:
    import weechat, re
except ImportError:
    print 'This script must be run under WeeChat'
    print 'You can obtain a copy of WeeChat, for free, at http://www.weechat.org'
    import_ok=False

latest_speaker={}
weechat_version=0

def my_completer(data, buffer, command):
    global latest_speaker
    str_input = weechat.buffer_get_string(weechat.current_buffer(), "input")
    if command == "/input complete_next" and str_input == '':
        nick = latest_speaker.get(buffer, "")
        if nick != "":
            weechat.command(buffer, "/input insert " + nick)
    return weechat.WEECHAT_RC_OK

def hook_print_cb(data, buffer, date, tags, displayed, highlight, prefix, message):
    global latest_speaker
    alltags = tags.split(',')
    if 'notify_message' in alltags:
        nick = None
        if int(weechat_version) >= 0x00030400:
            # in version >= 0.3.4, there is a tag "nick_xxx" for each message
            for tag in alltags:
                if tag.startswith('nick_'):
                    nick = tag[5:]
                    break
        else:
            # in older versions, no tag, so extract nick from printed message
            # this is working, except for irc actions (/me ...)
            nick = prefix
            if re.match('^[@%+~*&!-]', nick):
                nick = nick[1:]
        if nick:
            local_nick = weechat.buffer_get_string(buffer, "localvar_nick")
            if nick != local_nick:
                latest_speaker[buffer] = nick
    return weechat.WEECHAT_RC_OK

if __name__ == "__main__" and import_ok:
    if weechat.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION, SCRIPT_LICENSE, SCRIPT_DESC, "", ""):
        weechat_version = weechat.info_get("version_number", "") or 0
        weechat.hook_print("", "", "", 1, "hook_print_cb", "")
        weechat.hook_command_run('/input complete*', 'my_completer', '')
