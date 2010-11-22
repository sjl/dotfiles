#!/usr/bin/env python
import setpath
import unittest
import os

from bike import testdata
from bike.query.findDefinition import findAllPossibleDefinitionsByCoords
from bike.query.getTypeOf import getTypeOf,resolveImportedModuleOrPackage
from bike.parsing.newstuff import getModuleOrPackageUsingFQN
from bike.parsing.fastparserast import getRoot
from bike.testutils import *
        
class TestFindDefinitionByCoords(BRMTestCase):

    def test_findsClassRef(self):
        src=trimLines("""
        class TheClass:
            pass
        a = TheClass()
        """)
        createSourceNodeAt(src,"mymodule")
        defn = [x for x in findAllPossibleDefinitionsByCoords(os.path.abspath("mymodule.py"),3,6)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 1
        assert defn[0].colno == 6
        assert defn[0].confidence == 100

    def tests_findsMethodRef(self):
        src=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        a = TheClass()
        a.theMethod()
        """)

        createSourceNodeAt(src,"mymodule")
        defn = [x for x in findAllPossibleDefinitionsByCoords(os.path.abspath("mymodule.py"),5,3)]

        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 2
        assert defn[0].colno == 8
        assert defn[0].confidence == 100
        

    def test_returnsOtherMethodsWithSameName(self):
        src=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        a = SomeOtherClass()
        a.theMethod()
        """)

        createSourceNodeAt(src,"mymodule")
        defn = [x for x in findAllPossibleDefinitionsByCoords(os.path.abspath("mymodule.py"),5,3)]

        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 2
        assert defn[0].colno == 8
        assert defn[0].confidence == 50




    def test_findsTemporaryDefinition(self):
        src=trimLines("""
        a = 3
        b = a + 1
        """)
        createSourceNodeAt(src,"mymodule")
        defn = [x for x in findAllPossibleDefinitionsByCoords(os.path.abspath("mymodule.py"),2,4)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 1
        assert defn[0].colno == 0
        assert defn[0].confidence == 100

    def test_findsArgumentDefinition(self):
        src=trimLines("""
        def someFunction(a):
            b = a + 1
        """)
        createSourceNodeAt(src,"mymodule")
        defn = [x for x in findAllPossibleDefinitionsByCoords(os.path.abspath("mymodule.py"),2,8)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 1
        assert defn[0].colno == 17
        assert defn[0].confidence == 100

    def test_findsClassInstanceDefinition(self):
        src=trimLines("""
        class TheClass():
            pass
        a = TheClass()
        print a
        """)
        createSourceNodeAt(src,"mymodule")
        defn = [x for x in findAllPossibleDefinitionsByCoords(os.path.abspath("mymodule.py"),4,6)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 3
        assert defn[0].colno == 0
        assert defn[0].confidence == 100

    def test_findsDefinitionInParentScope(self):
        src=trimLines("""
        a = 3
        def foo(self):
            b = a + 1
        """)
        createSourceNodeAt(src,"mymodule")
        defn = [x for x in findAllPossibleDefinitionsByCoords(os.path.abspath("mymodule.py"),3,8)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 1
        assert defn[0].colno == 0
        assert defn[0].confidence == 100

    def test_findsDefinitionWithinFunction(self):
        src=trimLines("""
        def foo(yadda):
            a = someFunction()
            print a
        """)
        createSourceNodeAt(src,"mymodule")
        defn = [x for x in findAllPossibleDefinitionsByCoords(os.path.abspath("mymodule.py"),3,10)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 2
        assert defn[0].colno == 4
        assert defn[0].confidence == 100
        

    def test_findsDefinitionFromSubsequentAssignment(self):
        src=trimLines("""
        def foo(yadda):
            a = 3
            print a
            a = 5
        """)
        createSourceNodeAt(src,"mymodule")
        defn = [x for x in findAllPossibleDefinitionsByCoords(os.path.abspath("mymodule.py"),4,4)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 2
        assert defn[0].colno == 4
        assert defn[0].confidence == 100

    def test_findsDefinitionFromDefinition(self):
        src=trimLines("""
        def foo(yadda):
            a = 3
            print a
            a = 5
        """)
        createSourceNodeAt(src,"mymodule")
        defn = [x for x in findAllPossibleDefinitionsByCoords(os.path.abspath("mymodule.py"),4,4)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 2
        assert defn[0].colno == 4
        assert defn[0].confidence == 100


    def test_findsClassRefUsingFromImportStatement(self):
        src=trimLines("""
        from a.b.bah import TheClass
        """)
        classsrc=trimLines("""
        class TheClass:
            pass
        """)
        root = createSourceNodeAt(src,"a.foo")
        root = createSourceNodeAt(classsrc, "a.b.bah")
        module = getModuleOrPackageUsingFQN("a.foo")
        filename = os.path.abspath(os.path.join("a","foo.py"))        
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,1,21)]
        assert defn[0].filename == os.path.abspath(os.path.join("a","b","bah.py"))
        assert defn[0].lineno == 1
        assert defn[0].colno == 6
        assert defn[0].confidence == 100


    def test_findsVariableRefUsingFromImportStatement(self):
        importsrc=trimLines("""
        from a.b.bah import mytext
        print mytext
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        root = createSourceNodeAt(importsrc,"a.foo")
        root = createSourceNodeAt(src, "a.b.bah")
        filename = os.path.abspath(os.path.join("a","foo.py"))        
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,2,6)]
        assert defn[0].filename == os.path.abspath(os.path.join("a","b","bah.py"))
        assert defn[0].lineno == 1
        assert defn[0].colno == 0
        assert defn[0].confidence == 100


    def test_findsVariableRefUsingImportStatement(self):
        importsrc=trimLines("""
        import a.b.bah
        print a.b.bah.mytext
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        root = createSourceNodeAt(importsrc,"a.foo")
        root = createSourceNodeAt(src, "a.b.bah")
        filename = os.path.abspath(os.path.join("a","foo.py"))        
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,2,14)]
        assert defn[0].filename == os.path.abspath(os.path.join("a","b","bah.py"))
        assert defn[0].lineno == 1
        assert defn[0].colno == 0
        assert defn[0].confidence == 100


    def test_findsVariableRefUsingFromImportStarStatement(self):
        importsrc=trimLines("""
        from a.b.bah import *
        print mytext
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        createSourceNodeAt(importsrc,"a.foo")
        createSourceNodeAt(src, "a.b.bah")
        filename = os.path.abspath(os.path.join("a","foo.py"))
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,2,6)]
        assert defn[0].filename == os.path.abspath(os.path.join("a","b","bah.py"))
        assert defn[0].lineno == 1
        assert defn[0].colno == 0
        assert defn[0].confidence == 100

    def test_findsVariableRefUsingFromPackageImportModuleStatement(self):
        importsrc=trimLines("""
        from a.b import bah
        print bah.mytext
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        root = createSourceNodeAt(importsrc,"a.b.foo")
        root = createSourceNodeAt(src, "a.b.bah")
        filename = os.path.abspath(os.path.join("a","b","foo.py"))        
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,2,10)]
        assert defn[0].filename == os.path.abspath(os.path.join("a","b","bah.py"))
        assert defn[0].lineno == 1
        assert defn[0].colno == 0
        assert defn[0].confidence == 100

    def test_findsImportedVariableRefInAFunctionArg(self):
        importsrc=trimLines("""
        from a.b import bah
        someFunction(bah.mytext)
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        root = createSourceNodeAt(importsrc,"a.b.foo")
        root = createSourceNodeAt(src, "a.b.bah")
        filename = os.path.abspath(os.path.join("a","b","foo.py"))        
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,2,17)]
        assert defn[0].filename == os.path.abspath(os.path.join("a","b","bah.py"))
        assert defn[0].lineno == 1
        assert defn[0].colno == 0
        assert defn[0].confidence == 100


    def test_findsVariableRefUsingFromImportStatementInFunction(self):
        importsrc=trimLines("""
        def foo:
            from a.b.bah import mytext
            print mytext
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        root = createSourceNodeAt(importsrc,"a.foo")
        root = createSourceNodeAt(src, "a.b.bah")
        filename = os.path.abspath(os.path.join("a","foo.py"))        
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,3,10)]
        assert defn[0].filename == os.path.abspath(os.path.join("a","b","bah.py"))
        assert defn[0].lineno == 1
        assert defn[0].colno == 0
        assert defn[0].confidence == 100

    def test_findsVariableRefByImportingModule(self):
        importsrc=trimLines("""
        import a.b.bah
        print a.b.bah.mytext
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        defn = self.helper(importsrc, src, 2, 14)
        assert defn[0].filename == pkgstructureFile2
        assert defn[0].lineno == 1
        assert defn[0].colno == 0
        assert defn[0].confidence == 100


    def test_findsVariableRefByImportingModuleWithFrom(self):
        importsrc=trimLines("""
        from a.b import bah
        someFunction(bah.mytext)
        """)
        src=trimLines("""
        mytext = 'hello'
        """)

        defn = self.helper(importsrc, src, 2, 17)
        assert defn[0].filename == pkgstructureFile2
        assert defn[0].lineno == 1
        assert defn[0].colno == 0
        assert defn[0].confidence == 100


    def helper(self, src, classsrc, line, col):
        try:
            createPackageStructure(src,classsrc)
            filename = pkgstructureFile1
            #Root(None,None,[pkgstructureRootDir])
            defn = [x for x in findAllPossibleDefinitionsByCoords(filename,line,col)]
        finally:
            removePackageStructure()
        return defn

    def test_doesntfindVariableRefOfUnimportedModule(self):
        importsrc=trimLines("""
        # a.b.bah not imported
        print a.b.bah.mytext
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        root = createSourceNodeAt(importsrc,"a.b.foo")
        root = createSourceNodeAt(src, "a.b.bah")
        filename = os.path.abspath(os.path.join("a","b","foo.py"))        
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,2,14)]
        self.assertEqual(defn,[])



    def test_findsSelfAttributeDefinition(self):
        src=trimLines("""
        class MyClass:
           def __init__(self):
               self.a = 'hello'
           def myMethod(self):
               print self.a
        """)
        root = createSourceNodeAt(src,"mymodule")
        filename = os.path.abspath("mymodule.py")
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,5,18)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 3
        assert defn[0].colno == 12
        assert defn[0].confidence == 100

    def test_findsSelfAttributeDefinitionFromSamePlace(self):
        src=trimLines("""
        class MyClass:
           def __init__(self):
               self.a = 'hello'
           def myMethod(self):
               print self.a
        """)
        root = createSourceNodeAt(src,"mymodule")
        filename = os.path.abspath("mymodule.py")
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,3,12)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 3
        assert defn[0].colno == 12
        assert defn[0].confidence == 100


    def test_findsSelfAttributeDefinition(self):
        src=trimLines("""
        class MyClass:
            def someOtherFn(self):
                pass
            def load(self, source):
                # fastparser ast
                self.fastparseroot = fastparser(source,self.modulename)
        """)
        root = createSourceNodeAt(src,"mymodule")
        filename = os.path.abspath("mymodule.py")
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,6,14)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 6
        assert defn[0].colno == 13
        assert defn[0].confidence == 100


    def test_findsDefnOfInnerClass(self):
        src = trimLines("""
        class TheClass:
            class TheClass:
                pass
        a = TheClass.TheClass()
        """)
        root = createSourceNodeAt(src,"mymodule")
        filename = os.path.abspath("mymodule.py")
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,4,14)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 2
        assert defn[0].colno == 10
        assert defn[0].confidence == 100

    def test_findsDefnOfOuterClass(self):
        src = trimLines("""
        class TheClass:
            class TheClass:
                pass
        a = TheClass.TheClass()
        """)
        root = createSourceNodeAt(src,"mymodule")
        filename = os.path.abspath("mymodule.py")
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,4,4)]
        assert defn[0].filename == os.path.abspath("mymodule.py")
        assert defn[0].lineno == 1
        assert defn[0].colno == 6
        assert defn[0].confidence == 100


    def test_findsClassDeclaredIn__init__Module(self):
        importsrc=trimLines("""
        class TheClass:
            pass
        """)
        src=trimLines("""
        from a import TheClass
        c = TheClass()
        """)



        root = createSourceNodeAt(importsrc,"a.__init__")
        root = createSourceNodeAt(src, "mymodule")
        filename = os.path.abspath("mymodule.py")
        defn = [x for x in findAllPossibleDefinitionsByCoords(filename,2,6)]
        assert defn[0].filename == os.path.abspath(os.path.join("a",
                                                                "__init__.py"))
        assert defn[0].lineno == 1
        assert defn[0].colno == 6
        assert defn[0].confidence == 100


class TestFindDefinitionUsingFiles(BRMTestCase):
    def test_findsASimpleDefinitionUsingFiles(self):
        src=trimLines("""
        class TheClass:
            pass
        a = TheClass()
        """)
        writeTmpTestFile(src)
        defn = [x for x in findAllPossibleDefinitionsByCoords(tmpfile,3,6)]
        assert defn[0].filename == tmpfile
        assert defn[0].lineno == 1
        assert defn[0].colno == 6
        assert defn[0].confidence == 100


    def test_findsDefinitionInAnotherModuleUsingFiles(self):
        src=trimLines("""
        from a.b.bah import TheClass
        """)
        classsrc=trimLines("""
        class TheClass:
            pass
        """)
        defn = self.helper(src, classsrc, 1, 21)
        assert defn[0].filename == pkgstructureFile2
        assert defn[0].lineno == 1
        assert defn[0].colno == 6
        assert defn[0].confidence == 100



    def test_findsDefinitionInAnotherRelativeModuleUsingFiles(self):
        src=trimLines("""
        from b.bah import TheClass
        """)
        classsrc=trimLines("""
        class TheClass:
            pass
        """)
        defn = self.helper(src, classsrc,1,21)
        assert defn[0].filename == pkgstructureFile2
        assert defn[0].lineno == 1
        assert defn[0].colno == 6
        assert defn[0].confidence == 100

    def test_findsMethodDefinitionInAnotherModuleUsingFiles(self):
        src=trimLines("""
        from b.bah import TheClass
        a = TheClass()
        a.theMethod()
        """)
        classsrc=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        """)
        defn = self.helper(src, classsrc, 3, 2)
        assert defn[0].filename == pkgstructureFile2
        assert defn[0].lineno == 2
        assert defn[0].colno == 8
        assert defn[0].confidence == 100

    def test_findsDefinitonOfMethodWhenUseIsOnAMultiLine(self):
        classsrc=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        """)
        src=trimLines("""
        from b.bah import TheClass
        a = TheClass()
        i,j = (32,
               a.theMethod())  # <--- find me!
        something=somethingelse
        """)
        defn = self.helper(src, classsrc, 4, 9)
        assert defn[0].filename == pkgstructureFile2
        assert defn[0].lineno == 2
        assert defn[0].colno == 8
        assert defn[0].confidence == 100


    def test_findsDefinitionWhenUseIsOnAMultilineAndNextLineBalancesBrace(self):
        classsrc=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        """)
        src=trimLines("""
        from b.bah import TheClass
        c = TheClass()
        f1, f2 = (c.func1, 
                c.theMethod)
        f1, f2 = (c.func1, 
                c.theMethod)
        """)
        defn = self.helper(src, classsrc, 4, 10)
        self.assertEqual(pkgstructureFile2,defn[0].filename)
        self.assertEqual(2,defn[0].lineno)
        self.assertEqual(8,defn[0].colno)
        self.assertEqual(100,defn[0].confidence)

    def test_worksIfFindingDefnOfRefInSlashMultiline(self):
        classsrc=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        """)
        src=trimLines("""
        from b.bah import TheClass
        c = TheClass()
        f1, f2 = c.func1 \\
               ,c.theMethod
        """)
        defn = self.helper(src, classsrc, 4, 10)
        self.assertEqual(pkgstructureFile2,defn[0].filename)
        self.assertEqual(2,defn[0].lineno)
        self.assertEqual(8,defn[0].colno)
        self.assertEqual(100,defn[0].confidence)

    def test_findsDefnInSameNonPackageDirectory(self):
        try:
            getRoot().pythonpath = []   # clear the python path
            classsrc = trimLines("""
            def testFunction():
                print 'hello'
            """)
            src = trimLines("""
            from baz import testFunction
            """)
            writeTmpTestFile(src)
            newtmpfile = os.path.join(tmproot,"baz.py")
            writeFile(newtmpfile, classsrc)
            refs = [x for x in findAllPossibleDefinitionsByCoords(tmpfile,1,16)]
            assert refs[0].filename == newtmpfile
            assert refs[0].lineno == 1
        finally:
            os.remove(newtmpfile)
            deleteTmpTestFile()


    def test_findsDefnInPackageSubDirectoryAndRootNotInPath(self):
        src=trimLines("""
        from b.bah import TheClass
        """)
        classsrc=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        """)
        getRoot().pythonpath = []   # clear the python path
        defn = self.helper(src, classsrc, 1, 18)
        assert defn[0].filename == pkgstructureFile2
        assert defn[0].lineno == 1
        assert defn[0].colno == 6
        assert defn[0].confidence == 100

    def test_findsDefnInSamePackageHierarchyAndRootNotInPath(self):
        src=trimLines("""
        from a.b.bah import TheClass
        """)
        classsrc=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        """)
        getRoot().pythonpath = []   # clear the python path
        defn = self.helper(src, classsrc, 1, 20)
        assert defn[0].filename == pkgstructureFile2
        assert defn[0].lineno == 1
        assert defn[0].colno == 6
        assert defn[0].confidence == 100

    def helper(self, src, classsrc, line, col):
        try:
            createPackageStructure(src,classsrc)
            filename = pkgstructureFile1
            #Root(None,None,[pkgstructureRootDir])
            defn = [x for x in findAllPossibleDefinitionsByCoords(filename,line,col)]
        finally:
            removePackageStructure()
        return defn


if __name__ == "__main__":
    unittest.main()
