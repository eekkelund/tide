#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pyotherside
import os, pty, sys, glob
from select import select
from subprocess import PIPE, Popen, STDOUT
from threading import Thread
import signal

projectqml =None
process =None
bgthread =None
trace=None
plugins=None

def set_path(project_path, project_name):
    global projectqml
    projectqml = ""
    # Find main qml file
    if(os.path.isfile(project_path +"/qml/"+ project_name +".qml")):
        projectqml = project_path +"/qml/"+ project_name+".qml"
    elif(os.path.isfile(project_path+"/qml/main.qml")):
         projectqml = project_path+"/qml/main.qml"
    elif(os.path.isfile(project_path+"/qml/harbour-"+ project_name +".qml")):
        projectqml = project_path+"/qml/harbour-"+ project_name +".qml"
    elif(os.path.isfile(project_path +"/qml/" + project_name.replace("harbour-", "") +".qml")):
        projectqml = project_path +"/qml/" + project_name.replace("harbour-", "") +".qml"
    elif(os.path.isfile(project_path +"/src/qml/"+ project_name +".qml")):
        projectqml = project_path +"/src/qml/"+ project_name+".qml"
    elif(os.path.isfile(project_path +"/src/qml/main.qml")):
        projectqml = project_path +"/src/qml/main.qml"
    else:
        for file in glob.glob(project_path +"/qml/*" + ".qml"):
            projectqml = file
    return "path added"

def run_process():
    master_fd, slave_fd = pty.openpty()
    global process
    new_env = os.environ.copy()
    if (trace):
        new_env['QML_IMPORT_TRACE'] = '1'#if user wants trace
    elif(plugins):
        new_env['QT_DEBUG_PLUGINS']='1'#if user wants plugins log
    new_env['QT_LOGGING_TO_CONSOLE']='1'
    process = Popen(["qmlscene", projectqml], stdin=slave_fd, stdout=slave_fd, stderr=STDOUT, bufsize=0, close_fds=True, env=new_env )
    pyotherside.send('pid', process.pid)
    timeout = .1
    with os.fdopen(master_fd, 'r+b', 0) as master:
        input_fds = [master, sys.stdin]
        while True:
            fds = select(input_fds, [], [], timeout)[0]
            if master in fds: # subprocess' output is ready
                data = os.read(master_fd, 512) # <-- doesn't block, may return less
                if not data: # EOF
                    input_fds.remove(master)
                else:
                    os.write(sys.stdout.fileno(), data) # copy to our stdout
                    pyotherside.send('output', {'out':data})
            if sys.stdin in fds: # got user input
                data = os.read(sys.stdin.fileno(), 512)
                if not data:
                    input_fds.remove(sys.stdin)
                else:
                    master.write(data) # copy it to subprocess' stdin
            if not fds: # timeout in select()
                if process.poll() is not None: # subprocess ended
                    # and no output is buffered <-- timeout + dead subprocess
                    assert not select([master], [], [], 0)[0] # race is possible
                    os.close(slave_fd) # subproces don't need it anymore
                    break
    rc = process.wait()
    print("subprocess exited with status %d" % rc)
    processs.kill()

def init(import_trace, import_plugins):
    global trace
    trace = import_trace
    global plugins
    plugins = import_plugins
    global bgthread
    bgthread = Thread(target=run_process)
    return "created"


def start_proc():
    bgthread.start()
    return "started"


def kill():
    if(process.pid):
        try:
            os.kill(process.pid, signal.SIGTERM)
        except ProcessLookupError:
            bgthread = None
    process.wait()
    bgthread = None
    return "stopperd"

pyotherside.atexit(kill)
