import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel

Window {
    id: root
    width: 1560
    height: 720
    visible: true
    title: "BeMore"
    color: "#0f0f0f"

    // 0-carousel, 1-music, 2-images
    property int currentScreen: 0

    property bool gamesMode: false

    property string openedImageSource: ""

    //wallpaper
    AnimatedImage {
        id: backgroundImage
        anchors.fill: parent
        source: "icons/wallpapergif2.gif"
        z: -1
        fillMode: Image.PreserveAspectCrop
        opacity: 0.8
        playing: true 
    }

    //back button
    Button {
        id: backButton
        visible: root.currentScreen !== 0 && root.openedImageSource === ""
        z: 200 
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 25
        width: 70
        height: 70
        
        onClicked: {
            root.currentScreen = 0
            root.gamesMode = false
            carousel.forceActiveFocus()
        }
        
        background: null
        contentItem: Image {
            source: "icons/back.svg"
            fillMode: Image.PreserveAspectFit
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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 80; height: 80
            Keys.onSpacePressed: clicked()
            KeyNavigation.left: backButton.visible ? backButton : null
            KeyNavigation.right: powerButton 
            
            Keys.onDownPressed: {
                if (root.currentScreen === 0) {
                    if (root.gamesMode) gamesCarousel.forceActiveFocus()
                    else carousel.forceActiveFocus()
                }
                else if (root.currentScreen === 1) musicList.forceActiveFocus()
                else if (root.currentScreen === 2) imageGrid.forceActiveFocus()
            }

            contentItem: Image {
                source: "icons/mode.svg"
                fillMode: Image.PreserveAspectFit
                opacity: modeButton.activeFocus ? 1.0 : 0.4
            }
            background: null
        }

        Button {
            id: powerButton
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.verticalCenter: parent.verticalCenter
            width: 55; height: 55
            onClicked: Qt.quit()
            contentItem: Image {
                source: "icons/poweron.svg"
                fillMode: Image.PreserveAspectFit
                opacity: powerButton.activeFocus ? 1.0 : 0.4
            }
            background: null
        }
    }

    //main carousel
    PathView {
        id: carousel
        anchors.fill: parent
        visible: root.currentScreen === 0

        enabled: visible && root.openedImageSource === "" && !root.gamesMode
        focus: true 
        Component.onCompleted: carousel.forceActiveFocus()

        model: ListModel {
            ListElement { title: "MUSIC"; icon: "icons/music.svg" }
            ListElement { title: "IMAGES"; icon: "icons/camera.svg" }
            ListElement { title: "GAMES"; icon: "icons/controller.svg" }
            ListElement { title: "SETTINGS"; icon: "icons/sprocket.svg" }
        }

        Keys.onUpPressed: modeButton.forceActiveFocus()
        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()
        
        function selectItem() {
            if (currentIndex === 0) { root.currentScreen = 1; musicList.forceActiveFocus() }
            else if (currentIndex === 1) { root.currentScreen = 2; imageGrid.forceActiveFocus() }
            else if (currentIndex === 2) { root.gamesMode = true; gamesCarousel.forceActiveFocus() }
        }

        Keys.onReturnPressed: selectItem()
        Keys.onSpacePressed: selectItem()

        pathItemCount: 3
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange
        snapMode: PathView.SnapToItem

        path: Path {
            startX: 0; startY: root.height * 0.50
            PathLine { x: root.width; y: root.height * 0.50 }
        }

        delegate: Item {
            width: 100; height: 100
            readonly property bool isCurrent: PathView.isCurrentItem

            opacity: (isCurrent && carousel.activeFocus) ? 1.0 : (isCurrent ? 0.4 : 0.3)
            
            scale: isCurrent ? 1.2 : 0.7
            z: isCurrent ? 10 : 1

            Image { 
                anchors.centerIn: parent
                source: model.icon
                width: 100; height: 100; fillMode: Image.PreserveAspectFit 
            }

            Behavior on opacity { NumberAnimation { duration: 250 } }
            Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
        }
    }

    //game carousel
    PathView {
        id: gamesCarousel
        width: parent.width
        height: 250
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        visible: root.gamesMode && root.currentScreen === 0
        focus: visible
        clip: true

        model: FolderListModel {
            folder: "file:///home/kotel/Games"
            nameFilters: ["*.jpg", "*.png", "*.jpeg"]
            showDirs: false
        }

        Keys.onUpPressed: {
            root.gamesMode = false
            carousel.forceActiveFocus()
        }
        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()

        pathItemCount: 5
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange
        snapMode: PathView.SnapToItem

        path: Path {
            startX: root.width * 0.15; startY: 150
            PathLine { x: root.width * 0.85; y: 150 }
        }

        delegate: Item {
            width: 150; height: 150
            readonly property bool isCurrent: PathView.isCurrentItem
            z: isCurrent ? 10 : 1
            
            Rectangle {
                anchors.fill: parent
                anchors.margins: 10
                color: "transparent"
                border.color: "transparent"
                border.width: 3
                
                Image {
                    anchors.fill: parent
                    anchors.margins: 5
                    source: fileURL
                    fillMode: Image.PreserveAspectCrop
                }
                
                opacity: isCurrent ? 1.0 : 0.3
                scale: isCurrent ? 1.1 : 0.7
                Behavior on scale { NumberAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
    }

    //music list
    ListView {
        id: musicList
        width: parent.width; height: 500; anchors.centerIn: parent
        visible: root.currentScreen === 1
        clip: true; focus: true
        preferredHighlightBegin: height * 0.45; preferredHighlightEnd: height * 0.5
        highlightRangeMode: ListView.ApplyRange; snapMode: ListView.SnapToItem
        
        Keys.onUpPressed: (event) => { if (currentIndex === 0) modeButton.forceActiveFocus(); else event.accepted = false; }
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
                text: fileName; color: "#cac5d9"
                font.pixelSize: (parent.ListView.isCurrentItem && musicList.activeFocus) ? 32 : 20
                font.bold: (parent.ListView.isCurrentItem && musicList.activeFocus)
                opacity: (parent.ListView.isCurrentItem && musicList.activeFocus) ? 1.0 : 0.3
            }
        }
    }

    //image grid
    GridView {
        id: imageGrid
        anchors.fill: parent
        anchors.topMargin: 135; anchors.leftMargin: 200; anchors.rightMargin: 50; anchors.bottomMargin: 100
        visible: root.currentScreen === 2
        cellWidth: 240; cellHeight: 240; clip: true; focus: true
        
        readonly property int columns: Math.floor(width / cellWidth)
        Keys.onUpPressed: (event) => { if (currentIndex < columns) modeButton.forceActiveFocus(); else event.accepted = false; }
        Keys.onLeftPressed: (event) => { if (currentIndex % columns === 0) backButton.forceActiveFocus(); else event.accepted = false; }
        Keys.onEscapePressed: { root.currentScreen = 0; carousel.forceActiveFocus() }

        model: FolderListModel {
            folder: "file:///home/kotel/Pictures"
            nameFilters: ["*.jpg", "*.JPG", "*.png", "*.PNG", "*.jpeg", "*.JPEG"]; showDirs: false
        }
        
        delegate: Item {
            width: 220; height: 220
            Keys.onSpacePressed: root.openedImageSource = fileURL
            Rectangle {
                anchors.fill: parent; color: "transparent"
                border.color: "#cac5d9"; border.width: (parent.GridView.isCurrentItem && imageGrid.activeFocus) ? 2 : 0
                Image { anchors.fill: parent; anchors.margins: 5; source: fileURL; fillMode: Image.PreserveAspectCrop; autoTransform: true }
            }
        }
    }

    //enlarged image
    Item {
        id: lightbox
        anchors.fill: parent; visible: root.openedImageSource !== ""; z: 1000; focus: visible 
        Rectangle { anchors.fill: parent; color: "black"; opacity: 0.7 }
        Image {
            anchors.centerIn: parent
            width: parent.width * 0.9; height: parent.height * 0.9
            source: root.openedImageSource; fillMode: Image.PreserveAspectFit; autoTransform: true
            scale: lightbox.visible ? 1.0 : 0.5
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        }
        Keys.onSpacePressed: root.openedImageSource = ""
        Keys.onEscapePressed: root.openedImageSource = ""
        onVisibleChanged: if (!visible) imageGrid.forceActiveFocus()
    }
}