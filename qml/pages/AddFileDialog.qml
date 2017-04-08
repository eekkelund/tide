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
        if(_activated && showFolderList){
            listmodel.loadNew(path)
        }
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
        id:listView
        anchors.top: fileAddList.bottom
        width: page.width
        height: page.height-fileAddList.height-Theme.itemSizeLarge
        visible:showFolderList
        enabled:visible
        clip:true
        property var files: []
        model: ListModel{
            id: listmodel
            function loadNew(path2) {
                clear()
                listView.files = []
                py.call('openFile.allfiles', [path2], function(result) {
                    for (var i=0; i<result.length; i++) {
                        listView.files.push(result[i].files)
                        listmodel.append(result[i]);
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
                    listmodel.loadNew(path2);
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


    canAccept: fileName.text !== ""&& ext !==""&& ext !=="." && listView.files.indexOf(fileName.text + ext) == -1 ? true :false
    onAccepted: {
        if (fileName.text !== ""&& ext !==""&& ext !==".") {
            fName = fileName.text
            if (!path){
                path=homePath
            }
            var titleOfFile=fName + ext
            callback()
            singleFile=titleOfFile
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

