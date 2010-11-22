#!/usr/bin/env python
import unittest
from fastparser import*
from bike.parsing.load import*
from bike.parsing.fastparserast import*
from bike.testutils import *

class TestFastParser(BRMTestCase):
    def test_doesntGetClassDeclsInMLStrings(self):
        src = trimLines('''
        """
        class foo bah
        """
        ''')
        root = fastparser(src)
        assert root.getChildNodes() == []

    def test_evaluatesMLStringWithQuoteInIt(self):
        src = trimLines('''
        """some ml comment inclosing a " """
        def foo:
            pass 
        " hello "
        ''')
        root = fastparser(src)
        assert root.getChildNodes() != []

    def test_handlesClassDefsWithTwoSpacesInDecl(self):
        src = trimLines('''
        class  foo: pass
        ''')
        root = fastparser(src)
        assert root.getChildNodes() != []
        
    def test_handlesFnDefsWithTwoSpacesInDecl(self):
        src = trimLines('''
        def  foo: pass
        ''')
        root = fastparser(src)
        assert root.getChildNodes() != []


MLStringWithQuoteInIt = """
\"\"\"some ml comment inclosing a \" \"\"\"
def foo:
    pass
\" hello \"
"""

def load(path):
    files = getFilesForName(path)
    for fname in files:
        src = file(fname).read()
        fastparser(src)
        #print fname
        #myroot = parseFile(fname)



def fastparsetreeToString(root):
    class stringholder: pass
    s = stringholder()
    s.mystr = ""
    s.tabstr = ""
    def t2s(node):
        if isinstance(node, Class):
            s.mystr+=s.tabstr+"class "+node.name+"\n"
            s.tabstr+="\t"
            for n in node.getChildNodes():
                t2s(n)
            s.tabstr = s.tabstr[:-1]

        elif isinstance(node, Function):
            s.mystr+=s.tabstr+"function "+node.name+"\n"
            s.tabstr+="\t"
            for n in node.getChildNodes():
                t2s(n)
            s.tabstr = s.tabstr[:-1]


    for n in root.getChildNodes():
        t2s(n)
    return s.mystr


def compilerParseTreeToString(root):
    try:
        class TreeVisitor:
            def __init__(self):
                self.mystr = ""
                self.tabstr = ""

            def visitClass(self, node):
                self.mystr+=self.tabstr+"class "+node.name+"\n"
                self.tabstr+="\t"
                for child in node.getChildNodes():
                    self.visit(child)
                self.tabstr = self.tabstr[:-1]

            def visitFunction(self, node):
                self.mystr+=self.tabstr+"function "+node.name+"\n"
                self.tabstr+="\t"
                for child in node.getChildNodes():
                    self.visit(child)
                self.tabstr = self.tabstr[:-1]

        return compiler.walk(root, TreeVisitor()).mystr

    except:
        log.exception("ex")
        import sys
        sys.exit(0)


def compareCompilerWithFastparserOverPath(path):
    from bike.parsing.load import getFilesForName
    files = getFilesForName(path)
    for fname in files:
        if fname.endswith("bdist_wininst.py"): continue
        log.info(fname)
        src = file(fname).read()
        try:
            compiler_root = compiler.parse(src)
        except SyntaxError:
            continue
        fastparse_root = fastparser(src)
        str1 = fastparsetreeToString(fastparse_root)
        str2 = compilerParseTreeToString(compiler_root)
        assert str1 == str2, "\n"+"-"*70+"\n"+str1+"-"*70+"\n"+str2


def timeParseOfPythonLibrary(path):
    import time
    t1 = time.time()
    files = getFilesForName(path)
    import sys
    for fname in files:
        if fname.endswith("bdist_wininst.py"): continue
        src = file(fname).read()
        fastparser(src)
    print "\n", time.time()-t1


if __name__ == "__main__":
    from bike import logging
    logging.init()
    log = logging.getLogger("bike")
    log.setLevel(logging.INFO)
    # add soak tests to end of test
    class Z_SoakTestFastparser(BRMTestCase):

        def test_A_timeParseOfPythonLibrary(self):
            timeParseOfPythonLibrary("/usr/local/lib/python2.2")

        def test_parsesPythonLibraryCorrectly(self):
            print ""
            compareCompilerWithFastparserOverPath("/usr/local/lib/python2.2")

    unittest.main()

