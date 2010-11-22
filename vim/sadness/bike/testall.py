#!/usr/bin/env python

import sys,os

# check version
if sys.version_info[0] < 2 or sys.version_info[0] == 2 and sys.version_info[1] < 2:
    print "Python versions below 2.2 not supported"
    sys.exit(0)

if not os.path.abspath(".") in sys.path:
    sys.path.append(os.path.abspath("."))


from bike import logging

from bike.test_testutils import *
from bike.parsing.testall import *
from bike.query.testall import *
from bike.refactor.testall import *
from bike.testall import *

if __name__ == "__main__":
    from bike import logging
    logging.init()
    log = logging.getLogger("bike")
    log.setLevel(logging.WARN)
    unittest.main()
