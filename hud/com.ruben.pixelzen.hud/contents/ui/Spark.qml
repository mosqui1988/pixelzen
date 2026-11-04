import QtQuick

Item {
    id: sp
    property var serie: []
    property real maxv: 100
    property int cols: 56
    property color color: Pal.rosa
    clip: true
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: 1
        Repeater {
            model: sp.cols
            Item {
                width: (sp.width - (sp.cols - 1)) / sp.cols; height: sp.height
                property real v: { var i = sp.serie.length - sp.cols + index; return (i >= 0 && i < sp.serie.length) ? sp.serie[i] : 0 }
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Pal.line }
                Rectangle {
                    anchors.bottom: parent.bottom; width: parent.width
                    height: Math.max(2, Math.round(Math.min(1, parent.v / sp.maxv) * sp.height))
                    color: sp.color; opacity: 0.35 + 0.65 * (index / sp.cols)
                }
            }
        }
    }
}
