import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

SilicaListView {
    id:listView

    property alias listmodel: listmodel

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
