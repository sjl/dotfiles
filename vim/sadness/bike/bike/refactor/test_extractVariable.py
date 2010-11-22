#!/usr/bin/env python
import setpath
import unittest
from bike.testutils import *
from bike.refactor.extractVariable import coords, extractLocalVariable

class TestExtractLocalVariable(BRMTestCase):
    def test_worksOnSimpleCase(self):
        srcBefore=trimLines("""
        def foo():
            print 3 + 2
        """)
        srcAfter=trimLines("""
        def foo():
            a = 3 + 2
            print a
        """)
        sourcenode = createAST(srcBefore)
        extractLocalVariable(tmpfile,coords(2,10),coords(2,15),'a')
        self.assertEqual(sourcenode.getSource(),srcAfter)

    def test_worksIfCoordsTheWrongWayRound(self):
        srcBefore=trimLines("""
        def foo():
            print 3 + 2
        """)
        srcAfter=trimLines("""
        def foo():
            a = 3 + 2
            print a
        """)
        sourcenode = createAST(srcBefore)
        extractLocalVariable(tmpfile,coords(2,15),coords(2,10),'a')
        self.assertEqual(sourcenode.getSource(),srcAfter)

        
if __name__ == "__main__":
    unittest.main()


