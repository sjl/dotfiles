#!/usr/bin/env python

import sys
import os,glob
from distutils.core import setup

# check version
if sys.version_info[0] < 2 or sys.version_info[0] == 2 and sys.version_info[1] < 2:
    print "Python versions below 2.2 not supported"
    sys.exit(0)


setup(name="bicyclerepair",
      version="0.9",
      description="Bicycle Repair Man, the Python refactoring tool",
      maintainer="Phil Dawes",
      maintainer_email="pdawes@users.sourceforge.net",
      url="http://bicyclerepair.sourceforge.net",
      packages=['','bike','bike.refactor','bike.parsing','bike.query','bike.transformer'],
      package_dir = {'bike':'bike','':'ide-integration'}
      )

