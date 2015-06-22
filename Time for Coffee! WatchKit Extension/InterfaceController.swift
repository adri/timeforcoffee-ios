      //
//  InterfaceController.swift
//  Time for Coffee! WatchKit Extension
//
//  Created by Christian Stocker on 02.03.15.
//  Copyright (c) 2015 Christian Stocker. All rights reserved.
//

import WatchKit
import Foundation
import timeforcoffeeKit

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var infoLabel: WKInterfaceLabel!
    @IBOutlet weak var infoGroup: WKInterfaceGroup!
    override init () {
        super.init()
        println("init InterfaceController")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            TFCDataStore.sharedInstance.registerForNotifications()
            TFCDataStore.sharedInstance.synchronize()
        }

    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "reloadPages:",
            name: "TFCWatchkitReloadPages",
            object: nil)
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        func handleReply(stations: TFCStations?) {
            infoGroup.setHidden(true)
            if (stations == nil) {
                return
            }
            var pages = [String]()
            var pageContexts = [AnyObject]()
            if let station = stations?[0] {
                pages.append("StationPage")
                var pc = TFCPageContext()
                pc.station = station
                pc.pageNumber = 0
                pageContexts.append(pc)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                    station.updateDepartures(nil)
                    return
                }
            }
            pages.append("StationsOverviewPage")
            pageContexts.append("")
            WKInterfaceController.reloadRootControllersWithNames(pages, contexts: pageContexts)
        }
        func errorReply(text: String) {
            infoGroup.setHidden(false)
            infoLabel.setText(text)
        }

        TFCWatchData.sharedInstance.getStations(handleReply, errorReply: errorReply, stopWithFavorites: false)
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func reloadPages(notification: NSNotification) {
         NSLog("foo")
    }
}
