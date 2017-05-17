#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pyotherside
import configparser
import os

def openings(filepath):
    file = open(filepath, 'r', encoding = "utf-8")
    txt = file.read()
    file.close()
    return{'text': txt, 'fileTitle': os.path.basename(filepath)}

def openAutoSaved(filepath):
    file = open(filepath+"~", 'r', encoding = "utf-8")
    txt = file.read()
    file.close()
    return{'text': txt, 'fileTitle': os.path.basename(filepath+"~")}

def checkAutoSaved(filepath):
    if os.path.exists(filepath+"~"):
        return True
    else:
        return False

def untitledNumber(folderpath):
    for i in range(1,1000):
        if not os.path.exists(folderpath+"/"+"untitled"+str(i)):
            if not os.path.exists(folderpath+"/"+"untitled"+str(i)+"~"):
                return "untitled"+str(i)
    return "Error, too many untitled files"

def saveAs(fileName,ext,path,text):
    file = open(path +"/"+ fileName + ext, 'a+', encoding = "utf-8")
    file.write(text)
    file.close()
    return (path +"/"+ fileName + ext)

def savings(filepath, text):
    if os.path.exists(filepath+"~"):
        os.remove(filepath+"~")
    file = open(filepath, 'w', encoding = "utf-8")
    file.write(text)
    file.close()
    return os.path.basename(filepath)

def changeFiletype(filetype):
    config = configparser.RawConfigParser()
    config.read("/var/lib/harbour-tide-keyboard/config/config.conf")
    config.set('fileType', 'type', filetype)
    # Updating configuration file 'config.conf'
    with open("/var/lib/harbour-tide-keyboard/config/config.conf", 'w+') as configfile:
        config.write(configfile)

def autosave(filepath, text):
    if(filepath.endswith("~")):
        file = open(filepath, 'w', encoding = "utf-8")
    else:
        file = open(filepath+"~", 'w', encoding = "utf-8")
    file.write(text)
    file.close()
    return os.path.basename(filepath+"~")


