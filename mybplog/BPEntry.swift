//
//  BPEntry.swift
//  mybplog
//
//  Created by Rodney Witcher on 9/15/18.
//  Copyright © 2018 Pluckshot. All rights reserved.
//

import UIKit

class BPEntry {
    //MARK: init
    init?(_keydatetime: Date, _datetime: Date, _systolic: Int, _diastolic: Int, _pulse: Int, _notes: String?) {
        if _systolic < 0 || _diastolic < 0 || _pulse < 0 {
            return nil
        }
        self.keydatetime = _datetime
        self.datetime = _datetime
        self.systolic = _systolic
        self.diastolic = _diastolic
        self.pulse = _pulse
        self.notes = _notes
    }
    //MARK: properties
    var keydatetime: Date
    var datetime: Date
    var systolic: Int
    var diastolic: Int
    var pulse: Int
    var notes: String?
}
