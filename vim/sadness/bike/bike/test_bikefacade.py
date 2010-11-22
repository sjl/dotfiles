#!/usr/bin/env python
import unittest
import setpath
import sys

from bike import testdata
from bike.testutils import *
import bike
from bike.refactor.test_renameFunction import RenameFunctionTests, RenameFunctionTests_importsFunction, FunctionTestdata
from bike.refactor.test_renameClass import RenameClassTests, RenameClassTests_importsClass, TheClassTestdata
from bike.refactor.test_renameMethod import RenameMethodTests, RenameMethodTests_ImportsClass, RenameMethodReferenceTests, RenameMethodReferenceTests_ImportsClass, RenameMethodAfterPromptTests, TestDoesntRenameMethodIfPromptReturnsFalse,MethodTestdata
from bike.refactor import test_extractMethod
import bikefacade
from bike import UndoStackEmptyException
from bike.query.getTypeOf import getTypeOf

class TestPathFunctions(BRMTestCase):
    def test_setCompletePythonPath_removesDuplicates(self):
        origpath = sys.path
        try:
            sys.path = ["foobah"]
            ctx = bike.init()
            ctx._setCompletePythonPath(sys.path[-1])
            self.assertEqual(1,ctx._getCurrentSearchPath().count(sys.path[-1]))
        finally:
            sys.path = origpath


    def test_setNonLibPathonPath_removesLibDirectories(self):
        origpath = sys.path
        try:
            writeTmpTestFile("pass")
            libdir = os.path.join(sys.prefix,"lib","python"+sys.version[:3])
            sys.path = [libdir,os.path.join(libdir,"site-packages")]
            ctx = bike.init()
            ctx._setNonLibPythonPath(tmproot)
            self.assertEqual([tmproot],ctx._getCurrentSearchPath())
        finally:
            sys.path = origpath

class TestRenameMethodAfterPrompt(BRMTestCase,RenameMethodAfterPromptTests):
    def callback(self, filename, line, colstart, colend):
        return 1

    def renameMethod(self, src, line, col, newname):
        writeTmpTestFile(src)
        ctx = bike.init()
        ctx.setRenameMethodPromptCallback(self.callback)
        ctx.renameByCoordinates(tmpfile,line,col,newname)
        ctx.save()
        newsrc = readFile(tmpfile)
        return newsrc

class TestDoesntRenameMethodIfPromptReturnsFalse(TestDoesntRenameMethodIfPromptReturnsFalse):

    def callback(self, filename, line, colstart, colend):
        return 0

    def renameMethod(self, src, line, col, newname):
        writeTmpTestFile(src)
        ctx = bike.init()
        ctx.setRenameMethodPromptCallback(self.callback)
        ctx.renameByCoordinates(tmpfile,line,col,newname)
        ctx.save()
        newsrc = readFile(tmpfile)
        return newsrc


class TestRenameByCoordinates2(RenameMethodTests,RenameMethodReferenceTests, RenameClassTests,RenameFunctionTests,BRMTestCase):
    def rename(self, src, line, col, newname):
        writeTmpTestFile(src)
        ctx = bike.init()
        ctx.renameByCoordinates(os.path.abspath(tmpfile),line,col,newname)
        ctx.save()
        newsrc = readFile(tmpfile)
        return newsrc


class TestRenameByCoordinatesWithDirectoryStructure(
                                RenameClassTests_importsClass,
                                RenameFunctionTests_importsFunction,
                                RenameMethodTests_ImportsClass,
                                RenameMethodReferenceTests_ImportsClass,
                                BRMTestCase):
    def renameClass(self, src, newname):
        try:
            createPackageStructure(src, TheClassTestdata)
            ctx = bike.init()
            ctx.renameByCoordinates(pkgstructureFile2,1,6,newname)
            ctx.save()
            newsrc = readFile(pkgstructureFile1)
            return newsrc
        finally:
            removePackageStructure()


    def renameMethod(self, src, line, col, newname):
        try:
            createPackageStructure(src, MethodTestdata)
            ctx = bike.init()
            ctx.renameByCoordinates(pkgstructureFile2,line,col,newname)
            ctx.save()
            newsrc = readFile(pkgstructureFile1)
            return newsrc
        finally:
            removePackageStructure()

    def renameFunction(self, src, newname):
        try:
            createPackageStructure(src, FunctionTestdata)
            ctx = bike.init()
            ctx.renameByCoordinates(pkgstructureFile2,1,4,newname)
            ctx.save()
            newsrc = readFile(pkgstructureFile1)
            return newsrc
        finally:
            removePackageStructure()



class Test_deducePackageOfFile(BRMTestCase):
    def test_returnsEmptyStringIfFileNotInPackage(self):
        try:
            # this doesnt have __init__.py file, so
            # isnt package
            os.makedirs("a")
            writeFile(os.path.join("a","foo.py"),"pass")
            pkg = bikefacade._deducePackageOfFile(os.path.join("a","foo.py"))
            assert pkg == ""
        finally:
            os.remove(os.path.join("a","foo.py"))
            os.removedirs(os.path.join("a"))

    def test_returnsNestedPackage(self):
        try:
            os.makedirs(os.path.join("a","b"))
            writeFile(os.path.join("a","__init__.py"),"# ")
            writeFile(os.path.join("a","b","__init__.py"),"# ")
            writeFile(os.path.join("a","b","foo.py"),"pass")
            pkg = bikefacade._deducePackageOfFile(os.path.join("a","b","foo.py"))
            assert pkg == "a.b"
        finally:
            os.remove(os.path.join("a","__init__.py"))
            os.remove(os.path.join("a","b","__init__.py"))
            os.remove(os.path.join("a","b","foo.py"))
            os.removedirs(os.path.join("a","b"))
        

class TestExtractMethod(test_extractMethod.TestExtractMethod):

    def test_extractsPass(self):
        srcBefore=trimLines("""
        class MyClass:
            def myMethod(self):
                pass
        """)

        srcAfter=trimLines("""
        class MyClass:
            def myMethod(self):
                self.newMethod()

            def newMethod(self):
                pass
        """)

        writeTmpTestFile(srcBefore)
        ctx = bike.init()
        ctx.extractMethod(os.path.abspath(tmpfile),3,8,3,12,"newMethod")
        ctx.save()
        self.assertEqual(readTmpTestFile(),srcAfter)
        ctx.undo()
        ctx.save()
        self.assertEqual(readTmpTestFile(),srcBefore)
        

class TestExtractFunction(test_extractMethod.TestExtractFunction):
    def test_extractsFunction(self):        
        srcBefore=trimLines("""
        def myFunction(): # comment
            a = 3
            c = a + 99
            b = c * 1
            print b
        """)
        srcAfter=trimLines("""
        def myFunction(): # comment
            a = 3
            b = newFunction(a)
            print b

        def newFunction(a):
            c = a + 99
            b = c * 1
            return b
        """)
        writeTmpTestFile(srcBefore)
        ctx = bike.init()
        ctx.extractMethod(os.path.abspath(tmpfile),3,4,4,13,"newFunction")
        ctx.save()
        self.assertEqual(readTmpTestFile(),srcAfter)
        ctx.undo()
        ctx.save()
        self.assertEqual(readTmpTestFile(),srcBefore)


class TestUndo(BRMTestCase):

    def test_undoesTheTextOfASingleFile(self):
        src = trimLines("""
        class a:
            def foo(self):
                pass
        """)
        writeTmpTestFile(src)
        #ctx = bike.init()
        ctx = bike.init()

        ctx.renameByCoordinates(tmpfile,2,8,"c")
        ctx.save()
        ctx.undo()
        ctx.save()
        newsrc = readFile(tmpfile)
        self.assertEqual(newsrc,src)


    def test_undoesTwoConsecutiveRefactorings(self):
        try:
            src = trimLines("""
            class a:
                def foo(self):
                    pass
            """)
            writeTmpTestFile(src)
            ctx = bike.init()
            ctx.renameByCoordinates(tmpfile,2,8,"c")
            ctx.save()
            
            newsrc1 = readFile(tmpfile)

            ctx.renameByCoordinates(tmpfile,2,8,"d")
            ctx.save()

            
            # 1st undo
            ctx.undo()
            ctx.save()
            newsrc = readFile(tmpfile)
            self.assertEqual(newsrc,
                             newsrc1)

            # 2nd undo
            ctx.undo()
            ctx.save()
            newsrc = readFile(tmpfile)
            self.assertEqual(newsrc,src)
        finally:
            pass
            #deleteTmpTestFile()
        

    def test_undoesTheTextOfAFileTwice(self):
        for i in range(3):
            src = trimLines("""
            class foo:
                def bah(self):
                    pass
            """)
            writeTmpTestFile(src)
            ctx = bike.init()
            ctx.renameByCoordinates(tmpfile,2,8,"c")
            ctx.save()
            ctx.undo()
            ctx.save()
            newsrc = readFile(tmpfile)
            self.assertEqual(newsrc,src)
            raisedexception=0
            try:
                ctx.undo()
            except UndoStackEmptyException:
                pass
            else:
                assert 0,"should have raised an exception"

    '''
    def test_undoesManualModificationsToFiles(self):
        writeTmpTestFile("class foo: pass")
        origsrc = readFile(tmpfile)
        ctx = bike.init()

        writeTmpTestFile("pass")
        import os
        ctx.init()
        newsrc = readFile(tmpfile)
        assert newsrc != origsrc
        ctx.undo()
        ctx.save()
        newsrc = readFile(tmpfile)
        assert newsrc == origsrc
    '''

class TestGetReferencesToClass_Facade(BRMTestCase):
    def test_returnsReferences(self):        
        src = trimLines("""
        class TheClass:
            pass
        a = TheClass()
        """)
        writeTmpTestFile(src)
        ctx = bike.init()
        refs = [refs for refs in ctx.findReferencesByCoordinates(tmpfile,1,6)]
        self.assertEqual(refs[0].filename,os.path.abspath(tmpfile))
        self.assertEqual(refs[0].lineno,3)
        assert hasattr(refs[0],"confidence")


class TestFindDefinitionByCoordinates(BRMTestCase):
    def test_findsClassRef(self):
        src=trimLines("""
        class TheClass:
            pass
        a = TheClass()
        """)
        writeTmpTestFile(src)
        ctx = bike.init()
        defn = [x for x in ctx.findDefinitionByCoordinates(tmpfile,3,6)]
        assert defn[0].filename == os.path.abspath(tmpfile)
        assert defn[0].lineno == 1
        assert defn[0].confidence == 100

class TestBRM_InlineLocalVariable(BRMTestCase):
    def test_works(self):
        srcBefore=trimLines("""
        def foo():
            b = 'hello'
            print b
        """)
        srcAfter=trimLines("""
        def foo():
            print 'hello'
        """)

        writeTmpTestFile(srcBefore)
        ctx = bike.init()
        ctx.inlineLocalVariable(tmpfile,3,10)
        ctx.save()
        self.assertEqual(file(tmpfile).read(),srcAfter)


class TestBRM_ExtractLocalVariable(BRMTestCase):
    def test_works(self):
        srcBefore=trimLines("""
        def foo():
            print 3 + 2
        """)
        srcAfter=trimLines("""
        def foo():
            a = 3 + 2
            print a
        """)
        try:
            writeTmpTestFile(srcBefore)
            ctx = bike.init()
            ctx.extractLocalVariable(tmpfile,2,10,2,15,'a')
            ctx.save()
            self.assertEqual(file(tmpfile).read(),srcAfter)
        finally:
            pass
            #deleteTmpTestFile()






if __name__ == "__main__":
    unittest.main()
