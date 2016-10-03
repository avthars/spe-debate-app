//
//  DebateRound.swift
//  NavTransition
//
//  Created by Jonathan Yu on 7/15/15.
//  Copyright (c) 2015 App Design Vault. All rights reserved.
//

import UIKit

class DebateRound: NSObject {
    
    var name: String
    var partner: String
    var motion: String
    var format: Bool        // true == APDA, false == BP
    var scoreUser: Double
    var scorePartner: Double
    var result: Bool        // true == Win, false == Loss
    
    init(name: String, partner: String, motion: String, format: Bool, scoreUser: Double, scorePartner: Double, result: Bool) {
        self.name = name
        self.partner = partner
        self.motion = motion
        self.format = format
        self.scoreUser = scoreUser
        self.scorePartner = scorePartner
        self.result = result
    }
    
}
