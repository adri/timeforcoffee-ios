//
//  DepartureLineLabel.swift
//  timeforcoffee
//
//  Created by Jan Hug on 15.03.15.
//  Copyright (c) 2015 Christian Stocker. All rights reserved.
//

import UIKit
import timeforcoffeeKit

class DepartureLineLabel: UILabel, UITableViewDelegate {
    
    let linesWithSymbol = ["ICN", "EN", "ICN", "TGV", "RX", "EC", "IC", "SC", "CNL", "ICE", "IR"]
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.layer.cornerRadius = 4
        self.textAlignment = NSTextAlignment.Center
        self.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.adjustsFontSizeToFitWidth = true
    }

    override func drawTextInRect(rect: CGRect) {
        return super.drawTextInRect(UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)))
    }
    
    func setStyle(style: String, departure: TFCDeparture) {
        self.text = departure.getLine()
        self.layer.borderWidth = 0
        
        if (contains(linesWithSymbol, departure.getLine()) == true) {
            self.font = UIFont(name: "trainsymbol", size: 20)
            self.textColor = UIColor.whiteColor()
            self.backgroundColor = UIColor.redColor()
        } else {
            self.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            self.textColor = UIColor(netHexString: departure.colorFg!)
            
            if (departure.colorBg != "#ffffff") {
                self.backgroundColor = UIColor(netHexString: departure.colorBg!)
            } else {
                self.backgroundColor = UIColor.whiteColor()
                if (style == "normal") {
                    self.layer.borderColor = UIColor.lightGrayColor().CGColor
                    self.layer.borderWidth = 0.5
                }
            }
        }
    }
    
}