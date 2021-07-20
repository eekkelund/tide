/*
*  Thanks belongs to coderus+Jolla! https://github.com/CODeRUS/splashscreen-changer/blob/master/settings/SecondPage.qml
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
;import Nemo.FileManager 1.0
;import Sailfish.FileManager 1.0
import io.thp.pyotherside 1.3

Page {
    id: page
    allowedOrientations: Orientation.All

    property alias path: fileModel.path
    property string ext: ""
    property string title
    property bool showFormat
    signal formatClicked
    property Page currentPage
    property var callback

    function addNewFile(){
        dialog.acceptDestinationAction = PageStackAction.Replace
        dialog.accDest=Qt.resolvedUrl("EditorPage.qml")
        dialog.acceptDestination=Qt.resolvedUrl("EditorPage.qml")
        py.call('addFile.createFile', [dialog.fName,ext,dialog.path], function(fPath) {
            dialog.acceptDestinationInstance.fileTitle=dialog.fName+ext
            dialog.acceptDestinationInstance.fullFilePath=fPath
        });
    }

    backNavigation: !FileEngine.busy

    FileModel {
        id: fileModel
        directorySort: FileModel.SortDirectoriesBeforeFiles
        includeHiddenFiles: includeHidden
        path: rootMode ? "/" : homePath
        active: page.status === PageStatus.Active
      //  onError: {
      //      showError(traceback)
      //      console.log("###", fileName, error)
      //  }
    }
    SilicaListView {
        id: fileList

        opacity: FileEngine.busy ? 0.6 : 1.0
        Behavior on opacity { FadeAnimator {} }

        anchors.fill: parent
        PullDownMenu {
            MenuItem {
                enabled:rootMode
                visible:enabled
                text:fileModel.path=="/"? qsTr("Go /usr/share"):qsTr("Go to root")
                onClicked: fileModel.path=="/"?fileModel.path="/usr/share":fileModel.path="/"
            }
            MenuItem {
                enabled:!rootMode
                visible:enabled
                text:fileModel.path=="/media/sdcard/"? qsTr("Go to home"):qsTr("Go SD Card")
                onClicked: fileModel.path=="/media/sdcard/"?fileModel.path=homePath:fileModel.path="/media/sdcard/"
            }

            MenuItem {
                text:qsTr("Add file")
                onClicked:{
                    pageStack.push(dialog, {callback:page.addNewFile, path:path, showFolderList:false,accDest:"FileManagerPage.qml"})
                }
            }
        }
        model: fileModel

        header: PageHeader {
            title: path == homePath && page.title.length > 0 ? page.title
                                                             : page.path.split("/").pop()
            _titleItem.color: rootMode ? reverseColor(Theme.highlightColor) :Theme.highlightColor
        }

        delegate: ListItem {
            id: fileItem

            enabled:{
                if (model.isDir) {
                    return true
                } else {
                    if (mimeType.indexOf("audio/") == 0 || mimeType.indexOf("video/") == 0 || mimeType.indexOf("image/") == 0) {
                        return false
                    } else if (fileModel.absolutePath.slice(-1) == "~") {
                        return false
                    }else if (mimeType.indexOf("text/") == 0) {
                        return true
                    }else if(mimeType.indexOf("application/") == 0){
                        switch(mimeType) {
                        case "application/pdf":
                        case "application/vnd.oasis.opendocument.spreadsheet":
                        case "application/x-kspread":
                        case "application/vnd.ms-excel":
                        case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
                        case "application/vnd.openxmlformats-officedocument.spreadsheetml.template":
                        case "application/vnd.oasis.opendocument.presentation":
                        case "application/vnd.oasis.opendocument.presentation-template":
                        case "application/x-kpresenter":
                        case "application/vnd.ms-powerpoint":
                        case "application/vnd.openxmlformats-officedocument.presentationml.presentation":
                        case "application/vnd.openxmlformats-officedocument.presentationml.template":
                        case "application/vnd.oasis.opendocument.text-master":
                        case "application/vnd.oasis.opendocument.text":
                        case "application/vnd.oasis.opendocument.text-template":
                        case "application/msword":
                        case "application/x-mswrite":
                        case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
                        case "application/vnd.openxmlformats-officedocument.wordprocessingml.template":
                        case "application/vnd.ms-works":
                            return false
                        default:
                            return true
                        }
                    }
                    else return false
                }
            }

            width: ListView.view.width
            contentHeight:Theme.itemSizeMedium
            Row {
                anchors.fill: parent
                spacing: Theme.paddingLarge
                Rectangle {
                    width: height
                    height: parent.height
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    Image {
                        anchors.centerIn: parent
                        source: Theme.iconForMimeType(model.mimeType)
                    }
                }
                Column {
                    width: parent.width - parent.height - parent.spacing - Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: -Theme.paddingSmall
                    Label {
                        text: model.fileName
                        width: parent.width
                        font.pixelSize: Theme.fontSizeLarge
                        truncationMode: TruncationMode.Fade
                        color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    Label {
                        property string dateString: Format.formatDate(model.modified, Formatter.DateLong)
                        text: model.isDir ? dateString
                                            //: Shows size and modification date, e.g. "15.5MB, 02/03/2016"
                                            //% "%1, %2"
                                          : qsTrId("filemanager-la-file_details").arg(Format.formatFileSize(model.size)).arg(dateString)
                        width: parent.width
                        truncationMode: TruncationMode.Fade
                        font.pixelSize: Theme.fontSizeSmall
                        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    }
                }
            }

            onClicked: {
                if (model.isDir) {
                    pageStack.push(Qt.resolvedUrl("FileManagerPage.qml"),
                                   { path: fileModel.appendPath(model.fileName), homePath: page.homePath, callback: page.callback, currentPage: page.currentPage})
                }else if (!fileItem.enabled && fileModel.absolutePath.slice(-1) == "~"){
                    showError(qsTr("This is autosaved file, open the regular one"))
                }else if (!fileItem.enabled){
                    showError(qsTr("No support for this file type.."))
                }else {
                    var filePath = fileModel.path + "/" + model.fileName;
                    console.log("###", mimeType, filePath);
                    if (typeof callback == "function") {
                        callback(filePath, currentPage);
                    }
                }
            }
        }
        ViewPlaceholder {
            enabled: fileModel.count === 0
            //% "No files"
            text: qsTrId("filemanager-la-no_files")
        }
        VerticalScrollDecorator {}
    }
    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('./../python'));
            importModule('addFile', function() {});
        }
        onError: {
            showError(traceback)
            console.log('python error: ' + traceback);
        }
    }

    AddFileDialog {
        id: dialog
    }
}
