#!/usr/bin/python
import re, commands
def get_keychain_pass(account=None, server=None):
    params = {
        'security': '/usr/bin/security',
        'command': 'find-internet-password',
        'account': account,
        'server': server
    }
    command = "%(security)s %(command)s -g -a %(account)s -s %(server)s" % params
    outtext = commands.getoutput(command)
    return re.match(r'password: "(.*)"', outtext).group(1)