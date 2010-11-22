#!/usr/bin/env python
import setpath

import unittest

#import all the tests
from test_load import *
from test_newstuff import *
from test_parserutils import *
from test_fastparser import *
from test_fastparserast import *

if __name__ == "__main__":
    from bike import logging
    logging.init()
    log = logging.getLogger("bike")
    log.setLevel(logging.WARN)
    unittest.main()
