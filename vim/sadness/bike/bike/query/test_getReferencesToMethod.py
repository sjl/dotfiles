#!/usr/bin/env python
import setpath
import unittest
import os
from bike import testdata
from bike.testutils import *
from bike.query.findReferences import findReferences
from bike.parsing.fastparserast import Module

class TestGetReferencesToMethod(BRMTestCase):

    def test_getsReferenceOfSimpleMethodCall(self):
        src = trimLines("""
        from b.bah import TheClass
        a = TheClass()
        a.theMethod()
        """)
        root = createSourceNodeAt(src,"a.foo")
        root = createSourceNodeAt(MethodTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,2,8)
                if x.confidence == 100]
        self.assertEqual(refs[0].filename,
                         os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,3)
        self.assertEqual(refs[0].colno,2)
        self.assertEqual(refs[0].colno,2)

    def test_getsReferenceOfMethodCallFromClassImportedWithAlias(self):
        src = trimLines("""
        from b.bah import TheClass as MyTheClass
        
        def foo():
            a = MyTheClass()
            a.theMethod()
        """)
        root = createSourceNodeAt(src,"a.foo")
        root = createSourceNodeAt(MethodTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,2,8)
                if x.confidence == 100]
        self.assertEqual(refs[0].filename,
                         os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,5)
        self.assertEqual(refs[0].colno,6)


    def test_getsReferenceOfMethodCallWhenInstanceReturnedByFunction(self):
        src = trimLines("""
        from b.bah import TheClass
        
        def foo():
            return TheClass()
        a = foo()
        a.theMethod()
        """)
        root = createSourceNodeAt(src,"a.foo")
        root = createSourceNodeAt(MethodTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,2,8)
                if x.confidence == 100]
        self.assertEqual(refs[0].filename,
                         os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,6)
        self.assertEqual(refs[0].colno,2)
        
    def test_getsReferenceOfMethodCallInSameClass(self):
        src = trimLines("""
        class TheClass:
            def theMethod(self):
                pass
            def anotherMethod(self):
                self.theMethod()
        """)

        root = createSourceNodeAt(src,"a.foo")
        filename = os.path.abspath("a/foo.py")
        refs = [x for x in findReferences(filename,2,8)
                if x.confidence == 100]
        self.assertEqual(refs[0].filename,
                         os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,5)
        self.assertEqual(refs[0].colno,13)

    def test_getsReferenceOfMethodOnBaseClassInstance(self):
        src = trimLines("""
        class root:
            def theMethod():
                pass
                
        class a(root):
            def theMethod():
                pass
                
        class b(root):
            pass
            
        class TheClass(b):
            def theMethod(self):
                pass
                
        rootinstance = root()
        rootinstance.theMethod()
        """)

        refs =self.helper4(src,"pass",2,8)
        self.assertEqual(refs[2].filename,pkgstructureFile1)
        self.assertEqual(refs[2].lineno,17)
        self.assertEqual(refs[2].colno,13)

    def helper4(self, src, importedsrc, line, col):
        try:
            createPackageStructure(src,importedsrc)
            filename = pkgstructureFile1
            refs =  [x for x in findReferences(filename,line,col)
                     if x.confidence == 100]
        finally:
            removePackageStructure()
        return refs
        
    def test_doesntGetReferenceToMethodWhenObjectCreatedInChildScopeToMethodReference(self):
        src = trimLines("""
        from b.bah import TheClass
        a = AnotherClass()
        def foo():
            a = TheClass()
        a.theMethod()
        """)
        root = createSourceNodeAt(src,"a.foo")
        root = createSourceNodeAt(MethodTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,2,8)
                if x.confidence == 100]
        assert len(refs) == 0
        
    def test_renamesMethodReferenceOfInstanceCreatedInSubsequentFunction(self):
        src = trimLines("""
        class TheClass:
            def theMethod():
                pass
        class NotTheClass:
            def theMethod():
                pass
            
        def foo():
            a = bah()
            a.theMethod()
            
        def bah():
            return TheClass()
        """)
        root = createSourceNodeAt(src,"a.foo")
        filename = os.path.abspath("a/foo.py")
        refs = [x for x in findReferences(filename,2,8)
                if x.confidence == 100]
        self.assertEqual(refs[0].filename,
                         os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,10)
        self.assertEqual(refs[0].colno,6)


    def test_getsReferenceInMiddleOfBiggerCompoundCall(self):
        src = trimLines("""
        class TheClass:
            def theMethod(self): return AnotherClass()
        TheClass().theMethod().anotherMethod()
        """)

        root = createSourceNodeAt(src,"a.foo")
        filename = os.path.abspath("a/foo.py")
        refs = [x for x in findReferences(filename,2,8)
                if x.confidence == 100]
        self.assertEqual(refs[0].filename,
                         os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,3)
        self.assertEqual(refs[0].colno,11)
        self.assertEqual(refs[0].colend,20)


MethodTestdata = trimLines("""
class TheClass:
    def theMethod(self):
        pass
    def differentMethod(self):
        pass

class DifferentClass:
    def theMethod(self):
        pass
""")


if __name__ == "__main__":
    unittest.main()
