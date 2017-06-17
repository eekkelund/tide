/*****************************************************************************
 *
 * Created: 2016-2017 by Eetu Kahelin / eekkelund
 *
 * Copyright 2016-2017 Eetu Kahelin. All rights reserved.
 *
 * This file may be distributed under the terms of GNU Public License version
 * 3 (GPL v3) as defined by the Free Software Foundation (FSF). A copy of the
 * license should have been included with this file, or the project in which
 * this file belongs to. You may also find the details of GPL v3 at:
 * http://www.gnu.org/licenses/gpl-3.0.txt
 *
 * If you have any questions regarding the use of this file, feel free to
 * contact the author of this file, or the owner of the project in which
 * this file belongs to.
*****************************************************************************/
import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import harbour.tide.editor.documenthandler 1.0
import "../components"

Page {
    id: page
    objectName: "editorPage"
    property bool textChangedAutoSave: false
    property bool textChangedSave: false
    property bool searched: false
    property bool shortcutUsed: false
    property bool ready: false
    property string fileTitle:fullFilePath? fullFilePath.substring(fullFilePath.lastIndexOf('/')+1) : "untitled"
    property bool untitled:fullFilePath?false:true
    property string fullFilePath
    property string previousPath:fullFilePath.substring(0,fullFilePath.lastIndexOf('/'))
    property bool inSplitView: false
    property string ext: ""
    //Check if file ends with tilde "~" and change the filetype accordingly
    property string fileType: /~$/.test(fileTitle) ? fileTitle.split(".").slice(-1)[0].slice(0, -1) :fileTitle.split(".").slice(-1)[0]
    property DocumentHandler documentHandler: editorArea.documentHandler
    property alias topBar: topBar
    property alias background: background
    property alias myeditor: editorArea
    property alias drawer:drawer
    property alias restoreD:restoreD

    onFullFilePathChanged:{
        fileTitle=fullFilePath?  fullFilePath.substring(fullFilePath.lastIndexOf('/')+1) : "untitled"
        untitled=fullFilePath?false:true
        previousPath=fullFilePath.substring(0,fullFilePath.lastIndexOf('/'))
        fileType= /~$/.test(fileTitle) ? fileTitle.split(".").slice(-1)[0].slice(0, -1) :fileTitle.split(".").slice(-1)[0]
    }
    function saveAsNewFile(){
        py.call('editFile.saveAs', [dialog.fName,ext,dialog.path,myeditor.text], function(fPath) {
            fileTitle=dialog.fName+ext
            dialog.acceptDestinationAction = PageStackAction.Pop
            dialog.acceptDestination=pageStack.currentPage
            fullFilePath=fPath
            textChangedSave=false;
            pageStatusChange(page)
        });
    }

    function createNewFile(){
        py.call('addFile.createFile', [dialog.fName,ext,dialog.path], function(fPath) {
            fileTitle=dialog.fName+ext
            fullFilePath=fPath
            dialog.acceptDestinationAction = PageStackAction.Pop
            dialog.acceptDestination=pageStack.currentPage
            pageStatusChange(page)
        });
    }

    function pageStatusChange(page){
        if(!inSplitView && page.status === PageStatus.Active && pageStack.forwardNavigation) {
            pageStack.popAttached()

        }
        if((page.status !== PageStatus.Active) /*|| (myeditor.text.length > 0)*/){
            if (autoSave&&textChangedSave&&!untitled){
                py.call('editFile.savings', [fullFilePath,myeditor.text], function(result) {
                    fileTitle=result
                });
            }
            ready =false
            return;
        } else {
            if(untitled){
                py.call('editFile.untitledNumber', [homePath], function(result) {
                    fileTitle=result
                });
            } else{
                if(highlight) {
                    setHighlight()
                }
                py.call('editFile.checkAutoSaved', [fullFilePath], function(result) {
                    if(!result){
                        py.call('editFile.openings', [fullFilePath], function(result) {
                            documentHandler.text = result.text;
                            fileTitle=result.fileTitle
                            if(!editorMode){
                                py.call('editFile.changeFiletype', [fileType], function(result){});
                            }
                            if(highlight) {
                                documentHandler.setDictionary(fileType);
                            }
                        })
                    }else {
                        if(fileTitle.slice(-1)!="~"){
                            pageStack.push(restoreD, {pathToFile:fullFilePath});
                        } else {
                            if(highlight) {
                                documentHandler.setDictionary(fileType);
                            }
                        }
                    }
                })
            }
            previousPath=fullFilePath.substring(0,fullFilePath.lastIndexOf('/'))
            myeditor.forceActiveFocus();
            busy.running=false;
            hintLoader.start()
        }
        ready = true
    }

    function setHighlight() {
        documentHandler.setStyle(propertiesHighlightColor, stringHighlightColor,
                                 qmlHighlightColor, javascriptHighlightColor,
                                 commentHighlightColor, keywordsHighlightColor,
                                 myeditor.font.pixelSize);
    }

    function fileBrowser(file,path) {
        if (file.text.slice(-1) =="/") {
            lmodel.loadNew(path);
        }else {
            fullFilePath=path
            py.call('editFile.checkAutoSaved', [fullFilePath], function(result) {
                if(!result){
                    py.call('editFile.openings', [fullFilePath], function(result) {
                        fileTitle=result.fileTitle
                        // singleFile=result.fileTitle
                        documentHandler.text = result.text;
                        fileType = /~$/.test(fileTitle) ? fileTitle.split(".").slice(-1)[0].slice(0, -1) :fileTitle.split(".").slice(-1)[0];
                        previousPath=fullFilePath.substring(0,fullFilePath.lastIndexOf('/'))
                        if(!editorMode){
                            py.call('editFile.changeFiletype', [fileType], function(result){});
                        }
                        if(highlight) {
                            setHighlight()
                            documentHandler.setDictionary(fileType);
                        }

                    })
                }else {
                    pageStack.push(restoreD, {pathToFile:path});
                }
            })
            myeditor.forceActiveFocus();
        }
    }

    Drawer {
        id: drawer

        anchors.fill: parent

        dock: Dock.Left

        background: SilicaListView {
            anchors.fill: parent
            model: ListModel{
                id: lmodel
                property string folderPathForNewFile
                function loadNew(path) {
                    clear()
                    folderPathForNewFile=path
                    py.call('openFile.allfiles', [path], function(result) {
                        for (var i=0; i<result.length; i++) {
                            lmodel.append(result[i]);
                        }
                    });
                }
            }

            PullDownMenu {
                enabled:!inSplitView
                visible:enabled
                MenuItem {
                    enabled:!inSplitView
                    visible:enabled
                    text:  qsTr("New file")
                    onClicked: {
                        drawer.open = false
                        pageStack.push(dialog, {callback:createNewFile,path:lmodel.folderPathForNewFile, showFolderList:true})
                    }
                }
            }

            header: PageHeader {
                title: qsTr("Open file")
            }
            VerticalScrollDecorator {}

            delegate: ListItem {
                property string path: pathh
                id: litem
                width: parent.width
                height: Theme.itemSizeSmall
                anchors {
                    left: parent.left
                    right: parent.right
                }
                onClicked: {
                    fileBrowser(file,path)
                }
                Label {
                    id: file
                    wrapMode: Text.WordWrap
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.paddingMedium
                    text: files

                }
            }
        }

        foreground: Rectangle {
            id:background
            color: bgColor
            anchors.top:parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            //anchors.right: drawer.open ? background.right : parent.right
            width: drawer.opened ? all.width : parent.width
            //anchors.fill: parent
            visible: true

            MouseArea {
                enabled: drawer.open
                anchors.fill: parent
                onClicked: drawer.open = false
            }

            BusyIndicator {
                id:busy
                size: BusyIndicatorSize.Large
                anchors.centerIn: parent
                running: true
            }

            SilicaFlickable {
                id:hdr
                anchors.top:parent.top
                height: headerColumn.height
                width: parent.width
                enabled: !drawer.opened
                //height: contentHeight

                //wait that hint property is loaded
                Timer {
                    id:hintLoader
                    interval:500
                    onTriggered:{
                        if(hint<3){
                            headerHint.start()
                            hint = hint+1
                        }
                    }
                }

                TouchInteractionHint{
                    id: headerHint
                    z: 999
                    direction: TouchInteraction.Up
                    anchors.horizontalCenter: parent.horizontalCenter
                    distance: 1
                    loops: 2
                }
                InteractionHintLabel {
                    text: qsTr("Tap to show top bar")
                    opacity: headerHint.running ? 1.0 : 0.0
                    Behavior on opacity { FadeAnimation {} }
                    width: parent.width
                    anchors.top: parent.bottom
                    invert: true
                }

                Column {
                    id:headerColumn
                    width: parent.width
                    spacing: Theme.paddingSmall
                    height: topBar.height + replaceBar.height
                    visible: hdr.height>=topBar.height
                    onHeightChanged: hdr.height = height

                    Rectangle {
                        id: headerRec
                        width: parent.width
                        height: parent.height
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Theme.rgba(rootMode ? reverseColor(Theme.highlightBackgroundColor) :Theme.highlightBackgroundColor, 0.15) }
                            GradientStop { position: 1.0; color: Theme.rgba("transparent", 0.3) }
                        }
                        TopBar {
                            id:topBar
                            onFolderOpen: {
                                busy.running=true
                                fullFilePath = newPath
                            }
                        }
                        Item{
                            id:replaceBar
                            anchors.top:topBar.bottom
                            //anchors.verticalCenter: parent.verticalCenter
                            // anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            height: 0
                            visible: height == topBar.height
                            enabled: height == topBar.height
                            Flow {
                                id:menu
                                height: parent.height
                                anchors.horizontalCenter: parent.horizontalCenter
                                width:parent.width
                                TextField {
                                    height: parent.height
                                    id:replaceField
                                    width:parent.width-closeReplace.height*2
                                    placeholderText: qsTr("Replace")
                                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                                    EnterKey.onClicked: {
                                        if(topBar.foundEnd-topBar.foundStart>0 && replaceField.text.length>0) {
                                            replaceField.selectAll()
                                            replaceField.copy()
                                            myeditor.select(topBar.foundStart,topBar.foundEnd)
                                            myeditor.paste()
                                            topBar.foundStart=-1
                                            topBar.foundEnd = -1
                                        }
                                    }
                                }

                                IconButton {
                                    id:replaceBtn
                                    icon.source: "image://theme/icon-m-acknowledge"
                                    visible:parent.visible
                                    enabled: replaceField.text.length>0
                                    onClicked:{
                                        if(topBar.foundEnd-topBar.foundStart>0 && replaceField.text.length>0) {
                                            replaceField.selectAll()
                                            replaceField.copy()
                                            myeditor.select(topBar.foundStart,topBar.foundEnd)
                                            myeditor.paste()
                                            topBar.foundStart=-1
                                            topBar.foundEnd = -1
                                        }
                                    }
                                }
                                IconButton {
                                    id:closeReplace
                                    icon.source: "image://theme/icon-m-page-up"
                                    visible:parent.visible
                                    onClicked:{
                                        replaceField.text=""
                                        topBar.replaceFieldClosed=true
                                        if (!topBar.searchField.activeFocus) topBar.searchField.forceActiveFocus()
                                        replaceBar.height = 0
                                    }
                                }
                            }
                            Behavior on height { PropertyAnimation {duration:150} }
                        }
                    }
                }
                Behavior on height { PropertyAnimation {duration:150} }
            }
            SilicaFlickable {
                id:f
                clip: true
                anchors.top: hdr.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right:parent.right
                contentHeight:  editorArea.height
                enabled: !drawer.opened
                property int time
                property int startY
                VerticalScrollDecorator {}
                onMovementStarted: {
                    startY = contentY
                    time = 0
                    timeri.restart()
                }

                Timer {
                    id:timeri
                    interval: 500;
                    repeat:true;
                    onTriggered: {
                        f.time = f.time +1
                    }
                }

                Timer {
                    id:autosaveTimer
                    interval: 3000;
                    running: autoSave;
                    repeat: autoSave;
                    onTriggered: {
                        if(textChangedAutoSave&&!untitled){
                            var tmpPath=fullFilePath?fullFilePath:StandardPaths.home+"/"+fileTitle.replace(/~$/, '');
                            py.call('editFile.autosave', [tmpPath,myeditor.text], function(result) {
                                fileTitle=result
                                previousPath=tmpPath.substring(0,tmpPath.lastIndexOf('/'))
                            });
                            textChangedAutoSave=false;
                        }
                    }
                }

                onContentYChanged: {
                    if (contentY-startY > 200 && time < 2 ) {
                        //hdr.visible=false
                        //f.anchors.top = background.top
                        hdr.height=0
                    }
                    if (startY-contentY > 200 && time < 2 ) {
                        //hdr.visible=true
                        //f.anchors.top = hdr.bottom
                        hdr.height=headerColumn.height
                    }
                    if (contentY<100){
                        hdr.height=headerColumn.height
                    }
                }

                Item {
                    id:all
                    anchors.fill: parent

                    LineNumArea {
                        id:linenum
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        lineNumberList: documentHandler.lines
                    }

                    EditorArea {
                        id:editorArea
                        anchors.top: parent.top
                        anchors.left: linenum.right
                        anchors.right: parent.right
                        shortcutUsed: shortcutUsed
                        width: background.width -parent.x
                    }
                }
            }
            Python {
                id: py

                Component.onCompleted: {
                    addImportPath(Qt.resolvedUrl('./../python'));
                    importModule('editFile', function () {});
                    importModule('openFile', function () {});
                    importModule('addFile', function () {});
                }
                onError: {
                    showError(traceback)
                    // when an exception is raised, this error handler will be called
                    console.log('python error: ' + traceback);

                }
            }
        }
    }
    onStatusChanged:{
        pageStatusChange(page)
    }

    RestoreDialog{
        id:restoreD
    }
    AddFileDialog {
        id: dialog
    }
    Connections {
        target: appWindow
        onHighlightChanged: {
            documentHandler.enableHighlight(highlight)
        }
    }
}
