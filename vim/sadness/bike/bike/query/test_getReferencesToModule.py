#!/usr/bin/env python
import setpath
import unittest
import os
from bike import testdata
from bike.testutils import *
from bike.query.getReferencesToModule import *
from bike.parsing.fastparserast import Module

class TestGetReferencesToModule(BRMTestCase):
    
    def test_returnsEmptyListIfNoReferences(self):
        src = trimLines("""
        class MyClass:
            pass
        a = TheClass()
        """)
        root = createSourceNodeAt(src,"mymodule")
        self.assertEqual([x for x in getReferencesToModule(root,"myothermodule")],[])

    def test_findsReferencesInModuleWhichImportsModule(self):
        src = trimLines("""
        import b.bah
        def foo():
            a = b.bah.TheClass()
            a.theMethod()
        """)

        root = createSourceNodeAt( src, "a.foo")
        root = createSourceNodeAt( testdata.TheClass, "a.b.bah")
        refs = [x for x in getReferencesToModule(root,"a.b.bah")]

        
        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,1)
        self.assertEqual(refs[0].colno,9)
        self.assertEqual(refs[0].confidence,100)

        self.assertEqual(refs[1].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[1].lineno,3)
        self.assertEqual(refs[1].colno,10)
        self.assertEqual(refs[0].confidence,100)
        
    def test_findsReferenceInModuleWhichImportsModuleWithFrom(self):
        src = trimLines("""
        from b import bah
        def foo():
            a = bah.TheClass()
            a.theMethod()
        """)

        root = createSourceNodeAt( src, "a.foo")
        root = createSourceNodeAt( testdata.TheClass, "a.b.bah")
        refs = [x for x in getReferencesToModule(root,"a.b.bah")]

        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,1)
        self.assertEqual(refs[0].colno,14)
        self.assertEqual(refs[0].confidence,100)

        self.assertEqual(refs[1].filename,os.path.abspath(os.path.join("a/foo.py")))
        self.assertEqual(refs[1].lineno,3)
        self.assertEqual(refs[1].colno,8)
        self.assertEqual(refs[0].confidence,100)

    def test_findsReferenceInModuleWhichImportsModuleWithFromAndAlias(self):
        src = trimLines("""
        from b import bah as mymodule
        def foo():
            a = mymodule.MyTheClass()
            a.theMethod()
        """)


        root = createSourceNodeAt( src, "a.foo")
        root = createSourceNodeAt( testdata.TheClass, "a.b.bah")
        refs = [x for x in getReferencesToModule(root,"a.b.bah")]

        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,1)
        self.assertEqual(refs[0].colno,14)
        self.assertEqual(refs[0].confidence,100)

        """ # mymodule.MyTheClass
        self.assertEqual(refs[1].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[1].lineno,3)
        self.assertEqual(refs[1].colno,10)
        self.assertEqual(refs[1].confidence,100)
        """

    def test_findsReferenceInModuleWhichImportsModuleWithFromImportStar(self):
        src = trimLines("""
        from b.bah import *
        a = TheClass()
        a.theMethod()
        """)

        root = createSourceNodeAt( src, "a.foo")
        root = createSourceNodeAt( testdata.TheClass, "a.b.bah")
        refs = [x for x in getReferencesToModule(root,"a.b.bah")]

        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,1)
        self.assertEqual(refs[0].colno,7)
        self.assertEqual(refs[0].confidence,100)

    ''' Dont think this is a valid test, since cant import a module with
        from package import *
    def test_findsReferenceInModuleWhichImportsClassWithFromImportStar2(self):
        src = trimLines("""
        from a.b import * 
        a = bah.TheClass()
        """)

        root = createSourceNodeAt( src, "a.foo")
        root = createSourceNodeAt( testdata.TheClass, "a.b.bah")
        refs = [x for x in getReferencesToModule(root,"a.b.bah")]

        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,2)
        self.assertEqual(refs[0].colno,4)
        self.assertEqual(refs[0].confidence,100)
    '''
    
    def test_findsReferenceInClassBases(self):
        src =trimLines("""
        from b import bah
        class DerivedClass(bah.TheClass):
            pass
        """)

        root = createSourceNodeAt(src, "a.foo")
        root = createSourceNodeAt(testdata.TheClass, "a.b.bah")
        refs = [x for x in getReferencesToModule(root,"a.b.bah")]
        
        self.assertEqual(refs[1].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[1].lineno,2)
        self.assertEqual(refs[1].colno,19)
        self.assertEqual(refs[1].confidence,100)
            
    def test_findsReferenceInMultiLineImportStatement(self):
        src =trimLines("""
        from b import foo, \\
                  TheFooBah, TheClass, TheBastard, SomethingElse, bah
        """)

        root = createSourceNodeAt( src, "a.foo")
        root = createSourceNodeAt( testdata.TheClass, "a.b.bah")
        refs = [x for x in getReferencesToModule(root,"a.b.bah")]
        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,2)
        self.assertEqual(refs[0].colno,58)
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

        root = createSourceNodeAt( src, "a.foo")
        root = createSourceNodeAt( testdata.TheClass, "a.b.bah")
        refs = [x for x in getReferencesToModule(root,"a.b.bah")]
        
        self.assertEqual(refs[0].filename,os.path.abspath(os.path.join("a","foo.py")))
        self.assertEqual(refs[0].lineno,1)
        self.assertEqual(refs[0].colno,16)
        self.assertEqual(refs[0].confidence,100)
        
        assert (len(refs))==2


        
if __name__ == "__main__":
    unittest.main()
