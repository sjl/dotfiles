#!/usr/bin/env python
import setpath
import unittest
from rename import rename
import compiler
from bike import testdata

from bike.testutils import*

from bike.transformer.save import save

class RenameMethodTests:
    
    def test_renamesTheMethod(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName(self):
                pass
        """)
        src = self.rename(srcBefore,2,8,"newName")
        self.assertEqual(srcAfter,src)

    def test_doesntRenameMethodOfSameNameOnOtherClasses(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        class b:
            def theMethod(self):
                pass
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName(self):
                pass
        class b:
            def theMethod(self):
                pass
        """)
        src = self.rename(srcBefore,2,8,"newName")
        self.assertEqual(srcAfter,src)

    def test_doesntRenameOtherMethodsOfSameClass(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod(self):
                a=b
            def aMethod(self):
                pass
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName(self):
                a=b
            def aMethod(self):
                pass
        """)
        src = self.rename(srcBefore,2,8,"newName")
        self.assertEqual(srcAfter,src)

    def test_renamesMethodWhenClassNestedInFunction(self):
        srcBefore=trimLines("""
        def theFunction():
            class TheClass:
                def theMethod(self):
                    pass
        """)
        srcAfter=trimLines("""
        def theFunction():
            class TheClass:
                def newName(self):
                    pass
        """)
        src = self.rename(srcBefore,3,12,"newName")
        self.assertEqual(srcAfter,src)

    def test_doesntBarfOnInheritanceHierarchies(self):
        srcBefore=trimLines("""
        from b.bah import DifferentClass
        class TheClass(foo.bah):
            def theMethod(self):
                pass
        """)
        src = self.rename(srcBefore,2,8,"newName")

    def test_renamesMethodWhenMethodCallFromOtherMethodInSameClass(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
            def anotherMethod(self):
                self.theMethod()
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName(self):
                pass
            def anotherMethod(self):
                self.newName()
        """)
        src = self.rename(srcBefore,2,8,"newName")
        self.assertEqual(srcAfter,src)

    def test_doesntBarfOnNestedClasses(self):
        srcBefore=trimLines("""
        class TheClass:
            class AnotherClass:
                pass
            def theMethod(self):
                pass
        """)
        src = self.rename(srcBefore,4,8,"newName")

    def test_renamesMethodWhenBaseClassesArentInAST(self):
        srcBefore=trimLines("""
        class TheClass(notInAst):
            def theMethod(self):
                pass
        """)
        srcAfter=trimLines("""
        class TheClass(notInAst):
            def newName(self):
                pass
        """)
        src = self.rename(srcBefore,2,8,"newName")
        self.assertEqual(srcAfter,src)

    def test_renamesMethodInRelatedClasses(self):
        srcBefore=trimLines("""
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
        """)
        srcAfter=trimLines("""
        class root:
            def newName(self):
                pass

        class a(root):
            def newName(self):
                pass

        class b(root):
            pass

        class TheClass(b):
            def newName(self):
                pass
        """)
        src = self.rename(srcBefore,13,8,"newName")
        self.assertEqual(srcAfter,src)


    def test_renameMethodDoesntBarfOnNoneAsDefaultArgToMethod(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod(self, root, flist, stack=None):
                pass
        """)
        src = self.rename(srcBefore,2,8,"newName")



class RenameMethodTests_ImportsClass:
    def test_renamesMethodOnDerivedClassInstance(self):
        srcBefore = trimLines("""
        from b.bah import TheClass as BaseClass
        
        class DerivedClass(BaseClass):
            pass

        class DerivedDerivedClass(DerivedClass):
            def theMethod(self):
                print 'hello'
        """)
        srcAfter = trimLines("""
        from b.bah import TheClass as BaseClass
        
        class DerivedClass(BaseClass):
            pass

        class DerivedDerivedClass(DerivedClass):
            def newName(self):
                print 'hello'
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcAfter,src)
        
class RenameMethodReferenceTests:
    # Generic tests. These tests are designed to be run in the context of a ui
    #  and in a package hierarchy structure

    def test_doesntBarfWhenConfrontedWithComplexReturnTypes(self):
        src = trimLines("""
        import a
        class TheClass:
            def theMethod(self):
                 pass
                 
        def bah():
            return a[35]
            
        b = bah()
        b.theMethod()
        """)
        self.rename(src,3,8,"newName")

    def test_doesntbarfWhenCallMadeOnInstanceReturnedFromFnCall(self):
        srcBefore=trimLines("""
        from foo import e
        class TheClass:
            def theMethod(self):
                pass
        ast = e().f(src)
        """)
        self.rename(srcBefore,3,8,"newName")

    def test_doesntStackOverflowOnRecursiveFunctions(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod(self):
                pass

        def foo(a):
            return foo(a)
        """)
        self.rename(srcBefore,2,8,"newName")

    def test_renamesMethodReferenceOfInstanceCreatedInParentScopeAfterFunction(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        a = TheClass()
        def foo():
            a.theMethod()
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName(self):
                pass
        a = TheClass()
        def foo():
            a.newName()
        """)
        src = self.rename(srcBefore,2,8,"newName")
        self.assertEqual(srcAfter,src)
 
    def test_renamesMethodReferenceOfInstanceObtainedByCallingFunction(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod():
                pass
        def foo():
            b = TheClass()
            return b
        a = foo()
        a.theMethod()
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName():
                pass
        def foo():
            b = TheClass()
            return b
        a = foo()
        a.newName()
        """)
        src = self.rename(srcBefore,2,8,"newName")
        self.assertEqual(srcAfter,src)

    def test_renamesMethodReferenceOfInstanceCreatedInAnotherFunction(self):

        srcBefore=trimLines("""
        class TheClass:
            def theMethod():
                pass
        def bah():
            return TheClass()
        def foo():
            a = bah()
            a.theMethod()
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName():
                pass
        def bah():
            return TheClass()
        def foo():
            a = bah()
            a.newName()
        """)
        src = self.rename(srcBefore,2,8,"newName")
        self.assertEqual(srcAfter,src)

    def test_renamesMethodReferenceOfInstanceCreatedInSubsequentFunction(self):
        srcBefore = trimLines("""
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
        srcAfter=trimLines("""
        class TheClass:
            def newName():
                pass
        class NotTheClass:
            def theMethod():
                pass
            
        def foo():
            a = bah()
            a.newName()
            
        def bah():
            return TheClass()
        """)
        src = self.rename(srcBefore,2,8,"newName")
        self.assertEqual(srcAfter,src)

    def test_renamesMethodReferenceOnInstanceThatIsAnAttributeOfSelf(self):
        srcBefore = trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        
        class AnotherClass:
            def __init__(self):
                self.a = TheClass()
            def anotherFn(self):
                self.a.theMethod()
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName(self):
                pass
        
        class AnotherClass:
            def __init__(self):
                self.a = TheClass()
            def anotherFn(self):
                self.a.newName()
        """)
        src = self.rename(srcBefore,2,8,"newName")
        self.assertEqual(srcAfter,src)

    def test_doesntBarfOnGetattrThatItCantDeduceTypeOf(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        a = TheClass
        
        a.b.bah = 3
        """)
        self.rename(srcBefore,2,8,"newName")


class RenameMethodReferenceTests_ImportsClass:

    def test_renamesReferenceOfClassImportedAsAnotherName(self):
        srcBefore=trimLines("""
        from b.bah import TheClass as MyTheClass        
        def foo():
            a = MyTheClass()
            a.theMethod()
        """)
        srcAfter=trimLines("""
        from b.bah import TheClass as MyTheClass        
        def foo():
            a = MyTheClass()
            a.newName()
        """)
        src = self.renameMethod(srcBefore,2,8, "newName")
        self.assertEqual(srcAfter,src)

    def test_renamesReferenceWhenObjectCreationAndReferenceInModuleScope(self):
        srcBefore=trimLines("""
        from b.bah import TheClass
        a = TheClass()
        a.theMethod()
        """)
        srcAfter=trimLines("""
        from b.bah import TheClass
        a = TheClass()
        a.newName()
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcAfter,src)


    def test_renamesReferenceWhenObjectCreatedInSameFunctionAsReference(self):
        srcBefore=trimLines("""
        import b.bah
        def foo():
            a = b.bah.TheClass()
            a.theMethod()
        """)
        srcAfter=trimLines("""
        import b.bah
        def foo():
            a = b.bah.TheClass()
            a.newName()
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcAfter,src)

    def test_doesntrenameDifferentMethodReferenceWhenObjectCreatedInSameScope(self):
        srcBefore=trimLines("""
        import b.bah.TheClass
        def foo():
            a = b.bah.TheClass()
            a.theMethod()
        """)
        src = self.renameMethod(srcBefore, 4,8, "newName")
        self.assertEqual(srcBefore,src)

    def test_doesntrenameMethodReferenceWhenDifferentObjectCreatedInSameScope(self):
        srcBefore=trimLines("""
        import b.bah.TheClass
        def foo():
            a = b.bah.TheClass()
            a.theMethod()
        """)
        src = self.renameMethod(srcBefore, 8,8,"newName")
        self.assertEqual(srcBefore,src)

    def test_renamesReferenceOfImportedClass(self):
        srcBefore=trimLines("""
        import b.bah
        
        def foo():
            a = b.bah.TheClass()
            a.theMethod()
        """)
        srcAfter=trimLines("""
        import b.bah
        
        def foo():
            a = b.bah.TheClass()
            a.newName()
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcAfter,src)

    def test_doesntRenameReferenceOfDifferentImportedClass(self):
        srcBefore=trimLines("""
        from b.bah import DifferentClass
        
        def foo():
            a = b.bah.TheClass()
            a.theMethod()
        """)
        src = self.renameMethod(srcBefore, 8,8,
                                           "newName")
        self.assertEqual(srcBefore,src)

    def test_renamesReferenceOfClassImportedWithFromClause(self):
        srcBefore=trimLines("""
        from b.bah import TheClass
        
        def foo():
            a = TheClass()
            a.theMethod()
        """)
        srcAfter=trimLines("""
        from b.bah import TheClass
        
        def foo():
            a = TheClass()
            a.newName()
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcAfter,src)

    def test_doesntrenameReferenceOfClassImportedWithDifferentAsClause(self):
        srcBefore = trimLines("""
        from b.bah import TheClass as MyClass
        
        def foo():
            a = TheClass()
            a.theMethod()
        """)

        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcBefore,src)

    def test_renamesReferenceOfClassImportedWithFromFooImportStar(self):
        srcBefore=trimLines("""
        from b.bah import *
        a = TheClass()
        a.theMethod()
        """)
        srcAfter=trimLines("""
        from b.bah import *
        a = TheClass()
        a.newName()
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcAfter,src)

    def test_renamesMethodReferenceOfInstanceCreatedInParentScope(self):
        srcBefore=trimLines("""
        from b.bah import TheClass
        a = TheClass()
        def foo():
            a.theMethod()
        """)
        srcAfter=trimLines("""
        from b.bah import TheClass
        a = TheClass()
        def foo():
            a.newName()
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcAfter,src)

    def test_doesntRenameMethodWhenObjectCreatedInChildScopeToMethodReference(self):
        srcBefore = trimLines("""
        from b.bah import TheClass
        a = AnotherClass()
        def foo():
            a = TheClass()
        a.theMethod()
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcBefore,src)

    def test_renamesReferenceOnDerivedClassInstance(self):
        srcBefore=trimLines("""
        import b
        class DerivedClass(b.bah.TheClass):
            pass
        class DerivedDerivedClass(DerivedClass):
            pass
        theInstance = DerivedDerivedClass()
        theInstance.theMethod()
        """)
        srcAfter=trimLines("""
        import b
        class DerivedClass(b.bah.TheClass):
            pass
        class DerivedDerivedClass(DerivedClass):
            pass
        theInstance = DerivedDerivedClass()
        theInstance.newName()
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcAfter,src)



# tests that cover stuff not renamed automatically
# (I.e. are renamed after user manually expresses desire to do so)
class RenameMethodAfterPromptTests:
    def test_renamesReferenceWhenMethodCallDoneOnInstanceCreation(self):

        srcBefore=trimLines("""
        class TheClass:
            def theMethod(self): pass
        TheClass().theMethod()
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName(self): pass
        TheClass().newName()
        """)
        src = self.renameMethod(srcBefore,2,8, "newName")
        self.assertEqual(srcAfter,src)


    def test_renamesReferenceInMiddleOfBiggerCompoundCall(self):
        srcBefore = trimLines("""
        class TheClass:
            def theMethod(self): return AnotherClass()
        TheClass().theMethod().anotherMethod()
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName(self): return AnotherClass()
        TheClass().newName().anotherMethod()
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcAfter,src)


class TestRenameMethodWithSingleModule(BRMTestCase, RenameMethodTests, RenameMethodReferenceTests):
    # template method 
    def rename(self, src, line, col, newname):
        try:
            createPackageStructure(src, "pass")
            rename(pkgstructureFile1,line,col,newname)
            save()
            return file(pkgstructureFile1).read()
        finally:
            removePackageStructure()


class TestRenameMethodWithDirectoryStructure(RenameMethodTests, RenameMethodReferenceTests, BRMTestCase):

    def rename(self, src, line, col, newname):
        try:
            createPackageStructure("pass",src)
            rename(pkgstructureFile2,line,col,newname)
            save()
            return file(pkgstructureFile2).read()
        finally:
            removePackageStructure()


class TestRenameMethodReferenceWithDirectoryStructure(BRMTestCase, RenameMethodTests_ImportsClass, RenameMethodReferenceTests_ImportsClass):

    def renameMethod(self, src, line, col, newname):
        try:
            createPackageStructure(src,MethodTestdata)
            rename(pkgstructureFile2,line,col,newname)
            save()
            return file(pkgstructureFile1).read()
        finally:
            removePackageStructure()

class TestRenameMethodStuffCorrectlyAfterPromptReturnsTrue(BRMTestCase, 
                                                      RenameMethodAfterPromptTests):

    def callback(self, filename, line, colbegin, colend):
        return 1


    def renameMethod(self, src, line, col, newname):
        createPackageStructure(src, MethodTestdata)
        rename(pkgstructureFile1,line,col,newname,self.callback)
        save()
        return file(pkgstructureFile1).read()



class TestDoesntRenameMethodIfPromptReturnsFalse(BRMTestCase):
    def callback(self, filename, line, colbegin, colend):
        return 0

    def renameMethod(self, src, line, col, newname):
        createPackageStructure(src, MethodTestdata)
        rename(pkgstructureFile1,line,col,newname,self.callback)
        save()
        return file(pkgstructureFile1).read()

    def test_doesntRenameMethodIfPromptReturnsFalse(self):
        srcBefore = trimLines("""
        class TheClass:
            def theMethod(self):
                pass
        b = TheClass()
        b.theMethod()
        a = someFunction()
        a.theMethod()
        """)
        srcAfter=trimLines("""
        class TheClass:
            def newName(self):
                pass
        b = TheClass()
        b.newName()
        a = someFunction()
        a.theMethod()
        """)
        src = self.renameMethod(srcBefore, 2,8, "newName")
        self.assertEqual(srcAfter,src)


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
