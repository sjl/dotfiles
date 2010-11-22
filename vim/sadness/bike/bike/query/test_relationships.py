#!/usr/bin/env python
import setpath
import unittest
import os
from bike import testdata
from bike.testutils import *
from bike.query.getTypeOf import getTypeOf
from bike.parsing.fastparserast import Module
from bike.query.relationships import getRootClassesOfHierarchy
from bike.parsing.newstuff import getModule


class TestGetRootClassesOfHierarchy(BRMTestCase):
    def test_getsRootClassFromDerivedClass(self):
        src = trimLines("""
        from b.bah import TheClass as BaseClass
        
        class DerivedClass(BaseClass):
            pass

        """)
        rootclasses = self.helper(src,"DerivedClass")
        self.assertEqual("TheClass",rootclasses[0].name)
        self.assertEqual(len(rootclasses),1)        
        
    def test_getsRootClassFromDerivedDerivedClass(self):
        src = trimLines("""
        from b.bah import TheClass as BaseClass
        
        class DerivedClass(BaseClass):
            pass
        class DerivedDerivedClass(DerivedClass):
            pass
        """)
        rootclasses = self.helper(src,"DerivedDerivedClass")
        self.assertEqual("TheClass",rootclasses[0].name)
        self.assertEqual(len(rootclasses),1)


    def test_getsRootClassFromDiamondOfClasses(self):
        src = trimLines("""
        from b.bah import TheClass as BaseClass
        
        class DerivedClass(BaseClass):
            pass
        class DerivedDerivedClass(DerivedClass,BaseClass):
            pass
        """)
        rootclasses = self.helper(src,"DerivedDerivedClass")
        self.assertEqual("TheClass",rootclasses[0].name)
        self.assertEqual("TheClass",rootclasses[1].name)
        self.assertEqual(len(rootclasses),2)


    def test_getsRootClassesFromMultipleInheritance(self):
        src = trimLines("""
        from b.bah import TheClass as BaseClass
        
        class DerivedClass:
            pass
        class DerivedDerivedClass(DerivedClass,BaseClass):
            pass
        """)
        rootclasses = self.helper(src,"DerivedDerivedClass")
        self.assertEqual("DerivedClass",rootclasses[0].name)
        self.assertEqual("TheClass",rootclasses[1].name)
        self.assertEqual(len(rootclasses),2)

    def test_getsRootClassesFromMultipleInheritanceWithNewStyleClass(self):
        src = trimLines("""
        from b.bah import TheClass as BaseClass
        
        class DerivedClass(Object):
            pass
        class DerivedDerivedClass(DerivedClass,BaseClass):
            pass
        """)
        rootclasses = self.helper(src,"DerivedDerivedClass")
        self.assertEqual("DerivedClass",rootclasses[0].name)
        self.assertEqual("TheClass",rootclasses[1].name)
        self.assertEqual(len(rootclasses),2)


    def helper(self,src,classname):
        try:
            createPackageStructure(src,testdata.TheClass)
            classobj = getTypeOf(getModule(pkgstructureFile1),classname)
            return getRootClassesOfHierarchy(classobj)
        finally:
            removePackageStructure()


if __name__ == "__main__":
    unittest.main()
