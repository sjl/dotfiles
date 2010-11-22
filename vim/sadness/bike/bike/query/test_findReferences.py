#!/usr/bin/env python
import setpath
import unittest
import os
from bike import testdata
from bike.testutils import *
#from bike.testutils import trimLines, createSourceNodeAt, \
#     createSourceNodeAt_old, BRMTestCase
from bike import testdata
from findReferences import findReferences, findReferencesIncludingDefn
from bike.query.getTypeOf import getTypeOf

class helpers:
    def helper(self,src,lineno,colno):
        writeTmpTestFile(src)
        refs =  [x for x in findReferences(tmpfile,lineno,colno)]
        return refs

    def helper2(self,src,lineno,colno):
        writeTmpTestFile(src)
        refs =  [x for x in findReferencesIncludingDefn(tmpfile,lineno,
                                                           colno)]
        return refs
        
    def helper3(self, src, importedsrc, line, col):
        createPackageStructure(src,importedsrc)
        filename = pkgstructureFile2
        refs =  [x for x in findReferences(filename,line,col)
                 if x.confidence == 100]
        return refs

    def helper4(self, src, importedsrc, line, col):
        createPackageStructure(src,importedsrc)
        filename = pkgstructureFile1
        refs =  [x for x in findReferences(filename,line,col)
                 if x.confidence == 100]
        return refs

    

class TestFindReferences(BRMTestCase,helpers):
    def test_findsSimpleReferencesGivenAssignment(self):
        src=trimLines("""
        def foo():
            a = 3
            print a
        """)
        refs = self.helper(src,3,10)
        assert refs[0].filename == tmpfile
        assert refs[0].lineno == 3
        assert refs[0].colno == 10
        assert refs[0].confidence == 100



    def test_findsSimpleReferencesGivenReference(self):
        src=trimLines("""
        def foo():
            a = 3
            print a
        """)

        refs = self.helper2(src,3,10)
        assert refs[0].filename == tmpfile
        assert refs[0].lineno == 2
        assert refs[0].colno == 4
        assert refs[0].confidence == 100


    def test_findsReferencesToOtherAssignments(self):
        src=trimLines("""
        def foo():
            a = 3
            a = 4
        """)
        refs = self.helper(src,2,4)
        assert refs[0].filename == tmpfile
        assert refs[0].lineno == 3
        assert refs[0].colno == 4
        assert refs[0].confidence == 100

    def test_findsFunctionArg(self):
        src=trimLines("""
        def foo(a):
            print a
        """)
        refs = self.helper2(src,2,10)
        assert refs[0].filename == tmpfile
        assert refs[0].lineno == 1
        assert refs[0].colno == 8
        assert refs[0].confidence == 100

    def test_findsFunctionArgWithDefault(self):
        src=trimLines("""
        def foo(a=None, b=None):
            print a, b
        """)
        refs = self.helper(src,1,4)
        self.assertEquals(refs, [])

    def test_findsFunctionArgWithDefault2(self):
        src=trimLines("""
        def foo(a=None, b=None):
            print a, b
        """)
        refs = self.helper2(src,2,13)
        assert refs[0].filename == tmpfile
        assert refs[0].lineno == 1
        assert refs[0].colno == 16
        assert refs[0].confidence == 100


    def test_findsReferencesGivenFunctionArg(self):
        src=trimLines("""
        def foo(a):
            print a
        """)
        refs = self.helper(src,1,8)
        assert refs[0].filename == tmpfile
        assert refs[0].lineno == 2
        assert refs[0].colno == 10
        assert refs[0].confidence == 100


    def test_findsVariableRefInImportStatementUsingFromImportStatement(self):
        importsrc=trimLines("""
        from a.b.bah import mytext
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        refs = self.helper3(importsrc,src,1,1)
        assert refs[0].filename == pkgstructureFile1        
        assert refs[0].lineno == 1
        assert refs[0].colno == 20
        assert refs[0].confidence == 100



    def test_findsVariableRefUsingFromImportStatement(self):
        importsrc=trimLines("""
        from a.b.bah import mytext
        print mytext
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        refs = self.helper3(importsrc,src,1,1)
        assert refs[0].filename == pkgstructureFile1        
        assert refs[1].lineno == 2
        assert refs[1].colno == 6
        assert refs[1].confidence == 100

    def test_findsImportedVariableRefInAFunctionArg(self):
        importsrc=trimLines("""
        from a.b import bah
        someFunction(bah.mytext)
        """)
        src=trimLines("""
        mytext = 'hello'
        """)
        refs = self.helper3(importsrc,src,1,1)
        assert refs[0].filename == pkgstructureFile1        
        assert refs[0].lineno == 2
        assert refs[0].colno == 17
        assert refs[0].confidence == 100

    def test_getsReferenceOfSimpleMethodCall(self):
        src = trimLines("""
        from b.bah import TheClass
        a = TheClass()
        a.theMethod()
        """)

        refs = self.helper4(src,testdata.TheClass,3,2)
        assert refs[0].filename == pkgstructureFile1
        self.assertEqual(refs[0].lineno,3)
        self.assertEqual(refs[0].colno,2)


    def test_findsRefToSelfAttribute(self):
        src=trimLines("""
        class MyClass:
           def __init__(self):
               self.a = 'hello'
           def myMethod(self):
               print self.a
        """)
        refs = self.helper(src,3,12)
        assert refs[0].filename == tmpfile
        assert refs[0].lineno == 5
        assert refs[0].colno == 18
        assert refs[0].confidence == 100


class FindReferencesToMethod(BRMTestCase,helpers):
    def test_findsReferenceOfSimpleMethodCall(self):
        src = trimLines("""
        from b.bah import TheClass
        a = TheClass()
        a.theMethod()
        """)
        refs = self.helper3(src,testClass,2,8)
        assert refs[0].filename == pkgstructureFile1
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
        refs = self.helper3(src,testClass,2,8)
        assert refs[0].filename == pkgstructureFile1
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
        refs = self.helper3(src,testClass,2,8)
        assert refs[0].filename == pkgstructureFile1
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
        refs = self.helper4(src,testClass,2,8)
        assert refs[0].filename == pkgstructureFile1
        self.assertEqual(refs[0].lineno,5)
        self.assertEqual(refs[0].colno,13)

    def test_getsReferenceOfMethodOnBaseClassInstance(self):
        src = trimLines("""
        class root:
            def theMethod(self):
                pass
                
        class a(root):
            def theMethod(self):
                pass
                
        class b(root):
            pass
            
        class TheClass(b):
            def theMethod(self):
                pass
                
        rootinstance = root()
        rootinstance.theMethod()
        """)
        refs = self.helper4(src,"pass",2,8)
        self.assertEqual(refs[2].filename,pkgstructureFile1)
        self.assertEqual(refs[2].lineno,17)
        self.assertEqual(refs[2].colno,13)
        
    def test_doesntGetReferenceToMethodWhenObjectCreatedInChildScopeToMethodReference(self):
        src = trimLines("""
        from b.bah import TheClass
        a = AnotherClass()
        def foo():
            a = TheClass()
        a.theMethod()
        """)
        refs = self.helper3(src,testClass,2,8)
        assert refs == []
        
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
        refs = self.helper4(src,"pass",2,8)
        self.assertEqual(refs[0].filename,pkgstructureFile1)
        self.assertEqual(refs[0].lineno,10)
        self.assertEqual(refs[0].colno,6)


    def test_getsReferenceInMiddleOfBiggerCompoundCall(self):
        src = trimLines("""
        class TheClass:
            def theMethod(self): return AnotherClass()
        TheClass().theMethod().anotherMethod()
        """)

        refs = self.helper4(src,"pass",2,8)
        self.assertEqual(refs[0].filename,pkgstructureFile1)
        self.assertEqual(refs[0].lineno,3)
        self.assertEqual(refs[0].colno,11)
        self.assertEqual(refs[0].colend,20)

    def test_doesntBarfWhenObjectIsArrayMember(self):
        src = trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        a[0] = TheClass()
        a[0].theMethod()
        """)
        refs = self.helper4(src,"pass",2,8)
        # should get to here without exception

class FindReferencesToClass(BRMTestCase, helpers):
    def test_returnsEmptyListIfNoReferences(self):
        src = trimLines("""
        class MyClass:
            pass
        a = TheClass()
        """)
        refs = self.helper4(src,"pass",1,6)
        assert refs == []


    def test_findsSimpleReferenceInSameModule(self):
        src = trimLines("""
        class TheClass:
            pass
        a = TheClass()
        """)
        refs = self.helper4(src,"pass",1,6)
        self.assertEqual(refs[0].filename,pkgstructureFile1)
        self.assertEqual(refs[0].lineno,3)
        self.assertEqual(refs[0].colno,4)
        self.assertEqual(refs[0].confidence,100)

    def test_doesntBarfOnSingleLineSourceWithInlineClass(self):
        src=trimLines("""
        from b.bah import TheClass
        a = TheClass()
        """)
        refs = self.helper3(src,"class TheClass: pass",1,6)
        assert refs != []

    def test_findsReferenceToClassImportedInSameClassScope(self):
        src=trimLines("""
        class AnotherClass:
            from b.bah import TheClass
            TheClass.baz = 0
        """)
        refs = self.helper3(src,"class TheClass: pass",1,6)
        self.assertEqual(refs[0].filename,pkgstructureFile1)
        self.assertEqual(refs[0].lineno,2)
        self.assertEqual(refs[0].colno,22)

        self.assertEqual(refs[0].filename,pkgstructureFile1)
        self.assertEqual(refs[1].lineno,3)
        self.assertEqual(refs[1].colno,4)

    def testFindsClassReferenceWhenScopeIsSameNameAsClass(self):
        src = trimLines("""
        class TheClass:
            class TheClass:
                pass
        a = TheClass.TheClass()
        """)
        refs = self.helper4(src,"pass",2,10)
        self.assertEqual(refs[0].filename,pkgstructureFile1)
        self.assertEqual(refs[0].lineno,4)
        self.assertEqual(refs[0].colno,13)
        self.assertEqual(refs[0].confidence,100)

    def testFindsClassReferenceWhenChildIsSameNameAsClass(self):
        src = trimLines("""
        class TheClass:
            class TheClass:
                pass
        a = TheClass.TheClass()
        """)
        refs = self.helper4(src,"pass",1,6)
        self.assertEqual(refs[0].filename,pkgstructureFile1)
        self.assertEqual(refs[0].lineno,4)
        self.assertEqual(refs[0].colno,4)
        self.assertEqual(refs[0].confidence,100)


class TestFindReferencesIncludingDefn(BRMTestCase,helpers):
    def test_findsMethodDecl(self):
        src=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        """)
        refs = self.helper2(src,2,8)
        self.assertEqual(refs[0].filename,tmpfile)
        self.assertEqual(refs[0].lineno,2)
        self.assertEqual(refs[0].colno,8)
        self.assertEqual(refs[0].confidence,100)



class TestFindReferencesUsingFiles(BRMTestCase):
    def test_findsSimpleReferencesUsingFiles(self):
        src=trimLines("""
        def foo():
            a = 3
            print a
        """)
        refs = self.helper("pass",src,2,4)
        assert refs[0].filename == pkgstructureFile2
        assert refs[0].lineno == 3
        assert refs[0].colno == 10
        assert refs[0].confidence == 100
        
    def test_findsReferenceInModuleWhichImportsClassWithFromAndAlias(self):
        src = trimLines("""
        from b.bah import TheClass as MyTheClass
        def foo():
            a = MyTheClass()
        """)
        refs = self.helper(src,testClass,1,6)
        self.assertEqual(refs[0].filename,pkgstructureFile1)
        self.assertEqual(refs[0].lineno,1)
        self.assertEqual(refs[0].colno,18)
        self.assertEqual(refs[0].confidence,100)


    def test_doesntBarfWhenCantLocatePackageWhenTryingToFindBaseClass(self):
        src = trimLines("""
        from doesntexist import baseclass
        class foo(baseclass):
            def myMethod(self):
                pass
        """)
        refs = self.helper("",src,3,8)

    def test_doesntBarfWhenComesAcrossAPrintNl(self):
        src = trimLines("""
        class TheClass:
            pass

        print >>foo, TheClass
        """)
        refs = self.helper("",src,1,6)


    def test_returnsOtherFilesInSameNonPackageDirectory(self):
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
            refs = [x for x in findReferences(newtmpfile,1,4)]

            assert refs[0].filename == tmpfile
            assert refs[0].lineno == 1
        finally:
            os.remove(newtmpfile)
            deleteTmpTestFile()




    def helper(self, src, classsrc, line, col):
        try:
            createPackageStructure(src,classsrc)
            filename = pkgstructureFile2
            refs = [x for x in findReferences(filename,line,col)]
        finally:
            removePackageStructure()
        return refs




testClass = trimLines("""
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
