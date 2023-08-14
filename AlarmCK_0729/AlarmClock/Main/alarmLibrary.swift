//
//  alarmLibrary.swift
//  AlarmCK_0729
//
//  Created by 王柏崴 on 2023/7/31.
//
import Foundation

import RealmSwift

class ClockTable: Object {
    @Persisted dynamic var notificationID = UUID().uuidString
    @Persisted var time: String = ""
    @Persisted var days: String = ""
    @Persisted var tag: String = ""
    @Persisted var sound: String = ""
    @Persisted var isActive: Bool = true
    @Persisted var isSnooze: Bool = false
    
    
    override static func primaryKey() -> String? {
            return "notificationID"
        }
}
