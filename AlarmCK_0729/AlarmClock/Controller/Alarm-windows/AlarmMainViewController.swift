//
//  AlarmMainViewController.swift
//  AlarmCK_0729
//
//  Created by 王柏崴 on 2023/7/31.
//

import UIKit
import RealmSwift
import UserNotifications

class AlarmMainViewController: UIViewController, UITableViewDelegate {
    
    //MARK: Realm
    var clockArray: [ClockTable] = []
    
    // MARK: - IBOutlet
    @IBOutlet weak var tvAlarm: UITableView!
    
    // MARK: - Variables
    enum AlarmDayState: String {
    case once = "我就僅此奮鬥一次"
    case continuous = "持續奮鬥中💪"
    case workingDays = "社畜模式🐷"
    case weekends = "充實的假日✨"
    }
    
    var selectedTime: Date?


    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tvAlarm.dataSource = self
        tvAlarm.delegate = self
        tvAlarm.separatorStyle = .singleLine
        tvAlarm.separatorColor = .black  //你可以自行設定顏色
        tvAlarm.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)  //你可以自行設定邊緣距離

        tvAlarm.register(UINib(nibName: "AlarmTableViewCell", bundle: nil), forCellReuseIdentifier: AlarmTableViewCell.identified)
        navigationController?.navigationBar.prefersLargeTitles = true
        print("我在這這這這這這")
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let realm = try! Realm()
        clockArray = Array(realm.objects(ClockTable.self))
        
        if UserDefaults.standard.bool(forKey: "shouldTurnOffSwitch") {
            for clock in clockArray {
                if clock.days.contains("我就僅此奮鬥一次") {
                    // 這裡您需要更新資料庫中的開關狀態，然後更新UI
                }
            }
            UserDefaults.standard.set(false, forKey: "shouldTurnOffSwitch")  // 重置標記
        }
        
        clockArray.sort { (clock1, clock2) -> Bool in
            return clock1.time < clock2.time
        }
        
        tvAlarm.reloadData()
    }

    // MARK: - UI Settings
    func setupUI() {
        setupNavigation()
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.barTintColor = .systemGray6
        
        self.title = "鬧鐘"
        
        let btnLeft = UIBarButtonItem(title: "編輯", style: .done, target: self, action: #selector(nbEditAlarm))
        
        navigationItem.leftBarButtonItem = btnLeft
        
        let btnRight = UIBarButtonItem(title: "Add", image: UIImage(systemName: "plus"), target: self, action: #selector(nbAddNewAlarm))
        
        navigationItem.rightBarButtonItem = btnRight
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AlarmTableViewCell {
            cell.isSwiping = true
        }
        navigationItem.leftBarButtonItem?.title = "完成"
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? AlarmTableViewCell {
            cell.isSwiping = false
        }
        navigationItem.leftBarButtonItem?.title = "編輯"
    }
    
    func scheduleNotification(for clock: ClockTable) {
        let identifier = clock.notificationID
        // 如果鬧鐘未激活，則取消通知
        if !clock.isActive {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            return
        }
        // 解析時間
        let clockTime = clock.time
        let amPm = clockTime.prefix(2)
        let hourString = String(clockTime[clockTime.index(clockTime.startIndex, offsetBy: 3)..<clockTime.index(clockTime.startIndex, offsetBy: 5)])
        var hour = Int(hourString) ?? 0
        let minute = Int(clock.time.suffix(2)) ?? 0
        
        // 如果是PM，並且小時不為12時（12 PM 要保持不變），則小時加12
        if amPm == "PM" && hour != 12 {
            hour += 12
        }
        
        // 如果是AM，並且小時為12時（12 AM 應該是0小時），則小時設為0
        if amPm == "AM" && hour == 12 {
            hour = 0
        }
        
        // 從clock物件中獲取代表星期的字串
        let daysString = clock.days
        
        // 調用parseDays函數
        let selectedDays = parseDays(from: daysString)
        
        if selectedDays.isEmpty {
            // 設置觸發條件，不包括weekday
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute

            scheduleNotificationWithComponents(dateComponents, identifier: identifier, clock: clock)

            // 創建當前日期和時間的實例
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current

            // 獲取當前日期的年月日
            let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
            print("當前日期組件：", currentDateComponents)

            // 設置你希望觸發操作的時間
            var triggerComponents = DateComponents()
            triggerComponents.hour = hour
            triggerComponents.minute = minute
            print("觸發時間組件：", triggerComponents)

            // 將觸發時間與當前日期結合
            if let currentDate = calendar.date(from: currentDateComponents),
               let finalTriggerDate = calendar.date(bySettingHour: triggerComponents.hour!, minute: triggerComponents.minute!, second: 0, of: currentDate) {

                print("最終觸發日期和時間：", finalTriggerDate)

                // 如果觸發時間早於當前時間，則添加24小時
                var delay = finalTriggerDate.timeIntervalSince(Date())
                if delay < 0 {
                    delay += 24 * 60 * 60
                }
                print("計算的延遲時間（秒）：", delay)

                // 延遲執行功能
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let realm = try! Realm()
                    if let clockToUpdate = realm.object(ofType: ClockTable.self, forPrimaryKey: clock.notificationID) {
                        try! realm.write {
                            clockToUpdate.isActive = false  // 更新鬧鐘的isActive屬性
                        }
                        self.tvAlarm.reloadData() // 更新表格視圖
                    } else {
                        print("鬧鐘對象已被刪除或失效")
                    }
                }

            }

        } else {
            // 遍歷需要發出提醒的星期天
            for weekday in selectedDays {
                // 設置觸發條件，包括weekday
                var dateComponents = DateComponents()
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.weekday = weekday
                
                scheduleNotificationWithComponents(dateComponents, identifier: identifier, clock: clock)
            }
        }
    }
    
    func scheduleNotificationWithComponents(_ dateComponents: DateComponents, identifier: String, clock: ClockTable) {
        print(dateComponents)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // 設置通知內容
        let content = UNMutableNotificationContent()
        content.title = "Times UP！"
        content.body = clock.tag
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(clock.sound)"+".caf")) // 你的音檔名稱

        // 創建通知請求
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // 添加通知到通知中心
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }

        // 如果isSnooze為true，則添加6分鐘後的通知
        if clock.isSnooze {
            var snoozeComponents = dateComponents
            snoozeComponents.minute = (snoozeComponents.minute ?? 0) + 6

            let snoozeTrigger = UNCalendarNotificationTrigger(dateMatching: snoozeComponents, repeats: false)
            let snoozeRequest = UNNotificationRequest(identifier: identifier + "_snooze", content: content, trigger: snoozeTrigger)
            UNUserNotificationCenter.current().add(snoozeRequest) { error in
                if let error = error {
                    print("Error adding snooze notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    // MARK: - IBAction
    @objc func nbAddNewAlarm() {
        
        // 如果表格處於編輯模式，將其重置為非編輯模式
        if tvAlarm.isEditing {
            tvAlarm.setEditing(false, animated: true)
            navigationItem.leftBarButtonItem?.title = "編輯"
            
            for case let cell as AlarmTableViewCell in tvAlarm.visibleCells {
                cell.swtAction.isHidden = false
            }
        }
        
        let n1 = AddViewController()
        n1.delegate = self  // Set the delegate here
        let navController = UINavigationController(rootViewController: n1)
        present(navController, animated: true, completion: nil)
    }

    
    @objc func nbEditAlarm() {
        if tvAlarm.isEditing {
            tvAlarm.setEditing(false, animated: true)
            navigationItem.leftBarButtonItem?.title = "編輯"
            
            for case let cell as AlarmTableViewCell in tvAlarm.visibleCells {
                cell.swtAction.isHidden = false
            }
        } else {
            tvAlarm.setEditing(true, animated: true)
            tvAlarm.allowsSelectionDuringEditing = true
            navigationItem.leftBarButtonItem?.title = "完成"
            
            for case let cell as AlarmTableViewCell in tvAlarm.visibleCells {
                cell.swtAction.isHidden = true
                cell.editingAccessoryType = .disclosureIndicator
            }
        }
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        if let cell = sender.superview?.superview as? AlarmTableViewCell, let clock = cell.clock {
            let realm = try! Realm()
            try! realm.write {
                clock.isActive = sender.isOn  // 更新鬧鐘的isActive屬性
            }
            scheduleNotification(for: clock) // 重新計劃通知
            cell.updateLabelColor()
        }
    }
}
// MARK: - Extension
extension AlarmMainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 50 {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
}

extension AlarmMainViewController: AddViewControllerDelegate {
    func didAddClock() {
        let realm = try! Realm()
        clockArray = Array(realm.objects(ClockTable.self))
        
        // 進行排序
            clockArray.sort { (clock1, clock2) -> Bool in
                return clock1.time < clock2.time
            }
        
        tvAlarm.reloadData()
        scheduleNotifications()
    }
    

    
    func scheduleNotifications() {
        for clock in clockArray {
            scheduleNotification(for: clock)
        }
    }
    func parseDays(from string: String) -> [Int] {
        var selectedDays: [Int] = []

        if string.contains("1️⃣") { selectedDays.append(2) } // 星期一
        if string.contains("2️⃣") { selectedDays.append(3) } // 星期二
        if string.contains("3️⃣") { selectedDays.append(4) } // 星期三
        if string.contains("4️⃣") { selectedDays.append(5) } // 星期四
        if string.contains("5️⃣") { selectedDays.append(6) } // 星期五
        if string.contains("6️⃣") { selectedDays.append(7) } // 星期六
        if string.contains("7️⃣") { selectedDays.append(1) } // 星期天

        // 檢查特定狀態
        if string.contains(AlarmDayState.once.rawValue) {
            selectedDays = []
        } else if string.contains(AlarmDayState.continuous.rawValue) {
            selectedDays = [2, 3, 4, 5, 6, 7, 1]
        } else if string.contains(AlarmDayState.workingDays.rawValue) {
            selectedDays = [2, 3, 4, 5, 6]
        } else if string.contains(AlarmDayState.weekends.rawValue) {
            selectedDays = [7, 1]
        }
        return selectedDays
    }
}

extension AlarmMainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clockArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmTableViewCell.identified, for: indexPath) as? AlarmTableViewCell else {
            return UITableViewCell()
        }
            
        let clock = clockArray[indexPath.row]
        cell.clock = clock

        let clockTime = clock.time
        let smallFont = UIFont.systemFont(ofSize: 25) // 設定AM/PM
        let largeFont = UIFont.systemFont(ofSize: 45) // 設定hr:min

        let abbreviation = clockTime.prefix(3).description  // 設定AM/PM
        
        let hourString = String(clockTime[clockTime.index(clockTime.startIndex, offsetBy: 3)..<clockTime.index(clockTime.startIndex, offsetBy: 5)])
        
        let minutes = clockTime.dropFirst(5).description    // 設定min


        let attrString = NSMutableAttributedString(string: abbreviation, attributes: [NSAttributedString.Key.font: smallFont])

        attrString.append(NSAttributedString(string: hourString, attributes: [NSAttributedString.Key.font: largeFont]))

        attrString.append(NSAttributedString(string: minutes, attributes: [NSAttributedString.Key.font: largeFont]))

        cell.lbAlarmTime.attributedText = attrString

        cell.lbAlarmDays.text = clock.tag + "，" + clock.days
        cell.swtAction.isOn = clock.isActive // 設定開關的狀態基於鬧鐘的激活狀態
        cell.updateLabelColor()

        cell.swtAction.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)

        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let removeAction = UIContextualAction(style: .normal, title: "移除") { (action, view, completionHandler) in
            
            let realm = try! Realm()
            let clock = realm.objects(ClockTable.self)
            if !clock.isEmpty {
                let clockToRemove = clock[indexPath.row]
                
                try! realm.write {
                    realm.delete(clockToRemove)
                }

                self.clockArray = Array(realm.objects(ClockTable.self))
                tableView.deleteRows(at: [indexPath], with: .automatic)

                completionHandler(true)
            }
            
        }
        removeAction.backgroundColor = UIColor.red
        
        return UISwipeActionsConfiguration(actions: [removeAction])
    }
}

extension AlarmMainViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clock = clockArray[indexPath.row]
        let n1 = AddViewController()
        n1.clock = clock  // 傳遞數據到 AddViewController
        n1.delegate = self
        n1.isEditingExistingClock = true
        let navController = UINavigationController(rootViewController: n1)
        present(navController, animated: true, completion: nil)
    }

}
