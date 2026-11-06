import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import QtMultimedia 5.15
import QtGamepad 1.15

Window {
    id: root
    width: 1560
    height: 720
    visible: true
    title: "BeMore"
    color: "#0f0f0f"

    property string musicFolderPath: "file:///home/proj560/Music"
    property string gamesFolderPath: "file:///home/proj560/Games"
    property string picturesFolderPath: "file:///home/proj560/Pictures"

    // 0-carousel, 1-music, 2-images
    property int currentScreen: 0

    property bool gamesMode: false

    property bool settingsMode: false

    property bool wallpaperSettingsMode: false

    property bool useAnimatedWallpaper: false

    property string openedImageSource: ""

    property string playingMusicSource: ""

    function isVideo(sourceUrl) {
        var urlStr = sourceUrl.toString().toLowerCase();
        return urlStr.endsWith(".mp4") || urlStr.endsWith(".mkv") || urlStr.endsWith(".webm") || urlStr.endsWith(".avi") || urlStr.endsWith(".mov");
    }

    // pad navigation
    function navigateLeft() {
        if (root.openedImageSource !== "") return;
        
        if (modeButton.activeFocus) {
            if (backButton.visible) backButton.forceActiveFocus();
            return;
        }
        if (powerButton.activeFocus) {
            modeButton.forceActiveFocus();
            return;
        }

        if (root.currentScreen === 0) {
            if (root.wallpaperSettingsMode) wallpaperSettingsCarousel.decrementCurrentIndex()
            else if (root.settingsMode) settingsCarousel.decrementCurrentIndex()
            else if (root.gamesMode) gamesCarousel.decrementCurrentIndex()
            else carousel.decrementCurrentIndex()
        } else if (root.currentScreen === 1) {
            backButton.forceActiveFocus()
        } else if (root.currentScreen === 2) {
            if (imageGrid.currentIndex % imageGrid.columns === 0) backButton.forceActiveFocus()
            else imageGrid.currentIndex = Math.max(0, imageGrid.currentIndex - 1)
        }
    }

    function navigateRight() {
        if (root.openedImageSource !== "") return;

        if (backButton.activeFocus) {
            if (root.currentScreen === 1) musicList.forceActiveFocus()
            else if (root.currentScreen === 2) imageGrid.forceActiveFocus()
            return;
        }
        if (modeButton.activeFocus) {
            powerButton.forceActiveFocus()
            return;
        }

        if (root.currentScreen === 0) {
            if (root.wallpaperSettingsMode) wallpaperSettingsCarousel.incrementCurrentIndex()
            else if (root.settingsMode) settingsCarousel.incrementCurrentIndex()
            else if (root.gamesMode) gamesCarousel.incrementCurrentIndex()
            else carousel.incrementCurrentIndex()
        } else if (root.currentScreen === 2) {
            imageGrid.currentIndex = Math.min(imageGrid.count - 1, imageGrid.currentIndex + 1)
        }
    }

    function navigateUp() {
        if (root.openedImageSource !== "") return;

        if (backButton.activeFocus) {
            modeButton.forceActiveFocus()
            return;
        }

        if (root.currentScreen === 0) {
            if (root.wallpaperSettingsMode) {
                root.wallpaperSettingsMode = false
                root.settingsMode = true
                settingsCarousel.forceActiveFocus()
            } else if (root.settingsMode) {
                root.settingsMode = false
                carousel.forceActiveFocus()
            } else if (root.gamesMode) {
                root.gamesMode = false
                carousel.forceActiveFocus()
            } else {
                modeButton.forceActiveFocus()
            }
        } else if (root.currentScreen === 1) {
            if (musicList.currentIndex > 0) musicList.currentIndex--
            else modeButton.forceActiveFocus()
        } else if (root.currentScreen === 2) {
            if (imageGrid.currentIndex >= imageGrid.columns) imageGrid.currentIndex -= imageGrid.columns
            else modeButton.forceActiveFocus()
        }
    }

    function navigateDown() {
        if (root.openedImageSource !== "") return;

        if (modeButton.activeFocus || powerButton.activeFocus || backButton.activeFocus) {
            if (root.currentScreen === 0) {
                if (root.gamesMode) gamesCarousel.forceActiveFocus()
                else if (root.settingsMode) settingsCarousel.forceActiveFocus()
                else if (root.wallpaperSettingsMode) wallpaperSettingsCarousel.forceActiveFocus()
                else carousel.forceActiveFocus()
            }
            else if (root.currentScreen === 1) musicList.forceActiveFocus()
            else if (root.currentScreen === 2) imageGrid.forceActiveFocus()
            return;
        }

        if (root.currentScreen === 1) {
            if (musicList.currentIndex < musicList.count - 1) musicList.currentIndex++
        } else if (root.currentScreen === 2) {
            if (imageGrid.currentIndex + imageGrid.columns < imageGrid.count) imageGrid.currentIndex += imageGrid.columns
        }
    }

    function triggerActionA() {
        if (root.openedImageSource !== "") {
            if (lightbox.isVid) {
                lightbox.togglePlayPause()
            } else {
            }
            return;
        }

        if (modeButton.activeFocus) {
            modeButton.clicked();
            return;
        }
        if (powerButton.activeFocus) {
            powerButton.clicked();
            return;
        }
        if (backButton.activeFocus) {
            backButton.clicked();
            return;
        }

        if (root.currentScreen === 0) {
            if (root.wallpaperSettingsMode) {
                root.useAnimatedWallpaper = wallpaperSettingsCarousel.model.get(wallpaperSettingsCarousel.currentIndex).isAnimated
            } else if (root.settingsMode) {
                if (settingsCarousel.currentIndex === 0) {
                    root.wallpaperSettingsMode = true
                    root.settingsMode = false
                    wallpaperSettingsCarousel.forceActiveFocus()
                }
            } else if (!root.gamesMode) {
                carousel.selectItem()
            }
        } else if (root.currentScreen === 1) {
            var musicItem = musicList.currentItem
            if (musicItem) {
                musicItem.toggleAudio()
            }
        } else if (root.currentScreen === 2) {
            if (imageGrid.currentItem) {
                root.openedImageSource = imageGrid.currentItem.currentImgSrc
            }
        }
    }

    function triggerActionB() {
        if (root.openedImageSource !== "") {
            root.openedImageSource = ""
        } else if (root.currentScreen !== 0) {
            root.currentScreen = 0
            root.gamesMode = false
            carousel.forceActiveFocus()
        } else if (root.wallpaperSettingsMode) {
            root.wallpaperSettingsMode = false
            root.settingsMode = true
            settingsCarousel.forceActiveFocus()
        } else if (root.settingsMode) {
            root.settingsMode = false
            carousel.forceActiveFocus()
        } else if (root.gamesMode) {
            root.gamesMode = false
            carousel.forceActiveFocus()
        }
    }

    // auto repeats for carousel
    Timer {
        id: repeatTimerX
        interval: 150
        repeat: true
        property int direction: 0
        onTriggered: direction === -1 ? root.navigateLeft() : root.navigateRight()
    }
    Timer {
        id: delayTimerX
        interval: 400
        repeat: false
        onTriggered: repeatTimerX.start()
    }

    Timer {
        id: repeatTimerY
        interval: 150
        repeat: true
        property int direction: 0
        onTriggered: direction === -1 ? root.navigateUp() : root.navigateDown()
    }
    Timer {
        id: delayTimerY
        interval: 400
        repeat: false
        onTriggered: repeatTimerY.start()
    }

    // pad connection and usage
    Connections {
        target: GamepadManager
        function onGamepadConnected(deviceId) {
            console.log("[QML Gamepad] Connected pad, ID:", deviceId)
            gamepad.deviceId = deviceId
        }
        function onGamepadDisconnected(deviceId) {
            console.log("[QML Gamepad] Disconnected pad, ID:", deviceId)
            if (gamepad.deviceId === deviceId) {
                gamepad.deviceId = -1
            }
        }
    }

    Gamepad {
        id: gamepad
        deviceId: 0

        Component.onCompleted: {
            if (GamepadManager.connectedGamepads.length > 0) {
                deviceId = GamepadManager.connectedGamepads[0]
            }
        }

        onDeviceIdChanged: {
        }

        onButtonAChanged: {
            if (buttonA) {
                root.triggerActionA()
            }
        }
        onButtonBChanged: {
            if (buttonB) {
                root.triggerActionB()
            }
        }

        onButtonLeftChanged: {
            if (buttonLeft) {
                root.navigateLeft()
                repeatTimerX.direction = -1
                delayTimerX.start()
            } else if (!buttonRight && repeatTimerX.direction === -1) {
                delayTimerX.stop(); repeatTimerX.stop()
            }
        }
        onButtonRightChanged: {
            if (buttonRight) {
                root.navigateRight()
                repeatTimerX.direction = 1
                delayTimerX.start()
            } else if (!buttonLeft && repeatTimerX.direction === 1) {
                delayTimerX.stop(); repeatTimerX.stop()
            }
        }

        // d-pad
        onButtonUpChanged: {
            if (buttonUp) {
                root.navigateUp()
                repeatTimerY.direction = -1
                delayTimerY.start()
            } else if (!buttonDown && repeatTimerY.direction === -1) {
                delayTimerY.stop(); repeatTimerY.stop()
            }
        }
        onButtonDownChanged: {
            if (buttonDown) {
                root.navigateDown()
                repeatTimerY.direction = 1
                delayTimerY.start()
            } else if (!buttonUp && repeatTimerY.direction === 1) {
                delayTimerY.stop(); repeatTimerY.stop()
            }
        }

        // left joystick
        property bool axisXHeld: false
        onAxisLeftXChanged: {
            if (axisLeftX < -0.55) {
                if (!axisXHeld) {
                    axisXHeld = true
                    root.navigateLeft()
                    repeatTimerX.direction = -1
                    delayTimerX.start()
                }
            } else if (axisLeftX > 0.55) {
                if (!axisXHeld) {
                    axisXHeld = true
                    root.navigateRight()
                    repeatTimerX.direction = 1
                    delayTimerX.start()
                }
            } else if (Math.abs(axisLeftX) < 0.25) {
                if (axisXHeld) {
                    axisXHeld = false
                    if (!buttonLeft && !buttonRight) {
                        delayTimerX.stop(); repeatTimerX.stop()
                    }
                }
            }
        }

        property bool axisYHeld: false
        onAxisLeftYChanged: {
            if (axisLeftY < -0.55) {
                if (!axisYHeld) {
                    axisYHeld = true
                    root.navigateUp()
                    repeatTimerY.direction = -1
                    delayTimerY.start()
                }
            } else if (axisLeftY > 0.55) {
                if (!axisYHeld) {
                    axisYHeld = true
                    root.navigateDown()
                    repeatTimerY.direction = 1
                    delayTimerY.start()
                }
            } else if (Math.abs(axisLeftY) < 0.25) {
                if (axisYHeld) {
                    axisYHeld = false
                    if (!buttonUp && !buttonDown) {
                        delayTimerY.stop(); repeatTimerY.stop()
                    }
                }
            }
        }
    }

    MediaPlayer {
        id: audioPlayer
        source: root.playingMusicSource

        onStatusChanged: {
            if (status === MediaPlayer.EndOfMedia) {
                root.playingMusicSource = ""
            }
        }
    }

    //wallpaper
    Item {
        id: backgroundContainer
        anchors.fill: parent
        z: -1

        Image {
            anchors.fill: parent
            source: "icons/wallpaper_static.jpg" 
            fillMode: Image.PreserveAspectCrop
            opacity: 0.8
            visible: !root.useAnimatedWallpaper 
        }

        AnimatedImage {
            anchors.fill: parent
            source: "icons/wallpapergif2.gif"
            fillMode: Image.PreserveAspectCrop
            opacity: 0.8
            playing: root.useAnimatedWallpaper
            visible: root.useAnimatedWallpaper
        }
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

        // music info (filename)
        Text {
            id: musicInfo
            anchors.left: musicInfoIcon.right
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            color: "#cac5d9"
            font.pixelSize: 20
            font.bold: true
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter

            text: root.playingMusicSource !== "" ? root.playingMusicSource.split('/').pop().split('.')[0] : ""
        }

        // music info (playing/paused)
        Image {
            id: musicInfoIcon
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.verticalCenter: parent.verticalCenter

            source: {
                if (audioPlayer.playbackState === MediaPlayer.PlayingState) {
                    return "icons/music.svg"
                } else {
                    return "icons/pause.svg"
                }
            }
            width: 30; height: 30
            fillMode: Image.PreserveAspectFit
            visible: root.playingMusicSource !== ""
        }

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

        Text {
            id: dateText
            anchors.right: batteryDisplay.left
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            color: "#cac5d9"
            font.pixelSize: 20
            font.bold: true
            horizontalAlignment: Text.AlignRight

            text: Qt.formatDateTime(new Date(), "dd/MM hh:mm")

            Timer {
                interval: 5000
                running: true
                repeat: true
                onTriggered: parent.text = Qt.formatDateTime(new Date(), "dd/MM hh:mm")
            }
        }

        Row {
            id: batteryDisplay
            anchors.right: powerButton.left
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Image {
                source: "icons/thunder.svg" 
                width: 22; height: 22
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                visible: BatteryContext.isCharging
                opacity: 1.0
            }

            Image {
                width: 30; height: 30
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                opacity: 1.0
    
                source: {
                    var level = parseInt(BatteryContext.level);

                    if (isNaN(level)) {
                        return "icons/battery100.svg";
                    }
                    
                    if (level > 75) return "icons/battery100.svg";
                    else if (level > 50) return "icons/battery75.svg";
                    else if (level > 25) return "icons/battery50.svg";
                    else return "icons/battery25.svg";
                }
            }

            Text {
                id: batteryText
                color: "#cac5d9"
                font.pixelSize: 18
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                text: BatteryContext.level 
            }
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

        enabled: visible && root.openedImageSource === "" && !root.gamesMode && !root.settingsMode
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
            else if (currentIndex === 3) { root.settingsMode = true; settingsCarousel.forceActiveFocus() }
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

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    carousel.currentIndex = index
                    carousel.selectItem()
                }
            }

            Image { 
                anchors.centerIn: parent
                source: model.icon
                width: 100; height: 100; fillMode: Image.PreserveAspectFit 
            }

            Behavior on opacity { NumberAnimation { duration: 250 } }
            Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
        }
    }

    // settings carousel
    PathView {
        id: settingsCarousel
        width: parent.width
        height: 250
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        visible: root.settingsMode && root.currentScreen === 0
        focus: visible
        clip: true

        model: ListModel {
            ListElement { title: "WALLPAPER"; icon: "icons/wallpaper.svg" }
        }

        Keys.onUpPressed: {
            root.settingsMode = false
            carousel.forceActiveFocus()
        }
        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()

        Keys.onSpacePressed: {
            if (currentIndex === 0) {
                root.wallpaperSettingsMode = true
                root.settingsMode = false
                wallpaperSettingsCarousel.forceActiveFocus()
            }
        }

        pathItemCount: 1
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
                    source: model.icon
                    fillMode: Image.PreserveAspectFit
                }
                
                opacity: isCurrent ? 1.0 : 0.3
                scale: isCurrent ? 1.1 : 0.7
                Behavior on scale { NumberAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

    }

    //indicator of current suboption if depth > 2
    Image {
        id: floatingIndicator
        anchors.bottom: wallpaperSettingsCarousel.top 
        anchors.bottomMargin: -118
        anchors.horizontalCenter: parent.horizontalCenter
        
        width: 60
        height: 60
        fillMode: Image.PreserveAspectFit
        
        visible: root.wallpaperSettingsMode
        
        source: {
            if (settingsCarousel.model.count > 0) {
                return settingsCarousel.model.get(settingsCarousel.currentIndex).icon
            }
            return ""
        }
        
        opacity: visible ? 0.2 : 0.0
    }

    // subsettings for wallpaper
    PathView {
        id: wallpaperSettingsCarousel
        width: parent.width
        height: 250
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        visible: root.wallpaperSettingsMode && root.currentScreen === 0
        focus: visible
        clip: true

        model: ListModel {
            ListElement { title: "STATIC"; isAnimated: false }
            ListElement { title: "ANIMATED"; isAnimated: true }
            ListElement { title: "STATIC"; isAnimated: false }
            ListElement { title: "ANIMATED"; isAnimated: true }
        }

        Keys.onUpPressed: {
            root.wallpaperSettingsMode = false
            root.settingsMode = true
            settingsCarousel.forceActiveFocus()
        }
        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()

        Keys.onSpacePressed: {
            root.useAnimatedWallpaper = model.get(currentIndex).isAnimated
        }

        pathItemCount: 3
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
                color: "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: model.title

                    color: (root.useAnimatedWallpaper === model.isAnimated) ? "#83916A" : "#cac5d9"
                    
                    font.pixelSize: (isCurrent && wallpaperSettingsCarousel.activeFocus) ? 42 : 28
                    font.bold: isCurrent
                    
                    Behavior on font.pixelSize { NumberAnimation { duration: 200 } }
                }
                
                opacity: isCurrent ? 1.0 : 0.3
                scale: isCurrent ? 1.1 : 0.7
                Behavior on scale { NumberAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
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
            folder: root.gamesFolderPath
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
            readonly property var gameImgUrl: typeof fileUrl !== "undefined" ? fileUrl : (typeof fileURL !== "undefined" ? fileURL : "")
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
                    source: gameImgUrl
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
        
        Keys.onUpPressed: function(event) { if (currentIndex === 0) modeButton.forceActiveFocus(); else event.accepted = false; }
        Keys.onLeftPressed: backButton.forceActiveFocus()
        Keys.onEscapePressed: { root.currentScreen = 0; carousel.forceActiveFocus() }

        model: FolderListModel {
            folder: root.musicFolderPath
            nameFilters: ["*.mp3", "*.MP3", "*.wav", "*.WAV"]; showDirs: false
        }

        delegate: Item {
            id: musicItemDelegate
            width: musicList.width; height: 80

            readonly property string currentFileUrl: (typeof fileUrl !== "undefined" ? fileUrl : (typeof fileURL !== "undefined" ? fileURL : "")).toString()
            readonly property bool isPlayingThis: root.playingMusicSource === currentFileUrl

            function toggleAudio() {
                if (isPlayingThis) {
                    if (audioPlayer.playbackState === MediaPlayer.PlayingState) {
                        audioPlayer.pause()
                    } else {
                        audioPlayer.play()
                    }
                } else {
                    root.playingMusicSource = currentFileUrl
                    audioPlayer.play()
                }
            }

            Keys.onSpacePressed: toggleAudio()

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    musicList.currentIndex = index
                    musicItemDelegate.toggleAudio()
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 15
                
                // playing indicator
                Image {
                    source: {
                        if (audioPlayer.playbackState === MediaPlayer.PlayingState){
                            "icons/music.svg"
                        } else {
                            "icons/pause.svg"
                        }
                    }
                    y: 7
                    width: 24; height: 24
                    fillMode: Image.PreserveAspectFit
                    visible: isPlayingThis
                    opacity: (parent.parent.ListView.isCurrentItem && musicList.activeFocus) ? 1.0 : 0.5
                }

                Text {
                    text: typeof fileName !== "undefined" ? fileName : ""
                    color: isPlayingThis ? "#83916A" : "#cac5d9"
                    font.pixelSize: (parent.parent.ListView.isCurrentItem && musicList.activeFocus) ? 32 : 20
                    font.bold: (parent.parent.ListView.isCurrentItem && musicList.activeFocus)
                    opacity: (parent.parent.ListView.isCurrentItem && musicList.activeFocus) ? 1.0 : 0.3
                }
            }
        }
    }

    // image and video grid
    GridView {
        id: imageGrid
        anchors.fill: parent
        anchors.topMargin: 135; anchors.leftMargin: 200; anchors.rightMargin: 50; anchors.bottomMargin: 100
        visible: root.currentScreen === 2
        cellWidth: 240; cellHeight: 240; clip: true; focus: true
        
        readonly property int columns: Math.floor(width / cellWidth)
        Keys.onUpPressed: function(event) { if (currentIndex < columns) modeButton.forceActiveFocus(); else event.accepted = false; }
        Keys.onLeftPressed: function(event) { if (currentIndex % columns === 0) backButton.forceActiveFocus(); else event.accepted = false; }
        Keys.onEscapePressed: { root.currentScreen = 0; carousel.forceActiveFocus() }

        model: FolderListModel {
            folder: root.picturesFolderPath
            nameFilters: ["*.jpg", "*.JPG", "*.png", "*.PNG", "*.jpeg", "*.JPEG", "*.mp4", "*.MP4", "*.mkv", "*.MKV", "*.webm", "*.avi"]
            showDirs: false
        }
        
        delegate: Item {
            width: 220; height: 220
            readonly property var currentImgSrc: typeof fileUrl !== "undefined" ? fileUrl : (typeof fileURL !== "undefined" ? fileURL : "")
            readonly property bool isVid: root.isVideo(currentImgSrc)

            Keys.onSpacePressed: root.openedImageSource = currentImgSrc

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    imageGrid.currentIndex = index
                    root.openedImageSource = currentImgSrc
                }
            }

            Rectangle {
                anchors.fill: parent; color: "transparent"
                border.color: "#cac5d9"; border.width: (parent.GridView.isCurrentItem && imageGrid.activeFocus) ? 2 : 0
                
                Image { 
                    id: thumbImage
                    anchors.fill: parent
                    anchors.margins: 5
                    
                    asynchronous: true
                    
                    source: {
                        if (!isVid) {
                            return currentImgSrc;
                        } else {
                            var path = currentImgSrc.toString();
                            if (path.startsWith("file://")) {
                                path = path.substring(7);
                            }
                            return "image://vidthumb/" + path;
                        }
                    }
                    
                    fillMode: Image.PreserveAspectCrop
                    autoTransform: true 
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 50; height: 50
                    radius: 25
                    color: "#000000"
                    opacity: 0.6
                    visible: isVid
                    
                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: 3
                        text: "▶"
                        color: "white"
                        font.pixelSize: 24
                    }
                }
            }
        }
    }

    //enlarged image / video player
    Item {
        id: lightbox
        anchors.fill: parent; visible: root.openedImageSource !== ""; z: 1000; focus: visible 
        
        property bool isVid: root.isVideo(root.openedImageSource)

        function togglePlayPause() {
            if (videoPlayer.playbackState === MediaPlayer.PlayingState) {
                videoPlayer.pause()
            } else {
                videoPlayer.play()
            }
        }

        Rectangle { 
            anchors.fill: parent
            color: "black"
            opacity: lightbox.isVid ? 0.9 : 0.7
        }

        MediaPlayer {
            id: videoPlayer
            source: lightbox.isVid ? root.openedImageSource : ""
            onStatusChanged: {
                if (status === MediaPlayer.EndOfMedia) {
                    stop();
                    play(); // loop
                }
            }
        }

        VideoOutput {
            anchors.centerIn: parent
            width: parent.width * 0.9; height: parent.height * 0.9
            source: videoPlayer
            fillMode: VideoOutput.PreserveAspectFit
            visible: lightbox.isVid
            scale: lightbox.visible ? 1.0 : 0.5
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        }

        Image {
            anchors.centerIn: parent
            width: parent.width * 0.9; height: parent.height * 0.9
            source: lightbox.isVid ? "" : root.openedImageSource
            fillMode: Image.PreserveAspectFit; autoTransform: true
            visible: !lightbox.isVid
            scale: lightbox.visible ? 1.0 : 0.5
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        }

        Image {
            anchors.centerIn: parent
            source: "icons/pause.svg"
            width: 80; height: 80
            opacity: (lightbox.isVid && videoPlayer.playbackState !== MediaPlayer.PlayingState) ? 0.7 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (lightbox.isVid) {
                    lightbox.togglePlayPause()
                } else {
                    root.openedImageSource = ""
                }
            }
        }

        Keys.onSpacePressed: {
            if (lightbox.isVid) {
                lightbox.togglePlayPause()
            } else {
                root.openedImageSource = ""
            }
        }

        Keys.onEscapePressed: root.openedImageSource = ""

        onVisibleChanged: {
            if (!visible) {
                videoPlayer.stop()
                imageGrid.forceActiveFocus()
            } else {
                if (isVid) videoPlayer.play()
            }
        }
    }
}