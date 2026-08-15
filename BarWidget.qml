import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.scottpruett.sticky-keys"

  property var activeLayers: ({})

  readonly property var modifiers: [
    { layer: "control", label: "CTRL" },
    { layer: "alt", label: "ALT" },
    { layer: "shift", label: "SHIFT" },
    { layer: "meta", label: "SUPER" }
  ]
  readonly property bool hasActiveLayer: {
    for (var i = 0; i < modifiers.length; i++)
      if ((activeLayers[modifiers[i].layer] || 0) > 0) return true
    return false
  }
  readonly property color badgeBackground: bar ? bar.urgent : "#e06c75"
  readonly property color badgeForeground: bar
    ? ("themeContrastForeground" in bar ? bar.themeContrastForeground : bar.background)
    : "#111111"

  function adjustLayerDepth(layer, delta) {
    var next = {}
    for (var name in activeLayers) next[name] = activeLayers[name]
    var depth = Math.max(0, (next[layer] || 0) + delta)
    if (depth > 0) next[layer] = depth
    else delete next[layer]
    activeLayers = next
  }

  function handleLayerEvent(rawLine) {
    var line = String(rawLine).trim()
    if (line.length < 2) return

    var state = line.charAt(0)
    var layer = line.slice(1)
    if (state === "/") activeLayers = ({})
    else if (state === "+") adjustLayerDepth(layer, 1)
    else if (state === "-") adjustLayerDepth(layer, -1)
  }

  function tooltipText() {
    var names = []
    for (var i = 0; i < modifiers.length; i++) {
      if ((activeLayers[modifiers[i].layer] || 0) > 0)
        names.push(modifiers[i].label)
    }
    return names.length > 0
      ? "Active sticky keys: " + names.join(", ")
      : "Sticky keys ready — tap a modifier to latch it"
  }

  // Keep the plugin instantiated while idle so its keyd listener remains
  // attached, but occupy only one transparent pixel until a layer is active.
  visible: true
  implicitWidth: hasActiveLayer ? badgeRow.implicitWidth : 1
  implicitHeight: bar ? bar.barSize : 26

  Process {
    id: listener
    command: ["keyd", "listen"]
    running: true
    stdout: SplitParser {
      onRead: function(line) { root.handleLayerEvent(line) }
    }
    onExited: reconnectTimer.restart()
  }

  Timer {
    id: reconnectTimer
    interval: 2000
    repeat: false
    onTriggered: listener.running = true
  }

  Row {
    id: badgeRow
    anchors.centerIn: parent
    spacing: 4
    visible: root.hasActiveLayer

    Repeater {
      model: root.modifiers

      Rectangle {
        required property var modelData
        readonly property bool active: (root.activeLayers[modelData.layer] || 0) > 0
        visible: active
        width: active ? label.implicitWidth + 10 : 0
        height: 18
        radius: 4
        color: root.badgeBackground

        Behavior on color {
          ColorAnimation { duration: 420; easing.type: Easing.InOutCubic }
        }

        Text {
          id: label
          anchors.centerIn: parent
          text: parent.modelData.label
          color: root.badgeForeground
          font.family: root.bar ? root.bar.fontFamily : "monospace"
          font.pixelSize: 10
          font.bold: true

          Behavior on color {
            ColorAnimation { duration: 420; easing.type: Easing.InOutCubic }
          }
        }
      }
    }
  }

  HoverHandler {
    onHoveredChanged: {
      if (!root.bar) return
      if (hovered) root.bar.showTooltip(root, root.tooltipText())
      else root.bar.hideTooltip(root)
    }
  }
}
