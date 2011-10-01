#!/usr/bin/env python

import os, subprocess

def parse_filename(l):
    ns = l.split(' ', 3)[-1].rsplit('/', 1)[0]
    return os.path.join('./test', *ns.split('.')) + '.clj'

def process_error(fn, l, lines):
    lnum = int(l.rsplit(' ', 1)[-1].split(':')[-1])

    message = lines.pop(0)

    print '%s:%d:%s' % (fn, lnum, message)

    return message

if __name__ == '__main__':
    out = subprocess.check_output(r"cake test | perl -pe 's/\e\[?.*?[\@-~]//g'", shell=True)

    prev = ""
    fn = None
    lines = out.splitlines()
    while lines:
        l = lines.pop(0)
        if l.startswith('cake test ') and '/' in l:
            fn = parse_filename(l)

        if l.startswith('FAIL!'):
            prev = process_error(fn, l, lines)
        else:
            prev = l

