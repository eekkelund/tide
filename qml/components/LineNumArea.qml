import QtQuick 2.2
import Sailfish.Silica 1.0

Rectangle {
    id: linenum
    width: lineNums ? linecolumn.width *1.2 : Theme.paddingSmall
    color: "transparent"
    visible: lineNums
    property var lineNumberList
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
