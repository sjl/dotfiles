#!/usr/bin/env python
import setpath
import unittest
import compiler
import os

from bike import testdata
from bike.testutils import *
from bike.mock import Mock

from pathutils import getPathOfModuleOrPackage
from pathutils import *
import pathutils as loadmodule

class TestGetFilesForName(BRMTestCase):
    def testGetFilesForName_recursivelyReturnsFilesInBreadthFirstOrder(self):
        createPackageStructure("pass", "pass")

        files = getFilesForName(pkgstructureBasedir)
        for f in files:
            assert f in \
                  [os.path.join(pkgstructureBasedir, '__init__.py'), 
                    os.path.join(pkgstructureBasedir, 'foo.py'), 
                    os.path.join(pkgstructureChilddir, '__init__.py'), 
                    os.path.join(pkgstructureChilddir, 'bah.py')]

    def testGetFilesForName_globsStars(self):
        createPackageStructure("pass", "pass")
        assert getFilesForName(os.path.join(pkgstructureBasedir, "fo*")) == [os.path.join(pkgstructureBasedir, 'foo.py')]
        removePackageStructure()

    def testGetFilesForName_doesntListFilesWithDotAtFront(self):
        writeFile(os.path.join(".foobah.py"),"")
        files = getFilesForName("a")
        self.assertEqual([],files)
        



class TestGetRootDirectory(BRMTestCase):
    def test_returnsParentDirectoryIfFileNotInPackage(self):
        try:
            # this doesnt have __init__.py file, so
            # isnt package
            os.makedirs("a")
            writeFile(os.path.join("a", "foo.py"), "pass")
            dir = loadmodule.getRootDirectory(os.path.join("a", "foo.py"))
            assert dir == "a"
        finally:
            os.remove(os.path.join("a", "foo.py"))
            os.removedirs(os.path.join("a"))

    def test_returnsFirstNonPackageParentDirectoryIfFileInPackage(self):
        try:
            os.makedirs(os.path.join("root", "a", "b"))
            writeFile(os.path.join("root", "a", "__init__.py"), "# ")
            writeFile(os.path.join("root", "a", "b", "__init__.py"), "# ")
            writeFile(os.path.join("root", "a", "b", "foo.py"), "pass")
            dir = loadmodule.getRootDirectory(os.path.join("root", "a", "b", "foo.py"))
            assert dir == "root"
        finally:
            os.remove(os.path.join("root", "a", "__init__.py"))
            os.remove(os.path.join("root", "a", "b", "__init__.py"))
            os.remove(os.path.join("root", "a", "b", "foo.py"))
            os.removedirs(os.path.join("root", "a", "b"))

    def test_returnsFirstNonPackageParentDirectoryIfPathIsAPackage(self):
        try:
            os.makedirs(os.path.join("root", "a", "b"))
            writeFile(os.path.join("root", "a", "__init__.py"), "# ")
            writeFile(os.path.join("root", "a", "b", "__init__.py"), "# ")
            writeFile(os.path.join("root", "a", "b", "foo.py"), "pass")
            dir = loadmodule.getRootDirectory(os.path.join("root", "a", "b"))
            assert dir == "root"
        finally:
            os.remove(os.path.join("root", "a", "__init__.py"))
            os.remove(os.path.join("root", "a", "b", "__init__.py"))
            os.remove(os.path.join("root", "a", "b", "foo.py"))
            os.removedirs(os.path.join("root", "a", "b"))

    def test_returnsDirIfDirIsTheRootDirectory(self):
        try:
            os.makedirs(os.path.join("root", "a", "b"))
            writeFile(os.path.join("root", "a", "__init__.py"), "# ")
            writeFile(os.path.join("root", "a", "b", "__init__.py"), "# ")
            writeFile(os.path.join("root", "a", "b", "foo.py"), "pass")
            dir = loadmodule.getRootDirectory("root")
            assert dir == "root"
        finally:
            os.remove(os.path.join("root", "a", "__init__.py"))
            os.remove(os.path.join("root", "a", "b", "__init__.py"))
            os.remove(os.path.join("root", "a", "b", "foo.py"))
            os.removedirs(os.path.join("root", "a", "b"))


class getPackageBaseDirectory(BRMTestCase):
    def test_returnsBasePackageIfFileInPackageHierarchy(self):
        try:
            createPackageStructure("","")
            dir = loadmodule.getPackageBaseDirectory(pkgstructureFile2)
            self.assertEqual(pkgstructureBasedir, dir)
        finally:
            removePackageStructure()

    def test_returnsFileDirectoryIfFileNotInPackage(self):
        try:
            createPackageStructure("","")
            dir = loadmodule.getPackageBaseDirectory(pkgstructureFile0)
            self.assertEqual(pkgstructureRootDir, dir)
        finally:
            removePackageStructure()


class TestGetPathOfModuleOrPackage(BRMTestCase):
    def test_worksForFullPath(self):
        try:
            createPackageStructure("pass","pass")
            import sys
            self.assertEqual(getPathOfModuleOrPackage("a.b.bah",
                                                      [pkgstructureRootDir]),
                             pkgstructureFile2)
        finally:
            removePackageStructure()



if __name__ == "__main__":
    unittest.main()
