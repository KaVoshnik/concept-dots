// ~/.config/quickshell/concept-panel/shell.qml
//
// A small settings panel for concept-dots: pick a wallpaper (live-applied
// via awww/swww) or a theme (regenerates colors across every themed config via
// scripts/apply-theme.py).
//
// Toggle with SUPER+S (bound in hypr/keybinds.conf to `qs -c concept-panel
// ipc call panel toggle`). Requires the `quickshell` package.
//
// If your Quickshell version's API differs slightly from what's used here
// (this targets the 2026 Quickshell API — ShellRoot/FloatingWindow/
// IpcHandler/Process), check https://quickshell.org/docs for the current
// syntax; the logic (list wallpapers, run a script on click) stays the same.

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    property string homeDir: Quickshell.env("HOME")
    property string wallDir: homeDir + "/.config/hypr/wallpapers"
    property string scriptsDir: homeDir + "/.config/concept-dots/scripts"
    property int activeTab: 0 // 0 = wallpapers, 1 = themes

    FloatingWindow {
        id: window
        visible: false
        implicitWidth: 680
        implicitHeight: 520
        title: "concept-panel"

        color: "#101014"

        IpcHandler {
            target: "panel"
            function toggle(): void {
                window.visible = !window.visible
                if (window.visible) wallpaperLister.running = true
            }
        }

        // ── list wallpaper files on open ──
        ListModel { id: wallpaperModel }

        Process {
            id: wallpaperLister
            command: ["bash", "-c", "ls " + wallDir + "/*.png " + wallDir + "/*.jpg " + wallDir + "/*.jpeg 2>/dev/null"]
            stdout: StdioCollector {
                onStreamFinished: {
                    wallpaperModel.clear()
                    const lines = this.text.split("\n").filter(l => l.trim().length > 0)
                    for (const path of lines) {
                        // skip the "current.png" symlink itself to avoid duplicate/self entries
                        if (path.endsWith("/current.png")) continue
                        wallpaperModel.append({ path: path, name: path.split("/").pop() })
                    }
                }
            }
        }

        Process {
            id: wallpaperApplier
            command: ["bash", scriptsDir + "/apply-wallpaper.sh", ""]
            running: false
        }

        function applyWallpaper(path) {
            wallpaperApplier.command = ["bash", scriptsDir + "/apply-wallpaper.sh", path]
            wallpaperApplier.running = true
        }

        Process {
            id: themeApplier
            command: ["python3", scriptsDir + "/apply-theme.py", ""]
            running: false
        }

        function applyTheme(name) {
            themeApplier.command = ["python3", scriptsDir + "/apply-theme.py", name]
            themeApplier.running = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // ── tab bar ──
            RowLayout {
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 36
                    radius: 10
                    color: activeTab === 0 ? "#8a90f0" : "#1c1c24"
                    Text {
                        anchors.centerIn: parent
                        text: "Wallpaper"
                        color: activeTab === 0 ? "#0a0a0c" : "#e8e8ec"
                        font.bold: true
                    }
                    MouseArea { anchors.fill: parent; onClicked: activeTab = 0 }
                }

                Rectangle {
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 36
                    radius: 10
                    color: activeTab === 1 ? "#8a90f0" : "#1c1c24"
                    Text {
                        anchors.centerIn: parent
                        text: "Theme"
                        color: activeTab === 1 ? "#0a0a0c" : "#e8e8ec"
                        font.bold: true
                    }
                    MouseArea { anchors.fill: parent; onClicked: activeTab = 1 }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "SUPER+S to close"
                    color: "#72758c"
                    font.pixelSize: 12
                }
            }

            // ── wallpaper grid ──
            GridView {
                id: wallGrid
                visible: activeTab === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 160
                cellHeight: 100
                clip: true
                model: wallpaperModel

                delegate: Rectangle {
                    width: 150
                    height: 90
                    radius: 10
                    color: "#1c1c24"
                    border.width: 2
                    border.color: "#272733"

                    Image {
                        anchors.fill: parent
                        anchors.margins: 4
                        source: "file://" + path
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        layer.enabled: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.border.color = "#8a90f0"
                        onExited: parent.border.color = "#272733"
                        onClicked: window.applyWallpaper(path)
                    }
                }

                Text {
                    visible: wallpaperModel.count === 0
                    anchors.centerIn: parent
                    text: "No wallpapers found in ~/.config/hypr/wallpapers"
                    color: "#72758c"
                }
            }

            // ── theme grid ──
            GridLayout {
                visible: activeTab === 1
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                columnSpacing: 14
                rowSpacing: 14

                Repeater {
                    model: ListModel {
                        ListElement { themeName: "concept"; swatch1: "#8a90f0"; swatch2: "#e8a0c8"; swatch3: "#35a8b4"; label: "Concept (default)" }
                        ListElement { themeName: "aurora";  swatch1: "#f0a84a"; swatch2: "#7ce0c0"; swatch3: "#4ab4f0"; label: "Aurora" }
                    }

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        radius: 12
                        color: "#1c1c24"
                        border.width: 2
                        border.color: "#272733"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            RowLayout {
                                spacing: 8
                                Rectangle { width: 28; height: 28; radius: 14; color: swatch1 }
                                Rectangle { width: 28; height: 28; radius: 14; color: swatch2 }
                                Rectangle { width: 28; height: 28; radius: 14; color: swatch3 }
                            }

                            Text {
                                text: label
                                color: "#e8e8ec"
                                font.bold: true
                                font.pixelSize: 15
                            }

                            Item { Layout.fillHeight: true }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.border.color = "#8a90f0"
                            onExited: parent.border.color = "#272733"
                            onClicked: window.applyTheme(themeName)
                        }
                    }
                }
            }
        }
    }
}
