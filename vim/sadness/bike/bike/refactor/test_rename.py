#!/usr/bin/env python
import setpath
import unittest
from bike import testdata
from rename import rename
from bike.testutils import *

class TestRenameTemporary(BRMTestCase):
    def test_renamesSimpleReferencesGivenAssignment(self):
        src=trimLines("""
        def foo():
            a = 3
            print a
        """)
        srcAfter=trimLines("""
        def foo():
            b = 3
            print b
        """)
        src = self.helper(src,"",2,4,"b")
        self.assertEqual(srcAfter,src)

    def helper(self, src, classsrc, line, col, newname):
        try:
            createPackageStructure(src,classsrc)
            filename = pkgstructureFile1
            rename(filename,line,col,newname)
            # modify me once save is moved
            #return readFile(filename)
            from bike.transformer.save import outputqueue
            return outputqueue[filename]
        finally:
            removePackageStructure()
if __name__ == "__main__":
    unittest.main()
