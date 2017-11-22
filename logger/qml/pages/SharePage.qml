/*
 * Copyright (C) 2016-2017 Jolla Ltd.
 * Copyright (C) 2016-2017 Slava Monich <slava.monich@jolla.com>
 *
 * You may use this file under the terms of BSD license as follows:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *   3. Neither the name of Jolla Ltd nor the names of its contributors may
 *      be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.notifications 1.0

Page {
    id: page
    property var logSaver: LogSaver
    allowedOrientations: window.allowedOrientations
    property bool _canShare: !logSaver.packing && !logSaver.saving && !minWaitTimer.running

    // For the page slide animation to kick in, the initial value of
    // backNavigation has to be true. Once the transition has started,
    // backNavigation is turned off until the log has been saved.
    showNavigationIndicator: status !== PageStatus.Inactive
    backNavigation: status === PageStatus.Inactive || _canShare

    // The timer makes sure that animation is displayed for at least 1 second
    Timer {
        id: minWaitTimer
        interval: 1000
        running: true
    }

    Notification {
        id: notification
    }

    Connections {
        target: logSaver
        onSaveFinished: {
            notification.close()
            if (success) {
                //% "Saved %1"
                notification.previewBody = qsTrId("logger-sharepage-save-ok").arg(logSaver.archiveFile)
            } else {
                //% "Failed to save %1"
                notification.previewBody = qsTrId("logger-sharepage-save-error").arg(logSaver.archiveFile)
            }
            notification.publish()
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: parent.height

        PullDownMenu {
            visible: _canShare || active
            MenuItem {
                //% "Save to documents"
                text: qsTrId("logger-sharepage-pm-save-to-documents")
                onClicked: logSaver.save()
            }
            onActiveChanged: {
                if (!active && logSaver.saving) {
                    // Copying hasn't finished by the time menu was closed
                    minWaitTimer.start()
                }
            }
        }

        PageHeader {
            id: header
            //% "Pack and send"
            title: qsTrId("logger-sharepage-header")
        }

        ShareMethodList {
            visible: opacity > 0
            opacity: _canShare
            id: shareMethods
            source: logSaver.archivePath
            type: logSaver.archiveType
            //: Default email subject
            //% "Log"
            subject: qsTrId("logger-sharepage-default-subject")
            //: Default email recipient
            //% ""
            emailTo: qsTrId("logger-sharepage-default-email")
            Behavior on opacity { FadeAnimation {} }
            anchors {
                top: header.bottom
                left: parent.left
            }
            VerticalScrollDecorator {}
        }

        Label {
            id: warning
            visible: opacity > 0
            opacity: _canShare
            height: implicitHeight
            Behavior on opacity { FadeAnimation {} }
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraSmall
            verticalAlignment: Text.AlignTop
            color: Theme.secondaryColor
            //% "Keep in mind that some of the information contained in this archive may be considered private. If you would like to check what you are about to send, please consider sending it to yourself and checking its contents first."
            text: qsTrId("logger-sharepage-warning")
        }

        states: [
            State {
                name: "PORTRAIT"
                when: page.orientation === Orientation.Portrait
                AnchorChanges {
                    target: shareMethods
                    anchors {
                        right: parent.right
                        bottom: warning.top
                    }
                }
                PropertyChanges {
                    target: shareMethods
                    anchors.bottomMargin: Theme.paddingLarge
                    anchors.rightMargin: 0
                }
                PropertyChanges {
                    target: warning
                    x: Theme.horizontalPageMargin
                    y: window.height - height - Theme.paddingLarge
                    width: parent.width - 2*Theme.horizontalPageMargin
                }
            },
            State {
                name: "LANDSCAPE"
                when: page.orientation !== Orientation.Portrait
                AnchorChanges {
                    target: shareMethods
                    anchors {
                        right: warning.left
                        bottom: parent.bottom
                    }
                }
                PropertyChanges {
                    target: shareMethods
                    anchors.bottomMargin: 0
                    anchors.rightMargin: Theme.horizontalPageMargin
                }
                PropertyChanges {
                    target: warning
                    x: parent.width - width - Theme.horizontalPageMargin
                    y: header.y + header.height
                    width: parent.width*2/5 - 2*Theme.horizontalPageMargin
                }
            }
        ]
    }

    Column {
        visible: opacity > 0
        opacity: _canShare ? 0 : 1
        anchors.centerIn: parent
        spacing: Theme.paddingLarge
        width: Math.max(busyIndicator.width, pleaseWaitLabel.width)
        Behavior on opacity { FadeAnimation {} }
        BusyIndicator {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Large
            running: !_canShare
        }
        Label {
            id: pleaseWaitLabel
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
            //% "Please wait"
            text: qsTrId("logger-sharepage-please-wait")
        }
    }
}
