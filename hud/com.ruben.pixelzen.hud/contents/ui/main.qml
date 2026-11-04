import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    // ------------------------------------------------------------ datos
    readonly property string script: Qt.resolvedUrl("../code/datos.py").toString().replace("file://", "")
    property var d: ({ cpu: 0, ram: { pct: 0, usado: 0, total: 0 }, temp: 0, bat: null, net: { vpn: {} }, load: [0, 0, 0], up: 0, disco: 0, top: [] })
    property var s: ({ puertos: [], repos: [], tc: {}, tools: {}, fallos: 0, errores: 0, est: 0, vecinos: 0 })
    property var cpuH: []
    property var rxH: []
    property var now: new Date()

    function push(a, v, n) { var b = a.slice(); b.push(v); if (b.length > n) b.shift(); return b }
    function onRapido(out) { try { d = JSON.parse(out); cpuH = push(cpuH, d.cpu, 120); rxH = push(rxH, d.net.rx, 120) } catch (e) {} }
    function onLento(out) { try { s = JSON.parse(out) } catch (e) {} }

    P5Support.DataSource {
        id: sh
        engine: "executable"
        interval: 0
        connectedSources: []
        onNewData: function (source, data) {
            disconnectSource(source)
            if (source.indexOf("datos.py rapido") >= 0) root.onRapido(data["stdout"])
            else if (source.indexOf("datos.py lento") >= 0) root.onLento(data["stdout"])
        }
    }
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: sh.connectSource("python3 -I " + root.script + " rapido") }
    Timer { interval: 20000; running: true; repeat: true; triggeredOnStart: true; onTriggered: sh.connectSource("python3 -I " + root.script + " lento") }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: root.now = new Date() }

    function term(cmd, rellenar) {
        var c = rellenar ? ("commandline -r \"" + cmd + "\"") : cmd
        sh.connectSource("setsid -f alacritty --title PixelZen -e fish -C '" + c + "'")
    }

    // ------------------------------------------------------------ utilidades
    function p2(n) { return (n < 10 ? "0" : "") + n }
    




    function tasa(b) { return b >= 1048576 ? (b / 1048576).toFixed(1) + "M" : b >= 1024 ? Math.round(b / 1024) + "K" : b + "B" }
    function horas(m) { return m > 0 ? Math.floor(m / 60) + "h" + p2(m % 60) : "--" }
    function durac(s) { var dd = Math.floor(s / 86400), hh = Math.floor(s % 86400 / 3600), mm = Math.floor(s % 3600 / 60); return dd > 0 ? dd + " gün " + hh + " sa" : hh > 0 ? hh + " sa " + mm + " dk" : mm + " dk" }
    function luna() {
        var syn = 29.530588853, ref = Date.UTC(2000, 0, 6, 18, 14) / 86400000
        var age = (((Date.now() / 86400000 - ref) % syn) + syn) % syn
        return { age: age, p: age / syn }
    }
    readonly property var dias: ["Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi"]
    readonly property var meses: ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]
    readonly property var aylar: ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
    readonly property var haikus: [
        { jp: "古池や 蛙飛びこむ 水の音", tr: "Eski bir gölet; bir kurbağa atlar, suyun sesi duyulur.", au: "Bashō" },
        { jp: "閑さや 岩にしみ入る 蝉の声", tr: "Sessizlik; ağustos böceğinin sesi kayaya işler.", au: "Bashō" },
        { jp: "夏草や 兵どもが 夢の跡", tr: "Yaz otları; savaşçıların düşünden geriye kalanlar.", au: "Bashō" },
        { jp: "菜の花や 月は東に 日は西に", tr: "Kanola çiçekleri; ay doğuda, güneş batıda.", au: "Buson" },
        { jp: "秋深き 隣は何を する人ぞ", tr: "Derin sonbahar; komşum acaba ne yapıyor?", au: "Bashō" },
        { jp: "朝顔に つるべとられて もらい水", tr: "Sarmaşık kovayı sardı; suyumu komşudan alıyorum.", au: "Chiyo-ni" }
    ]
    property int hk: Math.floor(Date.now() / 90000) % haikus.length
    Timer { interval: 90000; running: true; repeat: true; onTriggered: hkAnim.restart() }
    property real hkOp: 1
    SequentialAnimation {
        id: hkAnim
        NumberAnimation { target: root; property: "hkOp"; to: 0; duration: 400 }
        ScriptAction { script: root.hk = (root.hk + 1) % root.haikus.length }
        NumberAnimation { target: root; property: "hkOp"; to: 1; duration: 600 }
    }

    // botones pixel
    component PxBtn: Item {
        id: b
        property string kanji: ""
        property string label: ""
        property bool activo: true
        signal clicked
        Rectangle {
            anchors.fill: parent
            color: ma.containsMouse && b.activo ? Pal.violet : Pal.bg2
            opacity: b.activo ? 1 : 0.55
            border.width: 1
            border.color: ma.containsMouse && b.activo ? Pal.rosa : Pal.border
            Rectangle { x: 0; y: 0; width: 4; height: 1; color: b.activo ? Pal.red : Pal.faint }
            Rectangle { x: 0; y: 0; width: 1; height: 4; color: b.activo ? Pal.red : Pal.faint }
            Text {
                anchors.centerIn: parent
                width: b.width - 8
                text: b.label
                font.family: Pal.mono
                font.pixelSize: 10
                color: b.activo ? Pal.text : Pal.faint
                renderType: Text.NativeRendering
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: b.clicked() }
    }
    component Etq: Text { font.family: Pal.mono; font.pixelSize: 11; color: Pal.dim; renderType: Text.NativeRendering }
    component Val: Text { font.family: Pal.mono; font.pixelSize: 13; color: Pal.text; renderType: Text.NativeRendering }

    // ------------------------------------------------------------ interfaz
    fullRepresentation: Item {
        id: hud
        implicitWidth: 336
        implicitHeight: 880
        Layout.minimumWidth: 200; Layout.minimumHeight: 524
        Layout.preferredWidth: 336; Layout.preferredHeight: 880

        // el diseno es de 336x880; si el widget es mas grande o mas pequeno, todo se escala por igual
        readonly property real k: Math.max(0.4, Math.min(width / 336, height / 880))

        Item {
            id: lienzo
            width: 336; height: 880
            scale: hud.k
            transformOrigin: Item.TopLeft

        Column {
            anchors.fill: parent
            spacing: 10

            // ===================================================== RELOJ
            Card {
                width: parent.width; height: 120
                kanji: "時"; title: "SAAT"; meta: root.s.host ? root.s.host : ""
                Text {
                    x: -2; y: -2
                    text: root.p2(root.now.getHours()) + ":" + root.p2(root.now.getMinutes())
                    font.family: Pal.mono; font.pixelSize: 46; color: Pal.text; renderType: Text.NativeRendering
                }
                Text {
                    x: 148; y: 16
                    text: root.p2(root.now.getSeconds())
                    font.family: Pal.mono; font.pixelSize: 18; color: Pal.rosa; renderType: Text.NativeRendering
                }
                Text {
                    x: 0; y: 44
                    visible: false
                    text: root.dias[root.now.getDay()] + " " + root.now.getDate() + " " + root.meses[root.now.getMonth()] + " " + root.now.getFullYear()
                    font.family: Pal.mono; font.pixelSize: 13; color: Pal.text; renderType: Text.NativeRendering
                }
                Text {
                    x: 0; y: 62
                    text: root.dias[root.now.getDay()] + ", " + root.now.getDate() + " " + root.aylar[root.now.getMonth()] + " " + root.now.getFullYear()
                    font.family: Pal.mono; font.pixelSize: 12; color: Pal.rosa; renderType: Text.NativeRendering
                }
                // fase lunar pixelada
                Canvas {
                    id: luna
                    x: parent.width - 82; y: 2; width: 36; height: 36
                    property real p: root.luna().p
                    onPChanged: requestPaint()
                    onPaint: {
                        var c = getContext("2d"); c.reset()
                        var R = 4.5, k = 4, q = Math.cos(2 * Math.PI * p)
                        for (var j = 0; j < 9; j++) for (var i = 0; i < 9; i++) {
                            var nx = (i - 4) / R, ny = (j - 4) / R
                            if (nx * nx + ny * ny > 1.02) continue
                            var ill = Math.sqrt(Math.max(0, 1 - ny * ny))
                            var lit = p < 0.5 ? nx >= q * ill : nx <= -Math.cos(2 * Math.PI * (1 - p)) * ill
                            c.fillStyle = lit ? "#f6ecd4" : "#2b2850"
                            c.fillRect(i * k, j * k, k, k)
                        }
                    }
                }
                Text { x: parent.width - 84; y: 40; width: 40; horizontalAlignment: Text.AlignHCenter; text: Math.round(root.luna().age) + " gün"; font.family: Pal.mono; font.pixelSize: 11; color: Pal.dim; renderType: Text.NativeRendering }
            }

            // ===================================================== SISTEMA
            Card {
                width: parent.width; height: 176
                kanji: "機"; title: "SİSTEM"
                meta: root.d.up ? "ÇALIŞMA " + root.durac(root.d.up) : ""
                Column {
                    spacing: 3
                    Row { spacing: 8
                        Etq { width: 42; text: "CPU"; y: 3 }
                        SegBar { width: 166; value: root.d.cpu; y: 3 }
                        Val { width: 80; horizontalAlignment: Text.AlignRight; text: Math.round(root.d.cpu) + "%  " + root.d.nuc + "c" }
                    }
                    Row { spacing: 8
                        Etq { width: 42; text: "RAM"; y: 3 }
                        SegBar { width: 166; value: root.d.ram.pct; y: 3 }
                        Val { width: 80; horizontalAlignment: Text.AlignRight; text: root.d.ram.usado + "/" + Math.round(root.d.ram.total) + "G" }
                    }
                    Row { spacing: 8
                        Etq { width: 42; text: "ISI"; y: 3 }
                        SegBar { width: 166; value: root.d.temp ? (root.d.temp - 30) / 60 * 100 : 0; y: 3; c1: Pal.cyan; c2: Pal.amber; c3: Pal.hot }
                        Val { width: 80; horizontalAlignment: Text.AlignRight; text: (root.d.temp ? root.d.temp.toFixed(0) : "--") + "°C" }
                    }
                    Row { spacing: 8
                        visible: root.d.bat !== null
                        Etq { width: 42; text: root.d.bat && root.d.bat.estado === "Charging" ? "ŞARJ" : "PİL"; y: 3 }
                        SegBar { width: 166; value: root.d.bat ? root.d.bat.pct : 0; y: 3; invert: true; c1: Pal.green }
                        Val { width: 80; horizontalAlignment: Text.AlignRight; text: root.d.bat ? root.d.bat.pct + "% " + root.horas(root.d.bat.min) : "" }
                    }
                    Item { width: 1; height: 1 }
                    Item { width: parent.parent.width; height: 24; Spark { anchors.horizontalCenter: parent.horizontalCenter; width: parent.width; height: 24; serie: root.cpuH; cols: 56; maxv: Math.max(12, Math.max.apply(null, root.cpuH.length ? root.cpuH : [0])); color: Pal.rosa } }
                    Row {
                        width: parent.parent.width
                        spacing: 0
                        Item {
                            width: parent.width / 3; height: 24
                            Column { anchors.centerIn: parent; spacing: 2
                                Etq { width: parent.width; text: "YÜK"; horizontalAlignment: Text.AlignHCenter }
                                Val { width: parent.width; text: root.d.load[0].toFixed(2); font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter }
                            }
                        }
                        Item {
                            width: parent.width / 3; height: 30
                            Column { anchors.centerIn: parent; spacing: 2
                                Etq { width: parent.width; text: "DİSK"; horizontalAlignment: Text.AlignHCenter }
                                Val { width: parent.width; text: Math.round(root.d.disco) + "%"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter }
                            }
                        }
                        Item {
                            width: parent.width / 3; height: 30
                            Column { anchors.centerIn: parent; spacing: 2
                                Etq { width: parent.width; text: "EN ÇOK"; horizontalAlignment: Text.AlignHCenter }
                                Val { width: parent.width; text: root.d.top && root.d.top.length ? root.d.top[0][0].substring(0, 8) : "--"; font.pixelSize: 12; color: Pal.amber; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight }
                            }
                        }
                    }
                }
            }

            // ===================================================== RED
            Card {
                width: parent.width; height: 176
                kanji: "網"; title: "AĞ"
                meta: root.d.net && root.d.net.iface ? root.d.net.iface : "Ağ yok"
                Column {
                    spacing: 3
                    Row { spacing: 8; height: 16
                        Row { spacing: 1; y: 2
                            Repeater { model: 4
                                Item { width: 3; height: 12
                                    Rectangle { anchors.bottom: parent.bottom; width: 3; height: 3 + index * 3
                                        color: (root.d.net && root.d.net.senal !== null && root.d.net.senal >= (index + 1) * 25 - 10) ? Pal.green : Pal.track }
                                }
                            }
                        }
                        Val { text: root.d.net && root.d.net.ssid ? root.d.net.ssid : "Kablolu" }
                    }
                    Row { spacing: 12
                        Etq { text: "IP"; y: 2 } Val { text: root.d.net && root.d.net.ip ? root.d.net.ip : "--"; font.pixelSize: 12 }
                        Etq { text: "AĞ GEÇ."; y: 2 } Val { text: root.d.net && root.d.net.gw ? root.d.net.gw : "--"; font.pixelSize: 12 }
                    }
                    Row { spacing: 8
                        Rectangle { y: 3; width: 9; height: 9; color: root.d.net.vpn && root.d.net.vpn.on ? Pal.green : Pal.faint }
                        Etq { text: "VPN"; y: 2 }
                        Val { text: root.d.net.vpn && root.d.net.vpn.on ? root.d.net.vpn.iface + "  " + root.d.net.vpn.ip : "Etkin değil"; font.pixelSize: 12; color: root.d.net.vpn && root.d.net.vpn.on ? Pal.green : Pal.dim }
                    }
                    Row { spacing: 10; height: 38
                        Column { width: 92; spacing: -3
                            Val { text: "↓ " + root.tasa(root.d.net.rx ? root.d.net.rx : 0); font.pixelSize: 12; color: Pal.cyan }
                            Val { text: "↑ " + root.tasa(root.d.net.tx ? root.d.net.tx : 0); font.pixelSize: 12; color: Pal.rosa }
                        }
                        Spark { width: 200; height: 28; serie: root.rxH; maxv: Math.max(20000, Math.max.apply(null, root.rxH.length ? root.rxH : [0])); cols: 40; color: Pal.cyan }
                    }
                    Flow {
                        width: parent.parent.width; spacing: 4
                        Repeater {
                            model: root.s.puertos ? root.s.puertos.slice(0, 8) : []
                            Rectangle {
                                width: t.width + 10; height: 16; color: "transparent"
                                border.width: 1; border.color: modelData.local ? Pal.faint : Pal.amber
                                Text { id: t; anchors.centerIn: parent; text: modelData.p + (modelData.n ? " " + modelData.n.substring(0, 6) : ""); font.family: Pal.mono; font.pixelSize: 11; color: modelData.local ? Pal.dim : Pal.amber; renderType: Text.NativeRendering }
                            }
                        }
                    }
                    Row { spacing: 12
                        Etq { text: "BAĞLANTI"; y: 2 } Val { text: root.s.est; font.pixelSize: 12 }
                        Etq { text: "YEREL"; y: 2 } Val { text: root.s.vecinos + " cihaz"; font.pixelSize: 12 }
                        Etq { text: "DNS"; y: 2 } Val { text: root.s.dns ? root.s.dns : "--"; font.pixelSize: 12 }
                    }
                }
            }

            // ===================================================== DEV
            Card {
                width: parent.width; height: 100 + Math.max(0, (root.s.repos ? root.s.repos.length : 0) - 1) * 17
                kanji: "開"; title: "GELİŞTİRME"
                meta: root.s.kernel ? "linux " + root.s.kernel : ""
                Column {
                    spacing: 3
                    Text {
                        visible: !root.s.repos || root.s.repos.length === 0
                        text: "Git deposu bulunamadı. ~/pixelzen ve geliştirme klasörleri taranıyor."; font.family: Pal.mono; font.pixelSize: 12; color: Pal.faint; renderType: Text.NativeRendering
                    }
                    Repeater {
                        model: root.s.repos ? root.s.repos : []
                        Row { spacing: 8
                            Rectangle { y: 5; width: 8; height: 8; color: modelData.sucio > 0 ? Pal.amber : Pal.green }
                            Val { text: modelData.n.substring(0, 14); font.pixelSize: 12 }
                            Val { text: modelData.b; color: Pal.rosa; font.pixelSize: 12 }
                            Val { text: (modelData.sucio ? "~" + modelData.sucio : "") + (modelData.adelante ? " ↑" + modelData.adelante : "") + (modelData.atras ? " ↓" + modelData.atras : ""); color: Pal.amber; font.pixelSize: 12 }
                        }
                    }
                    Row { spacing: 10
                        Etq { text: "PY"; y: 2 } Val { text: root.s.tc.py ? root.s.tc.py : "—"; font.pixelSize: 12 }
                        Etq { text: "NODE"; y: 2 } Val { text: root.s.tc.node ? root.s.tc.node : "—"; font.pixelSize: 12; color: root.s.tc.node ? Pal.text : Pal.faint }
                        Etq { text: "GO"; y: 2 } Val { text: root.s.tc.go ? root.s.tc.go : "—"; font.pixelSize: 12; color: root.s.tc.go ? Pal.text : Pal.faint }
                        Etq { text: "RUST"; y: 2 } Val { text: root.s.tc.rust ? root.s.tc.rust : "—"; font.pixelSize: 12; color: root.s.tc.rust ? Pal.text : Pal.faint }
                    }
                    Row { spacing: 10
                        Rectangle { y: 5; width: 8; height: 8; color: root.s.fallos > 0 ? Pal.hot : Pal.green }
                        Etq { text: "HİZMET"; y: 2 } Val { text: root.s.fallos + " hata"; font.pixelSize: 12; color: root.s.fallos > 0 ? Pal.hot : Pal.text }
                        Etq { text: "SON 1 SA."; y: 2 } Val { text: root.s.errores; font.pixelSize: 12; color: root.s.errores > 0 ? Pal.amber : Pal.text }
                        Etq { text: "GÜNC."; y: 2 } Val { text: root.s.pacman_h !== null && root.s.pacman_h !== undefined ? (root.s.pacman_h > 48 ? Math.floor(root.s.pacman_h / 24) + "d" : root.s.pacman_h + "h") : "--"; font.pixelSize: 12 }
                    }
                }
            }

            // ===================================================== HERRAMIENTAS
            Card {
                width: parent.width; height: 104
                kanji: "道"; title: "ARAÇLAR"
                meta: ""
                Grid {
                    columns: 4; spacing: 6
                    PxBtn { width: 74; height: 28; kanji: "監"; label: "SÜREÇ"; activo: !!root.s.tools.btop; onClicked: root.term("btop") }
                    PxBtn { width: 74; height: 28; kanji: "口"; label: "PORTLAR"; onClicked: root.term("ss -tulpn") }
                    PxBtn { width: 74; height: 28; kanji: "網"; label: "AĞ"; onClicked: root.term("ip -br a; echo; ip r; echo; resolvectl status | head -20") }
                    PxBtn { width: 74; height: 28; kanji: "報"; label: "ÖZET"; activo: !!root.s.tools.fastfetch; onClicked: root.term("fastfetch") }
                    PxBtn { width: 74; height: 28; kanji: "名"; label: "DNS"; activo: !!root.s.tools.dig; onClicked: root.term("dig archlinux.org +noall +answer +stats") }
                    PxBtn { width: 74; height: 28; kanji: "隣"; label: "CİHAZ"; onClicked: root.term("ip neigh") }
                    PxBtn { width: 74; height: 28; kanji: "脈"; label: "PING"; onClicked: root.term("ping -c 4 1.1.1.1") }
                    PxBtn {
                        width: 74; height: 28; kanji: "探"; label: root.s.tools.nmap ? "NMAP" : "NMAP KUR"
                        activo: !!root.s.tools.nmap
                        onClicked: root.s.tools.nmap ? root.term("nmap -sn " + (root.d.net.ip ? root.d.net.ip.replace(/\.\d+$/, ".0/24") : "192.168.1.0/24"), true) : root.term("sudo pacman -S nmap", true)
                    }
                }
            }

            // ===================================================== HAIKU
            Card {
                width: parent.width; height: 90
                kanji: "句"; title: "HAİKU"; meta: root.haikus[root.hk].au
                Item {
                    opacity: root.hkOp
                    width: parent.width; height: parent.height
                    Text { width: parent.width; text: root.haikus[root.hk].jp; font.family: Pal.jp; font.pixelSize: 14; color: Pal.flor; renderType: Text.NativeRendering }
                    Text { y: 19; width: parent.width; wrapMode: Text.WordWrap; text: root.haikus[root.hk].tr; font.family: Pal.mono; font.pixelSize: 11; color: Pal.dim; renderType: Text.NativeRendering }
                }
            }
        }
        }
    }
}
