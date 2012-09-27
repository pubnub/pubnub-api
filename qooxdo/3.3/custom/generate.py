#!/usr/bin/env python
# -*- coding: utf-8 -*-
################################################################################
#
#  qooxdoo - the new era of web development
#
#  http://qooxdoo.org
#
#  Copyright:
#    2008 - 2012 1&1 Internet AG, Germany, http://www.1und1.de
#
#  License:
#    LGPL: http://www.gnu.org/licenses/lgpl.html
#    EPL: http://www.eclipse.org/org/documents/epl-v10.php
#    See the LICENSE file in the project's top-level directory for details.
#
#  Authors:
#    * Thomas Herchenroeder (thron7)
#
################################################################################

##
# This is a stub proxy for the real generator.py
##

import sys, os, re, subprocess, codecs, optparse

CMD_PYTHON = sys.executable
QOOXDOO_PATH = '../../../../../qooxdoo-2.0.2-sdk'
QX_PYLIB = "tool/pylib"

##
# A derived OptionParser class that ignores unknown options (The parent
# class raises in those cases, and stops further processing).
# We need this, as we are only interested in -c/--config on this level, and
# want to ignore pot. other options.
#
class MyOptionParser(optparse.OptionParser):
    ##
    # <rargs> is the raw argument list. The original _process_args mutates
    # rargs, processing options into <values> and copying interspersed args
    # into <largs>. This overridden version ignores unknown or ambiguous 
    # options.
    def _process_args(self, largs, rargs, values):
        while rargs:
            try:
                optparse.OptionParser._process_args(self, largs, rargs, values)
            except (optparse.BadOptionError, optparse.AmbiguousOptionError):
                pass


def parseArgs():
    parser = MyOptionParser()
    parser.add_option(
        "-c", "--config", dest="config", metavar="CFGFILE", 
        default="config.json", help="path to configuration file"
    )
    (options, args) = parser.parse_args(sys.argv[1:])
    return options, args

ShellOptions, ShellArgs = parseArgs()


# this is from misc.json, duplicated for decoupling
_eolComment = re.compile(r'(?<![a-zA-Z]:)//.*$', re.M) # double $ for string.Template
_mulComment = re.compile(r'/\*.*?\*/', re.S)
def stripComments(s):
    b = _eolComment.sub('',s)
    b = _mulComment.sub('',b)
    return b

def getQxPath():
    path = QOOXDOO_PATH
    # OS env takes precedence
    if os.environ.has_key("QOOXDOO_PATH"):
        path = os.environ["QOOXDOO_PATH"]

    # else use QOOXDOO_PATH from config.json
    else:
        config_file = ShellOptions.config
        if os.path.exists(config_file):
            # try json parsing with qx json
            if not path.startswith('${'): # template macro has been resolved
                sys.path.insert(0, os.path.join(path, QX_PYLIB))
                try:
                    from misc import json
                    got_json = True
                except:
                    got_json = False

            got_path = False
            if got_json:
                config_str = codecs.open(config_file, "r", "utf-8").read()
                config_str = stripComments(config_str)
                config = json.loads(config_str)
                p = config.get("let")
                if p:
                    p = p.get("QOOXDOO_PATH")
                    if p:
                        path = p
                        got_path = True

            # regex parsing - error prone
            if not got_path:
                qpathr=re.compile(r'"QOOXDOO_PATH"\s*:\s*"([^"]*)"\s*,?')
                conffile = codecs.open(config_file, "r", "utf-8")
                aconffile = conffile.readlines()
                for line in aconffile:
                    mo = qpathr.search(line)
                    if mo:
                        path = mo.group(1)
                        break # assume first occurrence is ok

    path = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(sys.argv[0])), path))

    return path

os.chdir(os.path.dirname(os.path.abspath(sys.argv[0])))  # switch to skeleton dir
qxpath = getQxPath()
REAL_GENERATOR = os.path.join(qxpath, 'tool', 'bin', 'generator.py')

if not os.path.exists(REAL_GENERATOR):
    print "Cannot find real generator script under: \"%s\"; aborting" % REAL_GENERATOR
    sys.exit(1)

argList = []
argList.append(CMD_PYTHON)
argList.append(REAL_GENERATOR)
argList.extend(sys.argv[1:])
if sys.platform == "win32":
    argList1=[]
    for arg in argList:
        if arg.find(' ')>-1:
            argList1.append('"%s"' % arg)
        else:
            argList1.append(arg)
    argList = argList1
else:
    argList = ['"%s"' % x for x in argList]  # quote argv elements
    
cmd = " ".join(argList)
retval = subprocess.call(cmd, shell=True)
sys.exit(retval)
