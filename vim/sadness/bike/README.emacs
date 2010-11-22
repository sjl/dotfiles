Instructions for running Bicycle Repair Man through emacs/xemacs
----------------------------------------------------------------

N.B. You need xemacs / emacs 21 or above.

The emacs integration utilises the excellent 'Pymacs' package, written
by François Pinard, which integrates python with emacs. A copy of this
software is included with this package.


There are 3 steps to installing bicyclerepairman for emacs:

1) Install the base bicyclerepairman package

2) Install the Pymacs package (if you haven't already got it)

3) Modify your .emacs to active the bicyclerepairman functionality

See the sections below for instructions on doing each of these.

WINDOWS USERS: 
You need to have both the python executable and the scripts directory
(e.g. c:\Python22/Scripts) in your path for Bicyclerepairman to work.

There are a couple of niggles with brm/emacs on
windows. See the comments at the end of this file.







1) Installation of Base Bicyclerepairman:
-----------------------------------------

- install bicyclerepair man as per INSTALL


2) Installation of Pymacs:
--------------------------

(You can skip this if you already have pymacs installed.

- Go to the ide-integration/Pymacs-0.20 directory
- Run 
      python setup.py install
- Run 
      python setup-emacs.py -l <LISP DIR>    
  OR  
      python setup-emacs.py -E xemacs -l <LISP DIR>
  Depending on your version of emacs.

- Add the following into your .emacs or .xemacs/init.el:

;; pymacs
(autoload 'pymacs-load "pymacs" nil t)
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")

- Check that it has installed correctly:
  (Taken from the pymacs README)


    To check that `pymacs.el' is properly installed, start Emacs and give
    it the command `M-x load-library RET pymacs': you should not receive
    any error.  

    To check that `pymacs.py' is properly installed, start
    an interactive Python session (e.g. from a command shell) and type
    `from Pymacs import lisp': you should not receive any error.  

	To check that `pymacs-services' is properly installed, type
	`pymacs-services' in a shell; you should then get a line ending
	with "(pymacs-version VERSION)". Press ctrl-c to exit.


If you have any problems, consult the README file included with the
pymacs distribution. N.B. I renamed the setup script to setup-emacs.py
to make it more intuitive and easier for windows users. I've also
added a pymacs-services.bat file to allow it to run on windows.


3) Activating the Bike/Emacs integration
----------------------------------------

Add the following to your .emacs or .xemacs/init.el, after the pymacs
stuff:

(pymacs-load "bikeemacs" "brm-")
(brm-init)


You need to be using python-mode for the bicyclerepairman menu to
appear. If you haven't already, enable this with:

(autoload 'python-mode "python-mode" "Python editing mode." t)
(setq auto-mode-alist
      (cons '("\\.py$" . python-mode) auto-mode-alist))



Usage:
------

Load a python file into emacs. A BicycleRepairMan menu should appear.


Windows GNU-Emacs users
-----------------------

The load dialog in windows GNU-Emacs doesn't seem to allow selection
of directories. If this is the case for you, use 'M-x brm-load' to
import a package hierarchy.
