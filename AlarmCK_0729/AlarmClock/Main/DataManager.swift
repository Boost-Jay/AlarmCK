//
//  DataManager.swift
//  AlarmCK_0729
//
//  Created by 王柏崴 on 8/8/23.
//

import Foundation
import RealmSwift

// 封裝 Realm 的操作
class DataManager {
    static let shared = DataManager()
    let realm = try! Realm()

    func addClock(_ clock: ClockTable) {
        do {
            try realm.write {
                realm.add(clock)
            }
        } catch {
            print("Error writing to realm, \(error)")
        }
    }

    func updateClock(_ clock: ClockTable, with newClock: ClockTable) {
        do {
            try realm.write {
                clock.time = newClock.time
                clock.days = newClock.days
                clock.tag = newClock.tag
                clock.sound = newClock.sound
            }
        } catch {
            print("Error writing to realm, \(error)")
        }
    }

    func deleteClock(_ clock: ClockTable) {
        do {
            try realm.write {
                realm.delete(clock)
            }
        } catch {
            print("Error writing to realm, \(error)")
        }
    }
}

// 建立一個結構體來存儲常數
struct Constants {
    static let padding: CGFloat = 8
    static let switchWidth: CGFloat = 10
    // 更多的常數...
}

// 使用 enum 管理表格的行
enum TableRow: Int, CaseIterable {
    case repeatRow = 0
    case tagRow
    case soundRow
    case snoozeRow
}
