#!/usr/bin/python
# Original source: http://forrst.com/posts/An_unball_script_for_vimball_plugins-CHM

import os, sys

if len(sys.argv) < 2:
    raise SystemExit('usage: python castrate.py annoying.vba bundle/annoying')

infile = sys.argv[1]

vba_dir = os.path.splitext(infile)[0]
if len(sys.argv) > 2:
    vba_dir = sys.argv[2]

if os.path.exists(vba_dir):
    raise SystemExit('The location ' + vba_dir + ' already exists. '
                     'Please delete/move it or give a different folder to extract into.')

lines = open(infile).read().splitlines()
vbasize = len(lines)
i = 0

while i < vbasize:
    line = lines[i]
    if line.endswith('\t[[[1'):
        path = line.rstrip('\t[[[1').replace('\\', '/')
        size = int(lines[i + 1])
        content = '\n'.join(lines[i + 2 : i + 2 + size])
        relpath = os.path.join(vba_dir, path)
        dirname = os.path.dirname(relpath)
        if not os.path.exists(dirname):
            os.makedirs(dirname)
        open(relpath, 'w').write(content)
        print 'wrote', path
        i += 2 + size
    else:
        i += 1

print 'Unballed', infile, 'into', vba_dir
print 'And hence the world rests in peace'

