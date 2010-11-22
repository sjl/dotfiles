#!/usr/bin/env python
import setpath
from bike.testutils import *
from bike.transformer.save import save

from moveToModule import *

class TestMoveClass(BRMTestCase):
    def test_movesTheText(self):
        src1=trimLines("""
        def before(): pass
        class TheClass:
            pass
        def after(): pass
        """)
        src1after=trimLines("""
        def before(): pass
        def after(): pass
        """)
        src2after=trimLines("""
        class TheClass:
            pass
        """)
        
        try:
            createPackageStructure(src1, "")
            moveClassToNewModule(pkgstructureFile1,2,
                                 pkgstructureFile2)
            save()
            self.assertEqual(src1after,file(pkgstructureFile1).read())
            self.assertEqual(src2after,file(pkgstructureFile2).read())
        finally:
            removePackageStructure()

class TestMoveFunction(BRMTestCase):
    def test_importsNameReference(self):
        src1=trimLines("""
        a = 'hello'
        def theFunction(self):
            print a
        """)
        src2after=trimLines("""
        from a.foo import a
        def theFunction(self):
            print a
        """)
        self.helper(src1, src2after)
        


    def test_importsExternalReference(self):
        src0=("""
        a = 'hello'
        """)
        src1=trimLines("""
        from top import a
        def theFunction(self):
            print a
        """)
        src2after=trimLines("""
        from top import a
        def theFunction(self):
            print a
        """)
        try:
            createPackageStructure(src1, "", src0)
            moveFunctionToNewModule(pkgstructureFile1,2,
                                    pkgstructureFile2)
            save()
            self.assertEqual(src2after,file(pkgstructureFile2).read())
        finally:
            removePackageStructure()

    def test_doesntImportRefCreatedInFunction(self):
        src1=trimLines("""
        def theFunction(self):
            a = 'hello'
            print a
        """)
        src2after=trimLines("""
        def theFunction(self):
            a = 'hello'
            print a
        """)
        
        self.helper(src1, src2after)


    def test_doesntImportRefCreatedInFunction(self):
        src1=trimLines("""
        def theFunction(self):
            a = 'hello'
            print a
        """)
        src2after=trimLines("""
        def theFunction(self):
            a = 'hello'
            print a
        """)
        
        self.helper(src1, src2after)


    def test_addsImportStatementToOriginalFileIfRequired(self):
        src1=trimLines("""
        def theFunction(self):
            pass
        b = theFunction()
        """)
        
        src1after=trimLines("""
        from a.b.bah import theFunction
        b = theFunction()
        """)
        try:
            createPackageStructure(src1,"")
            moveFunctionToNewModule(pkgstructureFile1,1,
                                    pkgstructureFile2)
            save()
            self.assertEqual(src1after,file(pkgstructureFile1).read())
        finally:
            removePackageStructure()

    def test_updatesFromImportStatementsInOtherModules(self):
        src0=trimLines("""
        from a.foo import theFunction
        print theFunction()
        """)
        src1=trimLines("""
        def theFunction(self):
            pass
        """)
        
        src0after=trimLines("""
        from a.b.bah import theFunction
        print theFunction()
        """)
        try:
            createPackageStructure(src1,"",src0)
            moveFunctionToNewModule(pkgstructureFile1,1,
                                    pkgstructureFile2)
            save()
            self.assertEqual(src0after,file(pkgstructureFile0).read())
        finally:
            removePackageStructure()

    def test_updatesFromImportMultiplesInOtherModules(self):
        src0=trimLines("""
        from a.foo import something,theFunction,somethingelse #comment
        print theFunction()
        """)
        src1=trimLines("""
        def theFunction(self):
            pass
        something = ''
        somethingelse = 0
        """)
        
        src0after=trimLines("""
        from a.foo import something,somethingelse #comment
        from a.b.bah import theFunction
        print theFunction()
        """)
        try:
            createPackageStructure(src1,"",src0)
            moveFunctionToNewModule(pkgstructureFile1,1,
                                    pkgstructureFile2)
            save()
            self.assertEqual(src0after,file(pkgstructureFile0).read())
        finally:
            removePackageStructure()
        
    def test_updatesFromImportMultiplesInTargetModule(self):
        src0=trimLines("""
        from a.foo import something,theFunction,somethingelse #comment
        print theFunction()
        """)
        src1=trimLines("""
        def theFunction(self):
            pass
        something = ''
        somethingelse = 0
        """)
        
        src0after=trimLines("""
        from a.foo import something,somethingelse #comment
        print theFunction()
        def theFunction(self):
            pass
        """)
        try:
            createPackageStructure(src1,"",src0)
            moveFunctionToNewModule(pkgstructureFile1,1,
                                    pkgstructureFile0)
            save()
            #print file(pkgstructureFile0).read()
            self.assertEqual(src0after,file(pkgstructureFile0).read())
        finally:
            removePackageStructure()


    def test_updatesFromImportInTargetModule(self):
        src0=trimLines("""
        from a.foo import theFunction
        print theFunction()
        """)
        src1=trimLines("""
        def theFunction(self):
            pass
        """)
        
        src0after=trimLines("""
        print theFunction()
        def theFunction(self):
            pass
        """)
        try:
            createPackageStructure(src1,"",src0)
            moveFunctionToNewModule(pkgstructureFile1,1,
                                    pkgstructureFile0)
            save()
            self.assertEqual(src0after,file(pkgstructureFile0).read())
        finally:
            removePackageStructure()



    def helper(self, src1, src2after):
        try:
            createPackageStructure(src1, "")
            moveFunctionToNewModule(pkgstructureFile1,2,
                                    pkgstructureFile2)
            save()
            self.assertEqual(src2after,file(pkgstructureFile2).read())
        finally:
            removePackageStructure()
        

        
if __name__ == "__main__":
    unittest.main()
