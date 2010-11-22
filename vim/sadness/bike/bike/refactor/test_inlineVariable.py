#!/usr/bin/env python
import setpath
import unittest
from bike.testutils import trimLines,createAST, BRMTestCase
from inlineVariable import inlineLocalVariable_old

class TestInlineLocalVariable(BRMTestCase):

    def test_worksWhenUserDoesItAgainstReference(self):
        srcBefore=r"""
        def foo():
            b = 'hello'
            print b
        """
        srcAfter=r"""
        def foo():
            print 'hello'
        """

        self.helper( srcBefore, 3, 10, srcAfter )

    def test_worksWhenInlinedCodeIsOverTwoLines(self):
        srcBefore=r"""
        def foo():
            b = 3 + \
                2
            print b
        """

        srcAfter=r"""
        def foo():
            print 3 + \
                2
        """

        self.helper(srcBefore, 2, 4, srcAfter)

    ''' Needs Adding Again 
    def test_addsBracketsWhenInlinedCodeHasPresidenceOverSurroundingCode(self):
        srcBefore=trimLines(r"""
        def foo():
            b = 3 + 2
            print 3 * b
        """)
        srcAfter=trimLines(r"""
        def foo():
            print 3 * (3 + 2)
        """)
        assert 0
    '''

    def test_worksWithMultipleInstancesOfVariableOnLine(self):
        srcBefore=r"""
        def foo():
            x = 11
            print x, x
        """

        srcAfter=r"""
        def foo():
            print 11, 11
        """
        
        self.helper(srcBefore, 2, 4, srcAfter)

    def test_worksWithMultipleMultilineCode(self):
        srcBefore=r"""
        def foo():
            b = 3 + \
                2
            print b
            print b
        """

        srcAfter=r"""
        def foo():
            print 3 + \
                2
            print 3 + \
                2
        """

        self.helper(srcBefore, 2, 4, srcAfter)

    ''' Can't do this without some hairy logic to deduce how to inline
        the variables. E.g. how do you inline a,b = foo() ?

    def test_handlesTupleAssignment(self):
        srcBefore=r"""
        def foo():
            x, y = 1, 2
            print x
            print y
        """

        srcAfter=r"""
        def foo():
            y = 2
            print 1
            print y
        """
        
        self.helper(srcBefore, 2, 4, srcAfter)
    '''


    def helper(self, srcBefore, y, x, srcAfter):
        sourcenode = createAST(trimLines(srcBefore))
        inlineLocalVariable_old(sourcenode,y,x)
        self.assertEqual(sourcenode.getSource(),trimLines(srcAfter))

if __name__ == "__main__":
    unittest.main()

