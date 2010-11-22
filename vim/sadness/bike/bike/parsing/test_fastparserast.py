#!/usr/bin/env python
import unittest
from fastparserast import *
from fastparser import fastparser
from bike.query.getTypeOf import getTypeOf
from bike.testutils import *

class TestGetModule(BRMTestCase):

    def test_getRootWorksAfterDefinedByCreateSourceNodeAt(self):
        src=trimLines("""
        class TheClass:
            pass
        a = TheClass()
        """)
        root = createSourceNodeAt(src,"mymodule")
        assert root == getRoot()

    def test_returnsNoneIfModuleDoesntExist(self):
        assert getModule(tmpfile) == None


class TestGetEndLine(BRMTestCase):
    def test_returnsEndLineWithSimpleFunction(self):
        src = trimLines("""
        class TheClass:
            def theMethod():
                pass
        def foo():
            b = TheClass()
            return b
        a = foo()
        a.theMethod()
        """)
        root = fastparser(src)
        fn = getTypeOf(root,"foo")
        self.assertEqual(fn.getEndLine(),7)

    def test_worksWithFunctionsThatHaveEmptyLinesInThem(self):
        src = fnWithEmptyLineInIt
        root = fastparser(src)
        fn = getTypeOf(root,"TheClass.theFunction")
        self.assertEqual(fn.getEndLine(),8)

class TestGetBaseClassNames(BRMTestCase):
    def test_worksForClassHierarchy(self):
        src = trimLines("""
        class root:
            def theMethod():
                pass

        class a(root):
            def theMethod():
                pass    

        class b(root):
            pass

        class TheClass(a,b):
            def theMethod():
                pass

        rootinstance = root()
        rootinstance.theMethod()
        """)
        #classes = getASTNodeFromSrc(src,"Source").fastparseroot.getChildNodes()
        classes = createAST(src).fastparseroot.getChildNodes()
        self.assertEqual(classes[3].getBaseClassNames(),['a','b'])

    def test_returnsEmptyListForClassWithNoBases(self):
        src = trimLines("""
        class root:
            pass
        """)
        #classes = getASTNodeFromSrc(src,"Source").fastparseroot.getChildNodes()
        classes = createAST(src).fastparseroot.getChildNodes()        
        self.assertEqual(classes[0].getBaseClassNames(),[])


class TestGetMaskedLines(BRMTestCase):
    def test_doit(self):
        src =trimLines("""
        class foo: #bah
            pass
        """)
        mod = createAST(src).fastparseroot
        lines = mod.getMaskedModuleLines()
        assert lines[0] == "class foo: #***\n"


class TestGetLinesNotIncludingThoseBelongingToChildScopes(BRMTestCase):
    def test_worksForModule(self):
        src =trimLines("""
        class TheClass:
            def theMethod():
                pass
        def foo():
            b = TheClass()
            return b
        a = foo()
        a.theMethod()
        """)
        mod = createAST(src).fastparseroot
        self.assertEqual(''.join(mod.getLinesNotIncludingThoseBelongingToChildScopes()),
                         trimLines("""
                         a = foo()
                         a.theMethod()
                         """))

    def test_worksForModuleWithSingleLineFunctions(self):
        src=trimLines("""
        a = blah()
        def foo(): pass
        b = 1
        """)
        mod = createAST(src).fastparseroot
        lines = mod.getLinesNotIncludingThoseBelongingToChildScopes()
        self.assertEqual(''.join(lines),
                         trimLines("""
                         a = blah()
                         b = 1
                         """))


    def test_worksForSingleLineFunction(self):
        src=trimLines("""
        a = blah()
        def foo(): pass
        b = 1
        """)
        fn = createAST(src).fastparseroot.getChildNodes()[0]
        lines = fn.getLinesNotIncludingThoseBelongingToChildScopes()
        self.assertEqual(''.join(lines),
                         trimLines("""
                         def foo(): pass
                         """))


fnWithEmptyLineInIt = """
class TheClass:
    def theFunction():
        a = foo()

        print 'a'

    # end of function
"""

if __name__ == "__main__":
    unittest.main()
    
