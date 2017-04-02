/*****************************************************************************
 *
 * Created: 2016 by Eetu Kahelin / eekkelund
 *
 * Copyright 2016 Eetu Kahelin. All rights reserved.
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

Dialog {
    on_ActivatedChanged: {
        if(noPath && _activated){
            lmodel.loadNew(homePath)
        }
    }

    property string path
    property string noName: ""
    property bool noPath: false
    property string accDest
    property var replacePage
    property string fPath
    acceptDestination:Qt.resolvedUrl(accDest)
    acceptDestinationAction: PageStackAction.Replace
    DialogHeader {
        id:dHdr
        acceptText: qsTr("Add")
    }
    SilicaListView {
        id:fileAddList
        width: page.width
        //contentHeight: cMenu.height+row.height
        height: cMenu.height+row.height
        anchors.top: dHdr.bottom
        //anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left


        model: VisualItemModel {
            Row {
                id:row
                anchors.fill: parent
                TextField {
                    id: fileName
                    inputMethodHints: Qt.ImhNoPredictiveText
                    placeholderText:noPath ? noName: qsTr("Name of the file")
                    width: parent.width/2
                    validator: RegExpValidator { regExp: /.+/ }
                }
                ComboBox {
                    id:cBox
                    width: parent.width / 2
                    menu: ContextMenu {
                        id: cMenu
                        MenuItem {
                            id:anyType
                            TextField {
                                id:fType
                                anchors.horizontalCenter: parent.horizontalCenter
                                horizontalAlignment:parent.horizontalAlignment
                                x: parent.x
                                color: "transparent"
                                width: parent.width/2
                                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                                placeholderText: qsTr("Filetype")
                                placeholderColor: Theme.highlightDimmerColor
                                validator: RegExpValidator { regExp: /.+/ }
                                EnterKey.onClicked: {
                                    cBox.currentItem = anyType
                                    ext = anyType.text
                                    parent.down=true
                                    cMenu.hide()
                                }
                                onTextChanged: ext = "."+ text
                            }
                            text: "."+ fType.text
                            onClicked: {
                                ext = text
                            }
                        }
                        MenuItem {
                            text: ".qml"
                            onClicked: ext = text
                        }
                        MenuItem {
                            text: ".js"
                            onClicked: ext = text
                        }
                        MenuItem {
                            text: ".py"
                            onClicked: ext = text
                        }
                        MenuItem {
                            text: ".txt"
                            onClicked: ext = text
                        }
                    }
                }
            }
        }
    }
    SilicaListView {
        anchors.top: fileAddList.bottom
        width: page.width
        height: page.height-fileAddList.height-Theme.itemSizeLarge
        visible:noPath
        enabled:visible
        clip:true
        model: ListModel{
            id: lmodel
            function loadNew(path2) {
                clear()
                py.call('openFile.allfiles', [path2], function(result) {
                    for (var i=0; i<result.length; i++) {
                        lmodel.append(result[i]);
                    }
                });
            }
        }
        delegate: ListItem {
            property string path2: pathh
            id: litem
            width: parent.width
            height: Theme.itemSizeSmall
            anchors {
                left: parent.left
                right: parent.right
            }
            onClicked: {
                if (file.text.slice(-1) =="/") {
                    lmodel.loadNew(path2);
                    path=path2
                }else {}

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


    canAccept: fileName.text !== ""&& ext !==""&& ext !=="." ? true :false
    onAccepted: {
        if (fileName.text !== ""&& ext !==""&& ext !==".") {
            var fName = fileName.text
            if (!path){
                path=homePath
            }
            fPath = path +"/"+ fName + ext
            if(replacePage){
                py.call('editFile.saveAs', [fName,ext,path,myeditor.text], function(fPath) {
                    fPath=path
                    textChangedSave=false;
                });
                filePath = fPath
                acceptDestinationAction = PageStackAction.Pop
                acceptDestination=replacePage
                //acceptDestinationInstance.fullFilePath = filePath
                 //acceptDestinationReplaceTarget=replacePage
                acceptDestinationProperties = {fullFilePath: fPath, fileTitle:(fName+ext)}
            }else{
                py.call('addFile.createFile', [fName,ext,path], function(fPath) {
                    fPath=path
                });
                filePath = fPath
                if(accDest=="ProjectHome.qml"){
                    lmodel.loadNew(path);
                }
                accDest=Qt.resolvedUrl("EditorPage.qml")
                dialog.acceptDestination=Qt.resolvedUrl("EditorPage.qml")
                acceptDestinationInstance.fullFilePath = fPath
            }

            singleFile=(fName+ext)
            fileName.focus= false;
            fileName.text = ""
            fType.text =""
            cBox.currentIndex = 0

        }
    }
    onOpened:{
        fileName.focus= false;
        fileName.text = ""
        fType.text =""
        cBox.currentIndex = 0
        acceptDestination=Qt.resolvedUrl(accDest);

    }
}

