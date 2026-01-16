import QtQuick
import QtQuick.Controls

Window {
    width: 1280
    height: 720
    visible: true
    title: "Console Interface Prototype"
    color: "#0f0f0f"

    ListModel {
        id: consoleModel
        ListElement { title: "MUZYKA"; icon: "icons/kitty1.jpg"; bgColor: "#ffb7cf" }
        ListElement { title: "ZDJĘCIA"; icon: "icons/kitty2.jpg"; bgColor: "#acffaf" }
        //ListElement { title: "PLIKI"; icon: "icons/kitty3.png"; bgColor: "#aad9ff" }
        ListElement { title: "GRY"; icon: "icons/kitty4.jpg"; bgColor: "#ffc368" }
        ListElement { title: "SYSTEM"; icon: "icons/kitty5.jpg"; bgColor: "#adadad" }
        ListElement { title: "DESKTOP MODE"; icon: "icons/kitty3.jpg"; bgColor: "#f3caff"}
    }

    PathView {
        id: carousel
        anchors.fill: parent
        model: consoleModel
        focus: true

        readonly property real verticalPosition: parent.height * 0.55 

        readonly property real sidePadding: parent.width * 0.4

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange
        
        pathItemCount: 5 
        
        Keys.onRightPressed: incrementCurrentIndex()
        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onReturnPressed: console.log("Wybrano: " + model.get(currentIndex).title)

        path: Path {
            startX: -carousel.sidePadding
            startY: carousel.verticalPosition
            
            PathLine { 
                x: carousel.width + carousel.sidePadding
                y: carousel.verticalPosition 
            }
        }

        delegate: Item {
            width: 250
            height: 350
            
            readonly property bool isCurrent: PathView.isCurrentItem
            z: isCurrent ? 10 : 1

            Rectangle {
                anchors.centerIn: parent 
                width: parent.width
                height: parent.height
                color: model.bgColor
                radius: 10
                
                scale: isCurrent ? 1.2 : 0.8
                opacity: isCurrent ? 1.0 : 0.4
                
                //border.width: isCurrent ? 6 : 0
                //border.color: "white"

                Column {
                    anchors.centerIn: parent
                    spacing: 20

                    Image {
                        id: iconImg
                        source: model.icon
    

                        width: 200
                        height: 200

                        fillMode: Image.PreserveAspectFit
                        anchors.horizontalCenter: parent.horizontalCenter
    
                        sourceSize.width: 180
                        sourceSize.height: 180

                        smooth: true
                        antialiasing: true
                    }

                    Text { 
                        text: model.title
                        color: "white"
                        font.pixelSize: 24
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter 
                    }
                }

                Behavior on scale { NumberAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on border.width { NumberAnimation { duration: 100 } }
            }
        }
    }
}