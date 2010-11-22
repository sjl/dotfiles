import sys,os
if not os.path.abspath("../..") in sys.path:
    from bike import log
    print >> log.warning, "Appending to the system path. This should only happen in unit tests"
    sys.path.append(os.path.abspath("../.."))
