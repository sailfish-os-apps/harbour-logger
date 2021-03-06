/*
 * Copyright (C) 2016-2017 Jolla Ltd.
 * Contact: Slava Monich <slava.monich@jolla.com>
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
import harbour.logger.ofono 1.0
import "pages"

ApplicationWindow
{
    id: window
    LoggerHints {
        id: loggerHints
        appName: AppName
    }
    TransferMethodsModel {
        id: transferMethodsModel
        filter: LogSaver.archiveType
    }
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted
    initialPage: Component {
        MainPage {
            customLogMenuItem:  MenuItem {
                id: fixMobileDataMenuItem
                property bool active
                text: OfonoLogger.mobileDataBroken ?
                          //: Pull-down menu item
                          //% "Fix mobile data"
                          qsTrId("ofono-logger-pm-fix-mobile-data") :
                          //: Pull-down menu item
                          //% "Enable mobile data"
                          qsTrId("ofono-logger-pm-enable-mobile-data")

                onClicked: {
                    if (OfonoLogger.mobileDataBroken) {
                        OfonoLogger.fixMobileData()
                    } else {
                        OfonoLogger.enableMobileData()
                    }
                }
                onActiveChanged: updateVisiblity()
                Component.onCompleted: updateVisiblity()
                function updateVisiblity() {
                    if (!active) {
                        visible = OfonoLogger.mobileDataBroken || OfonoLogger.mobileDataDisabled
                    }
                }
            }
            Connections {
                target: OfonoLogger
                onMobileDataBrokenChanged: fixMobileDataMenuItem.updateVisiblity()
                onMobileDataDisabledChanged: fixMobileDataMenuItem.updateVisiblity()
            }
        }
    }
    cover: Component { CoverPage { } }
}
