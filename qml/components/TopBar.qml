import QtQuick 2.2
import Sailfish.Silica 1.0


Flipable {
    id: flipable
    width: parent.width
    height: pgHead.height

    property bool flipped: false

    function searchActive(){
        if (!flipable.flipped){
            flipable.flipped = true
        }
        searchField.forceActiveFocus()
    }

    function search(text, position, direction) {
        //var reg = new RegExp(text, "ig")
        text= text.toLowerCase()
        var myText = myeditor.text.toLowerCase()
        var match = myText.match(text)
        documentHandler.searchHighlight(text)
        if(match){
            if(direction=="back"){
                myeditor.cursorPosition = myText.lastIndexOf(match[match.length-1], position)
                if(myText.lastIndexOf(match[match.length-1], position) != -1) myeditor.select(myeditor.cursorPosition,myeditor.cursorPosition+text.length)
            }else{
                myeditor.cursorPosition = myText.indexOf(match[0],position)
                if (myText.indexOf(match[0],position)!=-1) myeditor.select(myeditor.cursorPosition,myeditor.cursorPosition+text.length)
            }
            f.time=3
            myeditor.forceActiveFocus()
        }else{
            searchField.errorHighlight = true
        }
    }

    transform: Rotation {
        id: rotation
        origin.x: flipable.width/2
        origin.y: flipable.height/2
        axis.x: -1; axis.y: 0; axis.z: 0     // set axis.y to 1 to rotate around y-axis
        angle: 0    // the default angle
    }

    states: State {
        name: "back"
        PropertyChanges { target: rotation; angle: 180 }
        when: flipable.flipped
    }

    transitions: Transition {
        NumberAnimation { target: rotation; property: "angle"; duration: 300 }
    }

    front:PageHeader  {
        id:pgHead
        width: parent.width
        anchors.right:parent.right
        title: fileTitle
        visible: !flipable.flipped
        enabled: visible
        MouseArea {
            enabled: !flipable.flipped
            onClicked: {
                flipable.flipped = !flipable.flipped
            }
            anchors.fill: parent
        }
    }

    back: Item{
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: parent.height
        clip:true
        Flickable {
            id: topBarFlick
            anchors.fill: parent
            contentWidth: menu.width < parent.width ? parent.width:menu.width
            contentHeight: menu.height
            contentX: topBarFlick.contentWidth/2-parent.width/2
            Flow {
                id:menu
                height: pgHead.height
                spacing: Screen.sizeCategory === Screen.Large? Theme.paddingLarge : Theme.paddingSmall
                anchors.horizontalCenter: parent.horizontalCenter

                SearchField{
                    id:searchField
                    width: (activeFocus || text.length>0) ? pgHead.width -previous.width*2: implicitWidth*1.5
                    placeholderText: qsTr("Search")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked:{
                        flipable.search(text,myeditor.cursorPosition,"forward");
                        searched=true
                    }
                    onTextChanged: {
                        if(shortcutUsed){
                            shortcutUsed=false
                            if(searchField.text[searchField.cursorPosition - 1] === "f"|| searchField.text[searchField.cursorPosition - 1] === "F"){
                                searchField._editor.remove(searchField.cursorPosition - 1, searchField.cursorPosition)
                            }
                        }
                        if(text==""){
                          documentHandler.setDictionary(fileType)
                        }
                        errorHighlight = false
                        searched = false
                    }
                }

                IconButton {
                    id:previous
                    icon.source: "image://theme/icon-m-previous"
                    enabled: searched
                    onClicked:{
                        flipable.search(searchField.text,myeditor.cursorPosition-searchField.text.length-1,"back");
                    }
                    visible:searchField.activeFocus || searchField.text.length>0
                }
                IconButton {
                    id:next
                    icon.source: "image://theme/icon-m-next"
                    enabled: searched
                    onClicked:{
                        flipable.search(searchField.text,myeditor.cursorPosition-(searchField.text.length-1),"forward");
                    }
                    visible:searchField.activeFocus || searchField.text.length>0
                }
                IconButton {
                    icon.source: "image://theme/icon-m-rotate-left"
                    enabled: myeditor._editor.canUndo
                    onClicked: myeditor._editor.undo()
                    visible:!searchField.activeFocus && searchField.text.length<=0
                }
                IconButton {
                    icon.source: "image://theme/icon-m-rotate-right"
                    enabled: myeditor._editor.canRedo
                    onClicked: myeditor._editor.redo()
                    visible:!searchField.activeFocus && searchField.text.length<=0
                }
                IconButton {
                    icon.source: untitled?"image://ownIcons/icon-m-save-as":"image://ownIcons/icon-m-save"
                    enabled: textChangedSave
                    visible:!searchField.activeFocus && searchField.text.length<=0
                    onClicked: {
                        if(untitled){
                            pageStack.push(dialog, {callback: saveAsNewFile,path:previousPath, showFolderList:true, noName:fileTitle/*, replacePage:pageStack.currentPage*/})
                        }else {
                            py.call('editFile.savings', [fullFilePath,myeditor.text], function(result) {
                                fileTitle=result
                            });
                        }
                        textChangedSave=false;
                    }
                }
                IconButton {
                    icon.source: "image://theme/icon-m-folder"
                    visible:!searchField.activeFocus && searchField.text.length<=0
                    enabled: !drawer.opened && !textChangedSave
                    onClicked:{
                        console.log(previousPath)
                        lmodel.loadNew(previousPath)
                        drawer.open = true
                    }
                }
                IconButton {
                    icon.source: "image://theme/icon-m-flip"
                    visible: !inSplitView /*&& Screen.sizeCategory === Screen.Large*/ && !searchField.activeFocus && searchField.text.length<=0
                    enabled: visible && !textChangedSave
                    onClicked:editorMode ? pageStack.push(Qt.resolvedUrl("../pages/SplitPage.qml"),{fullFilePath: fullFilePath},PageStackAction.Immediate) : pageStack.replace(Qt.resolvedUrl("../pages/SplitPage.qml"),{fullFilePath: fullFilePath},PageStackAction.Immediate)
                }
                IconButton {
                    icon.source: "image://theme/icon-m-close"
                    visible:!searchField.activeFocus && searchField.text.length<=0
                    onClicked:{
                        flipable.flipped = false
                    }
                }
            }
        }
    }
}
