import QtQuick 2.2
import Sailfish.Silica 1.0

Flipable {
    id: flipable
    width: parent.width
    height: pgHead.height
    property bool flipped: false
    property int foundStart
    property int foundEnd
    property int foundMatches: -1
    property alias searchField: searchField
    property bool replaceFieldClosed
    signal folderOpen(string newPath)

    function searchActive(){
        if (!flipable.flipped){
            flipable.flipped = true
        }
        searchField.forceActiveFocus()
    }

    function search(text, position, direction) {
        var reg = new RegExp(text, "ig")
        text= text//.toLowerCase()
        var myText = myeditor.text//.toLowerCase()
        var match = myText.match(reg)
        if(highlight) documentHandler.setDictionary(fileType);
        if(highlight) documentHandler.searchHighlight(text)
        if(match){
            foundMatches=match.length
            if(direction=="back"){
                myeditor.cursorPosition = myText.lastIndexOf(match[match.length-1], position)
                if(myText.lastIndexOf(match[match.length-1], position) != -1){
                    myeditor.select(myeditor.cursorPosition,myeditor.cursorPosition+text.length)
                    flipable.foundEnd = myeditor.cursorPosition
                    flipable.foundStart = myeditor.cursorPosition-text.length
                }
            }else{
                myeditor.cursorPosition = myText.indexOf(match[0],position)
                if (myText.indexOf(match[0],position)!=-1){
                    myeditor.select(myeditor.cursorPosition,myeditor.cursorPosition+text.length)
                    flipable.foundEnd = myeditor.cursorPosition
                    flipable.foundStart = myeditor.cursorPosition-text.length
                }
            }
            f.time=3
            myeditor.forceActiveFocus()
        }else{
            foundMatches=0
            searchField.errorHighlight = true
            flipable.foundStart = -1
            flipable.foundEnd = -1
        }
        replaceFieldClosed=false
    }
    function openEditor(chooserPath, currentPage){
        pageStack.pop(currentPage,{fullFilePath: chooserPath})
        folderOpen(chooserPath)

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
        _titleItem.color: rootMode ? reverseColor(Theme.highlightColor) :Theme.highlightColor
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
        //anchors.horizontalCenter: parent.horizontalCenter
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
                    width: (activeFocus || text.length>0 || replaceField.focus) ? pgHead.width -previous.width*3: implicitWidth*1.5
                    placeholderText: qsTr("Search")
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked:{
                        flipable.search(text,myeditor.cursorPosition,"forward");
                        searched=true
                    }
                    onActiveFocusChanged: {
                        if(activeFocus && !replaceFieldClosed) {
                            replaceBar.height=pgHead.height
                        }
                        else if (!activeFocus && text.length<1 && replaceBar.height>1 && !replaceField.activeFocus) {
                            replaceBar.height=0
                            flipable.foundStart = -1
                            flipable.foundEnd = -1
                        }
                    }

                    onTextChanged: {
                        if(shortcutUsed){
                            shortcutUsed=false
                            if(searchField.text[searchField.cursorPosition - 1] === "f"|| searchField.text[searchField.cursorPosition - 1] === "F"){
                                searchField._editor.remove(searchField.cursorPosition - 1, searchField.cursorPosition)
                            }
                        }
                        if(text==""){
                            if(highlight) documentHandler.setDictionary(fileType)
                        }
                        if(foundMatches>-1) foundMatches=-1
                        errorHighlight = false
                        searched = false
                        flipable.foundStart = -1
                        flipable.foundEnd = -1
                    }
                }

                IconButton {
                    id:previous
                    icon.source: "image://theme/icon-m-previous"
                    enabled: searched
                    onClicked:{
                        flipable.search(searchField.text,myeditor.cursorPosition-searchField.text.length-1,"back");
                    }
                    visible:searchField.activeFocus || searchField.text.length>0 || replaceField.focus
                }
                IconButton {
                    id:searchBtn
                    icon.source: "image://theme/icon-m-search"
                    enabled: searchField.text.length>0
                    onClicked:{
                        flipable.search(searchField.text,myeditor.cursorPosition-(searchField.text.length-1),"forward");
                         searched=true
                    }
                    visible:searchField.activeFocus || searchField.text.length>0 || replaceField.focus
                    Label {
                        id:searchMatches
                        color: foundMatches > 0 ? Theme.primaryColor : "#ff4d4d"
                        text: foundMatches > -1 ? foundMatches : ""
                        x: parent.width/2-Theme.paddingMedium
                        y:parent.height/2-Theme.paddingLarge
                        z:10
                    }
                }
                IconButton {
                    id:next
                    icon.source: "image://theme/icon-m-next"
                    enabled: searched
                    onClicked:{
                        flipable.search(searchField.text,myeditor.cursorPosition-(searchField.text.length-1),"forward");
                    }
                    visible:searchField.activeFocus || searchField.text.length>0 || replaceField.focus
                }
                IconButton {
                    icon.source: "image://theme/icon-m-rotate-left"
                    enabled: myeditor._editor.canUndo
                    onClicked: myeditor._editor.undo()
                    visible:!searchField.activeFocus && searchField.text.length<=0 && !replaceField.focus
                }
                IconButton {
                    icon.source: "image://theme/icon-m-rotate-right"
                    enabled: myeditor._editor.canRedo
                    onClicked: myeditor._editor.redo()
                    visible:!searchField.activeFocus && searchField.text.length<=0 && !replaceField.focus
                }
                IconButton {
                    icon.source: untitled?"image://ownIcons/icon-m-save-as":"image://ownIcons/icon-m-save"
                    enabled: textChangedSave
                    visible:!searchField.activeFocus && searchField.text.length<=0 && !replaceField.focus
                    onClicked: {
                        if(untitled){
                            pageStack.push(dialog, {callback: saveAsNewFile,path:previousPath, showFolderList:true, noName:fileTitle})
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
                    visible:!searchField.activeFocus && searchField.text.length<=0 && !replaceField.focus
                    enabled: !drawer.opened && !textChangedSave
                    onClicked:{
                        if(systemFM) {
                            pageStack.push(Qt.resolvedUrl("../pages/FileManagerPage.qml"),{callback:flipable.openEditor,path:projectName?projectPath+"/"+projectName : homePath, currentPage: pageStack.currentPage})
                        } else {
                            lmodel.loadNew(previousPath)
                            drawer.open = true
                        }
                    }

                }
                IconButton {
                    icon.source: "image://theme/icon-m-flip"
                    visible: !inSplitView /*&& Screen.sizeCategory === Screen.Large*/ && !searchField.activeFocus && searchField.text.length<=0 && !replaceField.focus
                    enabled: visible && !textChangedSave
                    onClicked:editorMode ? pageStack.push(Qt.resolvedUrl("../pages/SplitPage.qml"),{fullFilePath: fullFilePath},PageStackAction.Immediate) : pageStack.replace(Qt.resolvedUrl("../pages/SplitPage.qml"),{fullFilePath: fullFilePath},PageStackAction.Immediate)
                }
                IconButton {
                    icon.source: "image://theme/icon-m-developer-mode"
                    visible: !searchField.activeFocus && searchField.text.length<=0 && !inSplitView && !replaceField.focus
                    enabled: visible
                    onClicked: {
                        pageStack.pushAttached(Qt.resolvedUrl("../pages/SettingsPage.qml"))
                        pageStack.navigateForward()
                    }
                }
                IconButton {
                    icon.source: "image://theme/icon-m-page-up"
                    visible:!searchField.activeFocus && searchField.text.length<=0 && !replaceField.focus
                    onClicked:{
                        flipable.flipped = false
                    }
                }
            }
        }
    }
}
