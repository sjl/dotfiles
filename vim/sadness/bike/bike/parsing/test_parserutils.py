#!/usr/bin/env python
import unittest
from parserutils import *
from bike.testutils import *

class TestRemoveEscapedQuotes(BRMTestCase):

    def testMaskEscapedQuotes_MasksEscapedQuotes(self):
        src = '\" \\\\\\\" \' \\\\\\\\\"  \'  \''
        self.assertEqual(maskEscapedQuotes(src),'" **** \' ****"  \'  \'')

class TestMungePythonKeywordsInStrings(BRMTestCase):
    def test_mungesKeywords(self):
        src = '\"\"\"class try while\"\"\" class2 try2 while2 \'\'\' def if for \'\'\' def2 if2 for2'
        self.assertEqual(maskPythonKeywordsInStringsAndComments(src),
                      '"""CLASS TRY WHILE""" class2 try2 while2 \'\'\' DEF IF FOR \'\'\' def2 if2 for2')


class TestSplitLines(BRMTestCase):
    def test_handlesExplicitlyContinuedLineWithComment(self):
        self.assertEqual(splitLogicalLines(explicitlyContinuedLineWithComment),
              ['\n', 'z = a + b + \\  # comment\n  c + d\n', 'pass\n'])

    def test_handlesImplicitlyContinuedLine(self):
        self.assertEqual(splitLogicalLines(implicitlyContinuedLine), 
                         ['\n', 'z = a + b + (\n  c + d)\n', 'pass\n'])

    def test_handlesNestedImplicitlyContinuedLine(self):
        self.assertEqual(splitLogicalLines(implicitlyContinuedLine2), 
                         ['\n', 'z = a + b + ( c + [d\n  + e]\n  + f)   # comment\n', 'pass\n'])


    def test_handlesMultiLineStrings(self):
        self.assertEqual(splitLogicalLines(multilineComment),
                         ['\n', "''' this is an mlc\nso is this\n'''\n", 'pass\n'])
                         

class TestMakeLineParseable(BRMTestCase):
    def test_worksWithIfStatement(self):
        src = "if foo:"
        self.assertEqual(makeLineParseable(src),("if foo: pass"))

    def test_worksWithTryStatement(self):
        src = "try :"
        self.assertEqual(makeLineParseable(src),("try : pass\nexcept: pass"))

    def test_worksOnTryStatementWithCodeInlined(self):
        src = "try : a = 1"
        self.assertEqual(makeLineParseable(src),("try : a = 1\nexcept: pass"))

    def test_worksWithExceptStatement(self):
        src = "except :"
        self.assertEqual(makeLineParseable(src),("try: pass\nexcept : pass"))

    def test_worksWithFinallyStatement(self):
        src = "finally:"
        self.assertEqual(makeLineParseable(src),("try: pass\nfinally: pass"))

    def test_worksWithIfStatement(self):
        src = "if foo:"
        self.assertEqual(makeLineParseable(src),("if foo: pass"))

    def test_worksWithElseStatement(self):
        src = "else :"
        self.assertEqual(makeLineParseable(src),("if 0: pass\nelse : pass"))

    def test_worksWithElifStatement(self):
        src = "elif foo:"
        self.assertEqual(makeLineParseable(src),("if 0: pass\nelif foo: pass"))


def runOverPath(path):
    import compiler
    from parser import ParserError
    from bike.parsing.load import getFilesForName
    files = getFilesForName(path)
    for fname in files:
        print fname
        src = file(fname).read()
        #print src
        src = maskStringsAndRemoveComments(src)

        for logicalline in splitLogicalLines(src):
            #print "logicalline=",logicalline    
            logicalline = logicalline.strip()
            logicalline = makeLineParseable(logicalline)
            try:
                compiler.parse(logicalline)
            except ParserError:
                print "ParserError on logicalline:",logicalline
            except:
                log.exception("caught exception")
                

explicitlyContinuedLineWithComment = """
z = a + b + \  # comment
  c + d
pass
"""

implicitlyContinuedLine = """
z = a + b + (
  c + d)
pass
"""


implicitlyContinuedLine2 = """
z = a + b + ( c + [d
  + e]
  + f)   # comment
pass
"""

multilineComment = """
''' this is an mlc
so is this
'''
pass
"""

if __name__ == "__main__":
    from bike import logging
    logging.init()
    log = logging.getLogger("bike")
    log.setLevel(logging.INFO)
    
    # add soak tests to end of test
    class Z_SoakTest(BRMTestCase):
        def test_linesRunThroughPythonParser(self):
            print ""
            #print splitLogicalLines(file('/usr/local/lib/python2.2/aifc.py').read())
            #runOverPath('/usr/local/lib/python2.2/test/badsyntax_nocaret.py')
            runOverPath('/usr/local/lib/python2.2/')
    unittest.main()
