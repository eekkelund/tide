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
import "../components"

Dialog {
    on_ActivatedChanged: {
        if(_activated && showFolderList){
            fileManagerComponent.listmodel.loadNew(path)
        }
        ext=""
        acceptDestination=Qt.resolvedUrl(accDest)
        acceptDestinationAction= PageStackAction.Replace
    }

    property string path
    property string noName
    property bool noPath: false
    property string accDest
    property var replacePage
    property bool showFolderList
    property string fName
    property var callback
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
                    description: qsTr("File type")
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
                            id:readyOnes
                            width: parent.width
                            height: cBoxx.height
                            color:"transparent"
                        ComboBox {
                            id:cBoxx
                            width: parent.width
                            currentIndex: -1
                            label: qsTr("Ready template")
                            menu: ContextMenu {
                                on_OpenChanged:{
                                    if(!_open) {
                                        cBoxx.currentItem=null
                                    }
                                }
                                MenuItem {
                                    text: ".qml"
                                    onClicked:{
                                        ext = text
                                        cBox.currentItem = readyOnes
                                        readyOnes.text=text
                                        cMenu.hide()
                                    }
                                }
                                MenuItem {
                                    text: ".js"
                                    onClicked:{
                                        ext = text
                                        cBox.currentItem = readyOnes
                                        readyOnes.text=text
                                        cMenu.hide()
                                    }
                                }
                                MenuItem {
                                    text: ".py"
                                    onClicked:{
                                        ext = text
                                        cBox.currentItem = readyOnes
                                        readyOnes.text=text
                                        cMenu.hide()
                                    }
                                }
                                MenuItem {
                                    text: ".txt"
                                    onClicked:{
                                        ext = text
                                        cBox.currentItem = readyOnes
                                        readyOnes.text=text
                                        cMenu.hide()
                                    }
                                }
                                MenuItem {
                                    text: ".sh"
                                    onClicked:{
                                        ext = text
                                        cBox.currentItem = readyOnes
                                        readyOnes.text=text
                                        cMenu.hide()
                                    }
                                }
                            }
                        }
                        }
                    }
                }
            }
        }
    }
   FileManagerComponent {
       id:fileManagerComponent
       anchors.top: fileAddList.bottom
       width: page.width
       height: page.height-fileAddList.height-Theme.itemSizeLarge
       visible:showFolderList
       enabled:visible
   }



    canAccept: fileName.text !== ""&& ext !==""&& ext !=="." && fileManagerComponent.files.indexOf(fileName.text + ext) == -1 ? true :false
    onAccepted: {
        if (fileName.text !== ""&& ext !==""&& ext !==".") {
            fName = fileName.text
            if (!path){
                path=homePath
            }
            var titleOfFile=fName + ext
            callback()
            //   singleFile=titleOfFile
            fileName.focus= false;
            fileName.text = ""
            readyOnes.text=""
            fType.text =""
            cBox.currentIndex=0
            cBoxx.currentItem = null


        }
    }
    onOpened:{
        fileName.focus= false;
        fileName.text = ""
        fType.text =""
        readyOnes.text=""
        cBox.currentIndex=0
        cBoxx.currentItem = null
        acceptDestination=Qt.resolvedUrl(accDest);

    }
}

