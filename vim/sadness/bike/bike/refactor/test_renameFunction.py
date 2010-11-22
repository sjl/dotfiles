#!/usr/bin/env python
import setpath
import unittest
from rename import rename
from bike import testdata
from bike.testutils import *
from bike.transformer.save import save
import compiler

class RenameFunctionTests:
    def runTarget(self, src, klassfqn, newname):
        # see concrete subclasses for implementation
        pass

    def testRenamesFunctionDcl(self):
        srcBefore=trimLines("""
        def theFunction():
            pass
        """)
        srcAfter=trimLines("""
        def newName():
            pass
        """)
        src = self.rename(srcBefore,1,4,"newName")
        self.assertEqual(srcAfter,src)

    def testDoesntBarfWhenFunctionIncludesBrackettedExpression(self):
        srcBefore=trimLines("""
        def theFunction():
            return ('\\n').strip()
        """)
        srcAfter=trimLines("""
        def newName():
            return ('\\n').strip()
        """)
        src = self.rename(srcBefore,1,4, "newName")
        self.assertEqual(srcAfter,src)




class RenameFunctionTests_importsFunction:

    def testRenamesImportedFunctionReference(self):
        srcBefore=trimLines("""
        import b.bah
        b.bah.theFunction()
        """)
        srcAfter=trimLines("""
        import b.bah
        b.bah.newName()
        """)
        src = self.renameFunction(srcBefore,"newName")
        self.assertEqual(srcAfter,src)

    def testRenamesFunctionReferenceImportedWithFromClause(self):
        srcBefore=trimLines("""
        from b.bah import theFunction
        theFunction()
        """)
        srcAfter=trimLines("""
        from b.bah import newName
        newName()
        """)
        src = self.renameFunction(srcBefore,"newName")
        self.assertEqual(srcAfter,src)

    def testRenamesFunctionRefInImportClause(self):
        srcBefore=trimLines("""
        import b.bah
        b.bah.theFunction()
        """)
        srcAfter=trimLines("""
        import b.bah
        b.bah.newName()
        """)
        src = self.renameFunction(srcBefore,"newName")
        self.assertEqual(srcAfter,src)


    def testRenamesFunctionRefInImportFromClause(self):
        srcBefore=trimLines("""
        from b.bah import theFunction
        theFunction()
        """)
        srcAfter=trimLines("""
        from b.bah import newName
        newName()
        """)
        src = self.renameFunction(srcBefore,"newName")
        self.assertEqual(srcAfter,src)



class TestRenameFunction(BRMTestCase, RenameFunctionTests):
    def rename(self, src, line, col, newname):
        writeTmpTestFile(src)
        rename(tmpfile,line,col, newname)
        save()
        return file(tmpfile).read()


class TestRenameFunctionReferenceWithDirectoryStructure(BRMTestCase, RenameFunctionTests_importsFunction):

    def renameFunction(self, src, newname):
        createPackageStructure(src,FunctionTestdata)
        rename(pkgstructureFile2,1,4, newname)
        save()
        return file(pkgstructureFile1).read()

FunctionTestdata = trimLines("""
def theFunction():
    pass
""")


if __name__ == "__main__":
    unittest.main()
