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

Page {
    id: page
    property string projectHomePath: projectPath+ "/"+projectName
    property string ext: ""

    function addNewFile(){
        lmodel.loadNew(dialog.path)
        dialog.acceptDestinationAction = PageStackAction.Replace
        dialog.accDest=Qt.resolvedUrl("EditorPage.qml")
        dialog.acceptDestination=Qt.resolvedUrl("EditorPage.qml")
        py.call('addFile.createFile', [dialog.fName,ext,dialog.path], function(fPath) {
            dialog.acceptDestinationInstance.fileTitle=dialog.fName+ext
            dialog.acceptDestinationInstance.fullFilePath=fPath
        });
    }

    signal projectDeleted()

    RemorsePopup { id: remorsePopup }

    SilicaListView {
        id:fileList
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        VerticalScrollDecorator {}
        PullDownMenu {
            MenuItem {
                visible:!rootMode
                enabled:visible
                text: qsTr("Delete project")
                onClicked: {
                    remorsePopup.execute(qsTr("Deleting project"),  function () {
                        py.call('deleteProject.remove', [projectPath, projectName], function (success) {
                            if (success)
                            {
                                projectDeleted()
                                pageStack.pop()
                            }
                            else
                                console.log("Unable to remove project");
                        })
                    })
                }
            }
            MenuItem {
                visible:!rootMode
                enabled:visible
                text: qsTr("Build the app")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("BuildOutput.qml"))
                }
            }
            MenuItem {
                text: qsTr("Run the app")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AppOutput.qml"))
                }
            }
            MenuItem {
                text: qsTr("Add file")
                onClicked: {
                    pageStack.push(dialog, {callback:page.addNewFile, path:projectHomePath, showFolderList:false,accDest:"ProjectHome.qml"})


                }
            }
        }

        header: Column {
            width: parent.width
            spacing: Theme.paddingMedium
            PageHeader  {
                width: parent.width
                title: projectName
                _titleItem.color: rootMode ? reverseColor(Theme.highlightColor) :Theme.highlightColor
            }
            Label {
                width: parent.width
                anchors.bottomMargin: Theme.paddingLarge
                x: Theme.paddingLarge
                text: qsTr("Select file to open")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
            }
        }

        model: ListModel{
            id: lmodel
            function loadNew(path) {
                clear()
                py.call('openFile.files', [path], function(result) {
                    for (var i=0; i<result.length; i++) {
                        lmodel.append(result[i]);
                    }
                });
            }
        }

        delegate: ListItem {
            property string path: pathh
            id: litem
            width: parent.width
            height:Theme.itemSizeSmall
            anchors {
                left: parent.left
                right: parent.right
            }
            onClicked: {
                if (file.text.slice(-1) =="/") {
                    lmodel.loadNew(path);
                    projectHomePath = path;
                }
                else {
                    filePath=path;
                    //singleFile =file.text
                    pageStack.push(Qt.resolvedUrl("EditorPage.qml"),{fullFilePath: path, fileTitle: file.text})
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
    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('./../python'));
            importModule('addFile', function() {});
            importModule('buildRPM', function() {});
            importModule('deleteProject', function() {})
            importModule('openFile', function () {
            });
        }
        onError: {
            showError(traceback)
            console.log('python error: ' + traceback);
        }
    }
    AddFileDialog {
        id: dialog
    }
    onStatusChanged: {
        if(status==PageStatus.Activating){
            lmodel.loadNew(projectPath+ "/"+projectName);
        }
    }

}

