import QtQuick 2.7
import QtQuick.Layouts 1.3

import Vedder.vesc.commands 1.0

Item {
    id: mainItem
    anchors.fill: parent

    property Commands mCommands: VescIf.commands()

    ColumnLayout {
        id: gaugeColumn
        anchors.fill: parent
        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            CustomGaugeV2 {
                id: irGauge
                Layout.fillWidth: true
                Layout.preferredWidth: gaugeColumn.width * 0.45
                Layout.preferredHeight: gaugeColumn.height * 0.45
                maximumValue: 500
                minimumValue: 0.0
                tickmarkScale: 1
                tickmarkSuffix: ""
                labelStep: 50
                value: 200
                unitText: "mOhm"
                typeText: "Battery\nIR"
            }

            CustomGaugeV2 {
                id: mismatchGauge
                Layout.fillWidth: true
                Layout.preferredWidth: gaugeColumn.width * 0.45
                Layout.preferredHeight: gaugeColumn.height * 0.45
                maximumValue: 500
                minimumValue: 0
                tickmarkScale: 1
                tickmarkSuffix: ""
                labelStep: 50
                value: 0
                unitText: "mV"
                typeText: "Cell\nMismatch"
            }
        }
        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            CustomGaugeV2 {
                id: lowCellGauge
                Layout.fillWidth: true
                Layout.preferredWidth: gaugeColumn.width * 0.45
                Layout.preferredHeight: gaugeColumn.height * 0.45
                maximumValue: 5000
                minimumValue: 0
                tickmarkScale: 1
                tickmarkSuffix: ""
                labelStep: 500
                value: 3000
                unitText: "mV"
                typeText: "Low Cell"
            }

            CustomGaugeV2 {
                id: battTempGauge
                Layout.fillWidth: true
                Layout.preferredWidth: gaugeColumn.width * 0.45
                Layout.preferredHeight: gaugeColumn.height * 0.45
                maximumValue: 60
                minimumValue: 0
                tickmarkScale: 1
                tickmarkSuffix: ""
                labelStep: 10
                value: 0
                unitText: "C"
                typeText: "Battery\nTemp"
            }
        }

        Connections {
            target: mCommands

            function onCustomAppDataReceived(values, mask) {
                var dv = new DataView(values)
                irGauge.value = dv.getFloat32(0) * 1000
                mismatchGauge.value = dv.getFloat32(4) * 1000
                lowCellGauge.value = dv.getFloat32(8) * 1000
                battTempGauge.value = dv.getFloat32(12)
            }
        }
    }
}
