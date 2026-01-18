import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel

Window {
    id: root
    width: 1280
    height: 720
    visible: true
    title: "BeMore"
    color: "#0f0f0f"

    //0-carousel/home, 1-music, 2-images
    property int currentScreen: 0

    //enlarged image, empty=not enlarged
    property string openedImageSource: ""

    //wallpaper
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "icons/wallpaper.jpg"
        z: -1
        fillMode: Image.PreserveAspectCrop
        opacity: 0.3
    }

    //back/return button (from pictures and music)
    Button {
        id: backButton
        visible: root.currentScreen !== 0 && root.openedImageSource === ""
        z: 200 
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 25
        width: 70
        height: 70
        
        Keys.onSpacePressed: clicked()
        onClicked: {
            root.currentScreen = 0
            carousel.forceActiveFocus()
        }
        
        KeyNavigation.up: modeButton
        Keys.onRightPressed: {
            if (root.currentScreen === 1) musicList.forceActiveFocus()
            else if (root.currentScreen === 2) imageGrid.forceActiveFocus()
        }

        background: null
        contentItem: Image {
            source: "icons/back.svg"
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 50
            sourceSize.height: 50
            opacity: backButton.activeFocus ? 1.0 : 0.4 
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    //top bar
    Item {
        id: topBar
        anchors.top: parent.top
        width: parent.width
        height: 100
        z: 100
        enabled: root.openedImageSource === ""

        Button {
            id: modeButton
            text: "CONSOLE MODE"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 220
            height: 55
            
            Keys.onSpacePressed: clicked()
            onClicked: text = (text === "CONSOLE MODE") ? "DESKTOP MODE" : "CONSOLE MODE"

            KeyNavigation.left: backButton.visible ? backButton : null
            KeyNavigation.right: systemButton 
            
            Keys.onDownPressed: {
                if (root.currentScreen === 0) carousel.forceActiveFocus()
                else if (root.currentScreen === 1) musicList.forceActiveFocus()
                else if (root.currentScreen === 2) imageGrid.forceActiveFocus()
            }

            background: Rectangle {
                color: modeButton.activeFocus ? "#444" : "#222"
                radius: 28
                border.color: modeButton.activeFocus ? "white" : "#444"
                border.width: 2
            }
            contentItem: Text { 
                text: modeButton.text; color: "white"; font.bold: true
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter 
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            Button {
                id: systemButton
                width: 55; height: 55
                Keys.onSpacePressed: clicked()
                KeyNavigation.left: modeButton; KeyNavigation.right: powerButton
                Keys.onDownPressed: {
                    if (root.currentScreen === 0) carousel.forceActiveFocus()
                    else if (root.currentScreen === 1) musicList.forceActiveFocus()
                    else if (root.currentScreen === 2) imageGrid.forceActiveFocus()
                }
                contentItem: Image {
                    source: "icons/sprocket.svg"
                    fillMode: Image.PreserveAspectFit
                    opacity: systemButton.activeFocus ? 1.0 : 0.4
                }
                background: null
            }

            Button {
                id: powerButton
                width: 55; height: 55
                Keys.onSpacePressed: clicked()
                onClicked: Qt.quit()
                KeyNavigation.left: systemButton
                Keys.onDownPressed: {
                    if (root.currentScreen === 0) carousel.forceActiveFocus()
                    else if (root.currentScreen === 1) musicList.forceActiveFocus()
                    else if (root.currentScreen === 2) imageGrid.forceActiveFocus()
                }
                contentItem: Image {
                    source: "icons/poweron.svg"
                    fillMode: Image.PreserveAspectFit
                    opacity: powerButton.activeFocus ? 1.0 : 0.4
                }
                background: null
            }
        }
    }

    //carousel
    PathView {
        id: carousel
        anchors.fill: parent
        visible: root.currentScreen === 0
        enabled: visible && root.openedImageSource === ""
        focus: true 
        Component.onCompleted: carousel.forceActiveFocus()

        model: ListModel {
            ListElement { title: "MUSIC"; icon: "icons/music.svg" }
            ListElement { title: "IMAGES"; icon: "icons/camera.svg" }
            ListElement { title: "GAMES"; icon: "icons/controller.svg" }
        }

        Keys.onUpPressed: modeButton.forceActiveFocus()
        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()
        
        function selectItem() {
            if (currentIndex === 0) { root.currentScreen = 1; musicList.forceActiveFocus() }
            else if (currentIndex === 1) { root.currentScreen = 2; imageGrid.forceActiveFocus() }
        }

        Keys.onReturnPressed: selectItem()
        Keys.onSpacePressed: selectItem()

        pathItemCount: 3
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange
        snapMode: PathView.SnapToItem

        path: Path {
            startX: 0; startY: root.height * 0.55
            PathLine { x: root.width; y: root.height * 0.55 }
        }

        delegate: Item {
            width: 300; height: 300
            readonly property bool isCurrent: PathView.isCurrentItem
            opacity: (isCurrent && carousel.activeFocus) ? 1.0 : 0.3
            scale: (isCurrent && carousel.activeFocus) ? 1.2 : 0.7
            z: isCurrent ? 10 : 1

            Image { 
                anchors.centerIn: parent
                source: model.icon
                width: 250; height: 250; fillMode: Image.PreserveAspectFit 
            }

            Behavior on opacity { NumberAnimation { duration: 250 } }
            Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
        }
    }

    //music list
    ListView {
        id: musicList
        width: parent.width
        
        height: 700 
        
        anchors.centerIn: parent
        
        visible: root.currentScreen === 1
        enabled: visible && root.openedImageSource === ""
        
        clip: true
        focus: true
        
        preferredHighlightBegin: height * 0.45
        preferredHighlightEnd: height * 0.5
        highlightRangeMode: ListView.ApplyRange
        snapMode: ListView.SnapToItem
        highlightMoveDuration: 300

        Keys.onUpPressed: (event) => {
            if (currentIndex === 0) modeButton.forceActiveFocus();
            else event.accepted = false; 
        }
        
        Keys.onLeftPressed: backButton.forceActiveFocus()
        Keys.onEscapePressed: { root.currentScreen = 0; carousel.forceActiveFocus() }

        model: FolderListModel {
            folder: "file:///home/kotel/Music"
            nameFilters: ["*.mp3", "*.MP3", "*.wav", "*.WAV"]; showDirs: false
        }

        delegate: Item {
            width: musicList.width; height: 80
            
            Text {
                anchors.centerIn: parent
                text: fileName; color: "white"
                font.pixelSize: (parent.ListView.isCurrentItem && musicList.activeFocus) ? 32 : 20
                font.bold: (parent.ListView.isCurrentItem && musicList.activeFocus)
                opacity: (parent.ListView.isCurrentItem && musicList.activeFocus) ? 1.0 : 0.3
                
                Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }

    //picture gallery
    GridView {
        id: imageGrid
        anchors.fill: parent
        anchors.topMargin: 150; anchors.leftMargin: 120; anchors.rightMargin: 50
        visible: root.currentScreen === 2
        enabled: visible && root.openedImageSource === ""
        cellWidth: 240; cellHeight: 240; clip: true; focus: true
        
        readonly property int columns: Math.floor(width / cellWidth)

        Keys.onUpPressed: (event) => {
            if (currentIndex < columns) modeButton.forceActiveFocus();
            else event.accepted = false; 
        }

        Keys.onLeftPressed: (event) => {
            if (currentIndex % columns === 0) backButton.forceActiveFocus();
            else event.accepted = false; 
        }

        Keys.onEscapePressed: { root.currentScreen = 0; carousel.forceActiveFocus() }

        model: FolderListModel {
            folder: "file:///home/kotel/Pictures"
            nameFilters: ["*.jpg", "*.JPG", "*.png", "*.PNG", "*.jpeg", "*.JPEG"]; showDirs: false
        }
        
        delegate: Item {
            width: 220; height: 220
            Keys.onSpacePressed: root.openedImageSource = fileURL
            Keys.onReturnPressed: root.openedImageSource = fileURL

            //image container
            Rectangle {
                anchors.fill: parent; color: "transparent"
                
                //border if focused
                border.color: "white"
                border.width: (parent.GridView.isCurrentItem && imageGrid.activeFocus) ? 2 : 0
                Behavior on border.width { NumberAnimation { duration: 150 } }

                Image { 
                    anchors.fill: parent; anchors.margins: 5
                    source: fileURL; fillMode: Image.PreserveAspectCrop 
                    autoTransform: true
                }
            }
        }
    }

    //picture enlargment
    Item {
        id: lightbox
        anchors.fill: parent
        visible: root.openedImageSource !== ""
        z: 1000
        focus: visible 

        Rectangle {
            anchors.fill: parent; color: "black"; opacity: 0.7; visible: lightbox.visible
        }

        Image {
            anchors.centerIn: parent
            width: parent.width * 0.9; height: parent.height * 0.9
            source: root.openedImageSource; fillMode: Image.PreserveAspectFit; autoTransform: true
            scale: lightbox.visible ? 1.0 : 0.5
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        }

        Keys.onSpacePressed: root.openedImageSource = ""
        Keys.onEscapePressed: root.openedImageSource = ""
        Keys.onReturnPressed: root.openedImageSource = ""
        onVisibleChanged: if (!visible) imageGrid.forceActiveFocus()
    }
}