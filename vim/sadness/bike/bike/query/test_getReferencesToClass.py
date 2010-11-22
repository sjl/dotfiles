#!/usr/bin/env python
import setpath
import unittest
import os
from bike import testdata
from bike.testutils import *
from bike.query.findReferences import findReferences
from bike.parsing.fastparserast import Module

class TestGetReferencesToClass(BRMTestCase):
    def test_returnsEmptyListIfNoReferences(self):
        src = trimLines("""
        class MyClass:
            pass
        a = TheClass()
        """)
        root = createSourceNodeAt(src,"mymodule")
        refs = [x for x in findReferences(os.path.abspath("mymodule.py"),1,6)]
        self.assertEqual(refs,[])

    def test_findsSimpleReferenceInSameModule(self):
        src = trimLines("""
        class TheClass:
            pass
        a = TheClass()
        """)
        root = createSourceNodeAt(src,"mymodule")
        refs = [x for x in findReferences(os.path.abspath("mymodule.py"),1,6)]
        self.assertEqual(refs[0].filename,os.path.abspath("mymodule.py"))
        self.assertEqual(refs[0].lineno,3)
        self.assertEqual(refs[0].colno,4)
        self.assertEqual(refs[0].confidence,100)

    def test_findsReferencesInModuleWhichImportsClass(self):
        src = trimLines("""
        import b.bah
        def foo():
            a = b.bah.TheClass()
            a.theMethod()
        """)
        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        refs = [x for x in findReferences(os.path.abspath("a/b/bah.py"),1,6)]

        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,3)
        self.assertEqual(refs[0].colno,14)
        self.assertEqual(refs[0].confidence,100)


    def test_findsReferenceInModuleWhichImportsClassWithFrom(self):
        src = trimLines("""
        from b.bah import TheClass
        def foo():
            a = TheClass()
            a.theMethod()
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")

        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]

        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,1)
        self.assertEqual(refs[0].colno,18)
        self.assertEqual(refs[0].confidence,100)

        self.assertEqual(refs[1].filename,os.path.abspath(os.path.join("a/foo.py")))
        self.assertEqual(refs[1].lineno,3)
        self.assertEqual(refs[1].colno,8)
        self.assertEqual(refs[1].confidence,100)

    def test_findsReferenceToClassImportedInSameClassScope(self):
        src=trimLines("""
        class AnotherClass:
            from b.bah import TheClass
            TheClass.baz = 0
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")

        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]
        assert refs != []

    def test_findsReferenceInModuleWhichImportsClassWithFromAndAlias(self):
        src = trimLines("""
        from b.bah import TheClass as MyTheClass
        def foo():
            a = MyTheClass()
            a.theMethod()
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]

        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,1)
        self.assertEqual(refs[0].colno,18)
        self.assertEqual(refs[0].confidence,100)


    def test_findsReferenceInModuleWhichImportsClassWithImportAs(self):
        src = trimLines("""
        from b.bah import TheClass as MyTheClass
        def foo():
            a = MyTheClass()
            a.theMethod()
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]
        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,1)
        self.assertEqual(refs[0].colno,18)
        self.assertEqual(refs[0].confidence,100)

    def test_findsReferenceInModuleWhichImportsClassWithFromImportStar(self):
        src = trimLines("""
        from b.bah import *
        a = TheClass()
        a.theMethod()
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]
        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,2)
        self.assertEqual(refs[0].colno,4)
        self.assertEqual(refs[0].confidence,100)

    def test_findsReferenceInModuleWhichImportsClassWithFromImportStar2(self):
        src = trimLines("""
        from a.b.bah import *
        a = TheClass()
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]
        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,2)
        self.assertEqual(refs[0].colno,4)
        self.assertEqual(refs[0].confidence,100)


    def test_findsClassReferenceInInstanceCreation(self):
        src = trimLines("""
        class TheClass:
            def theMethod(self): pass
        TheClass().theMethod()
        """)
        root = createSourceNodeAt(src, "a.foo")
        filename = os.path.abspath("a/foo.py")
        refs = [x for x in findReferences(filename,1,6)]
        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,3)
        self.assertEqual(refs[0].colno,0)
        self.assertEqual(refs[0].confidence,100)

    
    def test_findsClassReferenceInInstanceCreationWithFQN(self):
        src = trimLines("""
        import b.bah
        def foo():
            a = b.bah.TheClass()
            a.theMethod()
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]

        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,3)
        self.assertEqual(refs[0].colno,14)
        self.assertEqual(refs[0].confidence,100)

    def test_doesntfindReferenceInModuleWhichDoesntImportClass(self):
        src = trimLines("""
        a = TheClass()
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]
        assert refs == []

    def test_findsReferenceInClassBases(self):
        src =trimLines("""
        from b.bah import TheClass
        class DerivedClass(TheClass):
            pass
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]
        self.assertEqual(refs[1].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[1].lineno,2)
        self.assertEqual(refs[1].colno,19)
        self.assertEqual(refs[1].confidence,100)
        

    
    def test_findsReferenceInMultiLineImportStatement(self):
        src =trimLines("""
        from b.bah import foo, \\
                  TheFooBah, TheClass, Foobah, SomethingElse
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]
        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,2)
        self.assertEqual(refs[0].colno,21)
        self.assertEqual(refs[0].confidence,100)

    def test_findsReferenceWhenModulenameSameAsClassMethodName(self):
        # asserts that brm doesnt search class scope after not finding name
        # in method scope (since class scope is invisible unless called on 'self'
        src =trimLines("""
        from a.b import bah
        class baz:
            def bah(self):
                print bah.TheClass
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]
        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,4)
        self.assertEqual(refs[0].colno,18)
        self.assertEqual(refs[0].confidence,100)


    def test_doesntBarfOnFromImportStarWhenNameIsInFromClause(self):
        src = trimLines("""
        from a.b.bah import TheClass
        a = TheClass()
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(ClassTestdata, "a.b.bah")
        filename = os.path.abspath("a/b/bah.py")
        refs = [x for x in findReferences(filename,1,6)]


ClassTestdata = trimLines("""
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
