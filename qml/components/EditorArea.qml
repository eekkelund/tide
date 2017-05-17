import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import harbour.tide.editor.documenthandler 1.0
import harbour.tide.editor.keyboardshortcut 1.0

TextArea {
    id: myeditor

    property alias documentHandler: documentHandler

    property string previousText: ""
    property bool textChangedManually: false
    property int currentLine: myeditor.positionToRectangle(cursorPosition).y/myeditor.positionToRectangle(cursorPosition).height +1
    property int lineCount: _editor.lineCount
    property bool shortcutUsed
    property string textBeforeCursor
    property var openBrackets
    property var closeBrackets
    property int openBracketsCount
    property int closeBracketsCount
    property int indentDepth
    property string indentStr

    //width: background.width -parent.x
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
            textChangedSave =  (untitled ? myeditor.text.length > 0: true)
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
