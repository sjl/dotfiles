#!/usr/bin/env python
import setpath
import unittest
from rename import rename
from bike.transformer.save import save
from bike.testutils import *
import compiler

class RenameClassTests:

    def testRenamesClassDcl(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod():
                pass
        """)
        srcAfter=trimLines("""
        class NewName:
            def theMethod():
                pass
        """)

        src = self.rename(srcBefore, 1,6,"NewName")
        self.assertEqual(srcAfter,src)

    # i.e. a = TheClass()
    def testRenamesClassReference(self):
        srcBefore=trimLines("""
        class TheClass:
            pass
        a = TheClass()
        """)
        srcAfter=trimLines("""
        class NewName:
            pass
        a = NewName()
        """)
        src = self.rename(srcBefore, 1,6,"NewName")
        self.assertEqual(srcAfter,src)

    # i.e. a = TheClass.TheClass()
    def testRenamesClassReferenceWhenScopeIsSameNameAsClass(self):
        srcBefore = trimLines("""
        class TheClass:
            class TheClass:
                pass
        a = TheClass.TheClass()
        """)
        srcAfter=trimLines("""
        class TheClass:
            class NewName:
                pass
        a = TheClass.NewName()
        """)
        src = self.rename(srcBefore, 2,10, "NewName")
        self.assertEqual(srcAfter,src)

    # i.e. a = TheClass.TheClass()
    def testRenamesClassReferenceWhenChildIsSameNameAsClass(self):
        srcBefore = trimLines("""
        class TheClass:
            class TheClass:
                pass
        a = TheClass.TheClass()
        """)
        srcAfter=trimLines("""
        class NewName:
            class TheClass:
                pass
        a = NewName.TheClass()
        """)
        src = self.rename(srcBefore, 1,6,"NewName")
        self.assertEqual(srcAfter,src)


    # a = TheClass() + TheClass()
    def testRenamesClassReferenceWhenTwoRefsInTheSameLine(self):
        srcBefore=trimLines("""
        class TheClass:
            pass
        a = TheClass() + TheClass()
        """)
        srcAfter=trimLines("""
        class NewName:
            pass
        a = NewName() + NewName()
        """)
        src = self.rename(srcBefore,1,6, "NewName")
        self.assertEqual(srcAfter,src)

    def testRenamesClassReferenceInInstanceCreation(self):
        srcBefore=trimLines("""
        class TheClass:
            def theMethod(self): pass
        TheClass().theMethod()
        """)
        srcAfter=trimLines("""
        class NewName:
            def theMethod(self): pass
        NewName().theMethod()
        """)
        src = self.rename(srcBefore,1,6,"NewName")
        self.assertEqual(srcAfter,src)

    # i.e. if renaming TheClass, shouldnt rename a.b.c.TheClass
    def testDoesntRenameBugusClassReferenceOnEndOfGetattrNest(self):
        srcBefore=trimLines("""
        class TheClass:
            pass        
        a.b.c.TheClass    # Shouldn't be renamed
        """)
        srcAfter=trimLines("""
        class NewName:
            pass        
        a.b.c.TheClass    # Shouldn't be renamed
        """)
        src = self.rename(srcBefore,1,6,"NewName")
        self.assertEqual(srcAfter,src)

    def testRenamesClassRefUsedInExceptionRaise(self):
        srcBefore=trimLines("""
        class TheClass:
            pass
        raise TheClass, \"hello mum\"
        """)
        srcAfter=trimLines("""
        class NewName:
            pass
        raise NewName, \"hello mum\"
        """)
        src = self.rename(srcBefore, 1,6, "NewName")
        self.assertEqual(srcAfter,src)

    def testRenamesClassReferenceNameInInheritenceSpec(self):
        srcBefore=trimLines("""
        class TheClass:
            pass
        class DerivedClass(TheClass):
            pass
        """)
        srcAfter=trimLines("""
        class NewName:
            pass
        class DerivedClass(NewName):
            pass
        """)
        src = self.rename(srcBefore, 1,6, "NewName")
        self.assertEqual(srcAfter,src)



class RenameClassTests_importsClass:

    def testRenamesClassReferenceInInstanceCreationWithFQN(self):
        srcBefore=trimLines("""
        import b.bah
        def foo():
            a = b.bah.TheClass()
        """)
        srcAfter=trimLines("""
        import b.bah
        def foo():
            a = b.bah.NewName()
        """)
        src = self.renameClass(srcBefore,"NewName")
        self.assertEqual(srcAfter,src)

    def testRenamesClassReferencesInInheritenceSpecs(self):

        srcBefore=trimLines("""
        import b
        class DerivedClass(b.bah.TheClass):
            pass
        """)
        srcAfter=trimLines("""
        import b
        class DerivedClass(b.bah.NewName):
            pass
        """)
        src = self.renameClass(srcBefore,"NewName")
        self.assertEqual(srcAfter,src)

    def testRenamesFromImportReferenceWhenInBodyOfClass(self):
        srcBefore=trimLines("""
        class AnotherClass:
            from b.bah import TheClass
            TheClass.baz = 0
        """)
        srcAfter=trimLines("""
        class AnotherClass:
            from b.bah import NewName
            NewName.baz = 0
        """)
        src = self.renameClass(srcBefore,"NewName")
        self.assertEqual(srcAfter,src)


    def testRenamesReferenceToClassImportedInSameClassScope(self):
        srcBefore=trimLines("""
        class AnotherClass:
            from b.bah import TheClass
            TheClass.baz = 0
        """)
        srcAfter=trimLines("""
        class AnotherClass:
            from b.bah import NewName
            NewName.baz = 0
        """)
        src = self.renameClass(srcBefore,"NewName")
        self.assertEqual(srcAfter,src)

    def testRenamesReferenceToClassImportedWithFromImportStar(self):
        srcBefore=trimLines("""
        from a.b.bah import *
        a = TheClass()
        """)
        srcAfter=trimLines("""
        from a.b.bah import *
        a = NewName()
        """)
        src = self.renameClass(srcBefore,"NewName")
        self.assertEqual(srcAfter,src)

class TestRenameClass(BRMTestCase, RenameClassTests):

    def rename(self, src, line, col, newname):
        createPackageStructure(src,"pass")
        rename(pkgstructureFile1,line,col, newname)
        save()
        return file(pkgstructureFile1).read()


class TestRenameClassReferenceWithDirectoryStructure(BRMTestCase,
                                         RenameClassTests_importsClass):

    def renameClass(self, src, newname):
        createPackageStructure(src,TheClassTestdata)
        rename(pkgstructureFile2,1,6, newname)
        save()
        return file(pkgstructureFile1).read()


TheClassTestdata = trimLines("""
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
