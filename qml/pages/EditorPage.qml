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
import harbour.tide.documenthandler 1.0
import harbour.tide.keyboardshortcut 1.0
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
    property var lineNumberList: documentHandler.lines
    property alias background: background
    property alias myeditor: myeditor
    property alias drawer:drawer
    property alias restoreD:restoreD

    onFullFilePathChanged:{
        fileTitle=fullFilePath?  fullFilePath.substring(fullFilePath.lastIndexOf('/')+1) : "untitled"
        untitled=fullFilePath?false:true
        previousPath=fullFilePath.substring(0,fullFilePath.lastIndexOf('/'))
        fileType= /~$/.test(fileTitle) ? fileTitle.split(".").slice(-1)[0].slice(0, -1) :fileTitle.split(".").slice(-1)[0]
        console.log(previousPath +"---"+ fullFilePath+"---"+fileTitle+"---")
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
            if (autoSave&&textChangedAutoSave){
                py.call('editFile.savings', [fullFilePath,myeditor.text], function(result) {
                    fileTitle=result
                });
            }
            ready =false
            return;
        }
        else {
            if(untitled){
                py.call('editFile.untitledNumber', [homePath], function(result) {
                    fileTitle=result
                });
            }
            else{
                documentHandler.setMultiLineHighlight(multiLineHighLight)
                documentHandler.setStyle(propertiesHighlightColor, stringHighlightColor,
                                         qmlHighlightColor, javascriptHighlightColor,
                                         commentHighlightColor, keywordsHighlightColor,
                                         myeditor.font.pixelSize);
                py.call('editFile.checkAutoSaved', [fullFilePath], function(result) {
                    if(!result){
                        py.call('editFile.openings', [fullFilePath], function(result) {
                            documentHandler.text = result.text;
                            fileTitle=result.fileTitle
                            if(!editorMode){
                                py.call('editFile.changeFiletype', [fileType], function(result){});
                            }
                            documentHandler.setDictionary(fileType);
                        })
                    }else {
                        if(fileTitle.slice(-1)!="~") pageStack.push(restoreD, {pathToFile:fullFilePath});
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
                    enabled:editorMode
                    visible:enabled
                    text: qsTr("About & Help")
                    onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
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
                                    fileType= /~$/.test(fileTitle) ? fileTitle.split(".").slice(-1)[0].slice(0, -1) :fileTitle.split(".").slice(-1)[0];
                                    previousPath=fullFilePath.substring(0,fullFilePath.lastIndexOf('/'))
                                    if(!editorMode){
                                        py.call('editFile.changeFiletype', [fileType], function(result){});
                                    }
                                    documentHandler.setMultiLineHighlight(multiLineHighLight)
                                    documentHandler.setStyle(propertiesHighlightColor, stringHighlightColor,
                                                             qmlHighlightColor, javascriptHighlightColor,
                                                             commentHighlightColor, keywordsHighlightColor,
                                                             myeditor.font.pixelSize);
                                    documentHandler.setDictionary(fileType);

                                })
                            }else {
                                pageStack.push(restoreD, {pathToFile:path});
                            }
                        })
                        myeditor.forceActiveFocus();
                    }

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

                PullDownMenu {
                    enabled:!inSplitView
                    visible:enabled
                    MenuItem {
                        enabled:!inSplitView
                        visible:enabled
                        text:  qsTr("Settings")
                        onClicked: {
                            pageStack.pushAttached(Qt.resolvedUrl("SettingsPage.qml"))
                            pageStack.navigateForward()
                        }
                    }
                }
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
                    height: topBar.height

                    Rectangle {
                        id: headerRec
                        width: parent.width
                        height: parent.height
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
                            GradientStop { position: 1.0; color: Theme.rgba("transparent", 0.3) }
                        }

                        TopBar {
                            id:topBar
                        }
                    }
                }
            }
            SilicaFlickable {
                id:f
                clip: true
                anchors.top: hdr.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right:parent.right
                contentHeight:  contentColumn.height
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
                        if(textChangedAutoSave){
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
                        hdr.visible=false
                        f.anchors.top = background.top
                    }
                    if (startY-contentY > 200 && time < 2 ) {
                        hdr.visible=true
                        f.anchors.top = hdr.bottom
                    }
                    if (contentY<100){
                        hdr.visible=true
                        f.anchors.top = hdr.bottom
                    }
                }

                Item {
                    id:all
                    anchors.fill: parent

                    Rectangle {
                        id: linenum
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: lineNums ? linecolumn.width *1.2 : Theme.paddingSmall
                        color: "transparent"
                        visible: lineNums
                        Column {
                            id: linecolumn
                            y: Theme.paddingSmall
                            anchors.horizontalCenter: parent.horizontalCenter

                            Repeater {
                                id:repeat
                                model: myeditor._editor.lineCount
                                delegate: TextEdit {
                                    anchors.right: linecolumn.right
                                    height: myeditor._editor.cursorRectangle.height
                                    color: index + 1 === myeditor.currentLine ? Theme.primaryColor : Theme.secondaryColor
                                    readOnly:true
                                    font.pixelSize: myeditor.font.pixelSize
                                    text: lineNumberList[index]
                                }
                            }
                        }
                    }
                    Column {
                        id: contentColumn
                        anchors.top: parent.top
                        anchors.left: linenum.right
                        anchors.right: parent.right

                        TextArea {
                            id: myeditor
                            property string previousText: ""
                            property bool textChangedManually: false
                            property int currentLine: myeditor.positionToRectangle(cursorPosition).y/myeditor.positionToRectangle(cursorPosition).height +1
                            property bool modified: false
                            property string path
                            property int lineCount: _editor.lineCount

                            property string textBeforeCursor
                            property var openBrackets
                            property var closeBrackets
                            property int openBracketsCount
                            property int closeBracketsCount
                            property int indentDepth
                            property string indentStr

                            width: background.width -parent.x
                            textMargin: 0
                            labelVisible: false
                            wrapMode: appWindow.wrapMode
                            text: documentHandler.text
                            color: focus ? textColor : Theme.primaryColor
                            font.pixelSize: fontSize
                            font.family: fontType
                            textWidth: wrapMode !== Text.NoWrap ? width : Math.max(width, editor.implicitWidth)
                            _flickableDirection: Flickable.HorizontalAndVerticalFlick

                            KeyboardShortcut {
                                key: "Ctrl+F"
                                onActivated: {
                                    if(myeditor.focus){
                                        shortcutUsed=true
                                       topBar.searchActive()
                                    }
                                }
                            }
                            KeyboardShortcut {
                                key: "Ctrl+S"
                                onActivated: {
                                    if(myeditor.focus){
                                        shortcutUsed=true
                                        if(untitled){
                                            pageStack.push(dialog, {callback:saveAsNewFile,path:previousPath, showFolderList:true, noName:fileTitle/*, replacePage:pageStack.currentPage*/})
                                        }else {
                                            py.call('editFile.savings', [fullFilePath,myeditor.text], function(result) {
                                                fileTitle=result
                                            });
                                        }
                                        textChangedSave=false;
                                    }
                                }
                            }

                            EnterKey.onClicked: {
                                var colonCount

                                textChangedAutoSave=true;
                                f.startY = f.contentY
                                textBeforeCursor = text.substring(0, cursorPosition - 1)

                                if(fileType=="py"){
                                    if(text[cursorPosition - 2]===":"){
                                        colonCount = textBeforeCursor.match(/\:/g).length
                                        indentStr = new Array(colonCount).join("    ")
                                        _editor.insert(cursorPosition - 1, indentStr)
                                        return
                                    }
                                }else if(indentSize<0){
                                    return
                                }else{

                                    openBrackets = textBeforeCursor.match(/\{/g)
                                    closeBrackets = textBeforeCursor.match(/\}/g)

                                    if (openBrackets !== null)
                                    {
                                        openBracketsCount = openBrackets.length
                                        closeBracketsCount = 0

                                        if (closeBrackets !== null)
                                            closeBracketsCount = closeBrackets.length

                                        indentDepth = openBracketsCount - closeBracketsCount
                                        if (indentDepth > 0){
                                            indentStr = new Array(indentDepth + 1).join(indentString)

                                            textChangedManually = true
                                            _editor.insert(cursorPosition, indentStr)
                                        }
                                    }
                                }
                            }

                            onTextChanged: {
                                if(shortcutUsed&&myeditor.focus){
                                    shortcutUsed=false
                                    if(myeditor.text[myeditor.cursorPosition - 1] === "s"|| myeditor.text[myeditor.cursorPosition - 1] === "S"){
                                        myeditor._editor.remove(myeditor.cursorPosition - 1, myeditor.cursorPosition)
                                    }
                                }
                                if (text !== previousText)
                                {
                                    textChangedSave = true
                                    if (textChangedManually)
                                    {
                                        previousText = text
                                        textChangedManually = false
                                        return
                                    }
                                    if(indentSize<0){
                                        return
                                    } else if (myeditor.text.length > previousText.length) {
                                        var lastCharacter = text[cursorPosition - 1]

                                        if(lastCharacter=="}") {
                                            //bug fix with letters after "}"
                                            if (/^[a-zA-Z]/.test(text[cursorPosition])){
                                                return
                                            }

                                            var lineBreakPosition
                                            for (var i = cursorPosition - 2; i >= 0; i--)
                                            {
                                                if (text[i] !== " ")
                                                {
                                                    if (text[i] === "\n")
                                                        lineBreakPosition = i

                                                    break
                                                }
                                            }
                                            if (lineBreakPosition !== undefined)
                                            {
                                                textChangedManually = true

                                                _editor.remove(lineBreakPosition + 1, cursorPosition - 1)
                                                //will remove empty spaces*indentDepth
                                                textBeforeCursor = text.substring(0, cursorPosition-1)
                                                openBrackets = textBeforeCursor.match(/\{/g)
                                                closeBrackets = textBeforeCursor.match(/\}/g)

                                                if (openBrackets !== null)
                                                {

                                                    openBracketsCount = openBrackets.length
                                                    closeBracketsCount = 0

                                                    if (closeBrackets !== null)
                                                        closeBracketsCount = closeBrackets.length

                                                    indentDepth = openBracketsCount - closeBracketsCount -1

                                                    if (indentDepth >= 0){
                                                        indentStr = new Array(indentDepth + 1).join(indentString)
                                                        textChangedManually = true
                                                        _editor.insert(cursorPosition - 1, indentStr)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    previousText = text
                                }
                            }

                            DocumentHandler {
                                id: documentHandler
                                target: myeditor._editor
                                cursorPosition: myeditor.cursorPosition
                                selectionStart: myeditor.selectionStart
                                selectionEnd: myeditor.selectionEnd
                                onTextChanged: {
                                    myeditor.text = text
                                    myeditor.update()
                                }
                            }
                        }
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
}
