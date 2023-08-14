//
//  AddViewController.swift
//  AlarmCK_0729
//
//  Created by 王柏崴 on 2023/7/31.
//


import UIKit
import RealmSwift


class AddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, RepeatWeekDelegate, AlarmSoundDelegate {
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var dpTime: UIDatePicker!  // 定義與時間選擇器視圖的連接
    @IBOutlet weak var tvToolBox: UITableView! // 定義與工具箱表格視圖的連接
    @IBOutlet weak var btnDelete: UIButton!   // 定義與刪除按鈕的連接
    
    // MARK: - Variables
    var lbRepeatDetail: UILabel?              // 定義重複詳情的標籤
    var lbAlarmSoundDetail: UILabel?          // 定義鬧鐘聲音詳情的標籤
    var alarmSoundFileName: String?           // 定義鬧鐘聲音文件名稱
    var txfTag: UITextField?                  // 定義標籤的文字輸入框
    weak var delegate: AddViewControllerDelegate? // 定義一個 weak 參考的代理
    var clock: ClockTable?                    // 定義鬧鐘物件
    var isEditingExistingClock: Bool = false  // 定義是否正在編輯現有鬧鐘的標記


    var isSnoozeEnabled: Bool = false

    
    // 創建日期格式器
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a hh:mm"       // 設定日期的格式
        return formatter
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 註冊自訂的 TableViewCell
        tvToolBox.register(ToolBoxTableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        // 設置視圖介面
        setupUI()
        
        // 如果有指定鬧鐘，則顯示刪除按鈕
        btnDelete.isHidden = (clock == nil)
        
        // 如果有指定鬧鐘，則設置時間選擇器的時間為鬧鐘的時間
        if let clockToDisplay = clock {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "a hh:mm"
            if let date = dateFormatter.date(from: clockToDisplay.time) {
                dpTime.date = date
            }
        }
    }
    
    // MARK: - UI Settings
    
    // 設置視圖介面
    func setupUI() {
        setuptvToolBox()   // 設置工具箱表格視圖
        setupdpTime()      // 設置時間選擇器
        setupNavigation()  // 設置導航欄
        setupbtnDelete()   // 設置刪除按鈕
    }
    
    // 設置刪除按鈕的介面
    func setupbtnDelete() {
        btnDelete.layer.cornerRadius = 10
        btnDelete.layer.masksToBounds = true
        btnDelete.layer.borderWidth = 0.5
        btnDelete.layer.borderColor = UIColor.systemRed.cgColor
        btnDelete.backgroundColor = .lightGray
    }
    
    // 設置導航欄介面
    func setupNavigation() {
        self.title = "新增鬧鐘"   // 設置導航欄的標題為 "新增鬧鐘"
        
        // 創建取消按鈕並設置其點擊事件
        let btnLeft = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(nbCancel))
        
        navigationItem.leftBarButtonItem = btnLeft  // 將取消按鈕設置為導航欄的左按鈕
                            
        // 創建儲存按鈕並設置其點擊事件
        let btnRight = UIBarButtonItem(title: "儲存", style: .done, target: self, action: #selector(nbSafe))
        
        navigationItem.rightBarButtonItem = btnRight  // 將儲存按鈕設置為導航欄的右按鈕
    }
    
    // 設置工具箱表格視圖介面
    func setuptvToolBox() {
        tvToolBox.backgroundColor = .lightGray   // 設置表格視圖的背景顏色為淺灰色
        tvToolBox.delegate = self                // 設置表格視圖的代理為自己
        tvToolBox.dataSource = self              // 設置表格視圖的數據源為自己
        // 註冊自訂的 TableViewCell
        tvToolBox.register(ToolBoxTableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        tvToolBox.layer.cornerRadius = 10        // 設置表格視圖的圓角
        tvToolBox.layer.masksToBounds = true     // 啟用表格視圖的邊界修剪
        tvToolBox.isScrollEnabled = false        // 禁止表格視圖的滾動
        tvToolBox.layer.borderWidth = 0.5        // 設置表格視圖的邊框寬度
        tvToolBox.rowHeight = 37.4               // 設置表格視圖的行高
    }
    
    // 設置時間選擇器介面
    func setupdpTime() {
        dpTime.datePickerMode = .time            // 設置時間選擇器的模式為時間模式
        dpTime.locale = Locale(identifier: "zh_TW")  // 設置時間選擇器的語言為繁體中文
        if #available(iOS 14, *) {
            dpTime.preferredDatePickerStyle = .wheels  // 如果系統版本大於等於14，設置時間選擇器的風格為輪盤風格
        }
        dpTime.date = Date()                    // 設置時間選擇器的初始時間為現在的時間
        dpTime.frame = CGRect(x: 8, y: dpTime.frame.origin.y, width: view.bounds.width - 16, height: dpTime.frame.height)  // 設置時間選擇器的位置和大小
    }
    
    // 設置表格視圖的單元格內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = TableRow(rawValue: indexPath.row) else { return UITableViewCell() }  // 獲取當前行的 TableRow 枚舉值
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! ToolBoxTableViewCell  // 重用或創建一個新的 ToolBoxTableViewCell
        configureCell(cell, for: row)  // 根據當前行的 TableRow 枚舉值來設置單元格的內容
        return cell
    }
    
    // 根據給定的 TableRow 枚舉值來設置單元格的內容
    func configureCell(_ cell: ToolBoxTableViewCell, for row: TableRow) {
        
        // 清除單元格內容視圖中的所有子視圖
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        // 根據 TableRow 枚舉值來設置單元格的內容
        switch row {
        case .repeatRow:
            // 第一行：設置重複詳情的標籤
            _ = createLabel(in: cell, text: "每週計畫", textColor: UIColor.white, fontSize: 20, alignment: .left)
            lbRepeatDetail = createLabel(in: cell, text: "我就僅此奮鬥一次 >", textColor: UIColor.systemBlue, fontSize: 18, alignment: .right)
            if let clockToDisplay = clock {
                lbRepeatDetail?.text = (clockToDisplay.days ) + " >"
            } else {
                lbRepeatDetail?.text = "我就僅此奮鬥一次 >"
            }

        case .tagRow:
            // 第二行：設置標籤的文字輸入框
            _ = createLabel(in: cell, text: "標籤", textColor: UIColor.white, fontSize: 20, alignment: .left)
            txfTag = createTextField(in: cell, placeholder: "鬧鐘", textColor: UIColor.gray, alignment: .right, keyboardType: .default)
            if let clockToDisplay = clock {
                let textWithoutLastCharacter = String(clockToDisplay.tag)
                if textWithoutLastCharacter == "鬧鐘" {
                    txfTag?.text = ""
                } else {
                    txfTag?.text = textWithoutLastCharacter
                }
            }
        case .soundRow:
            // 第三行：設置鬧鐘聲音詳情的標籤
            _ = createLabel(in: cell, text: "鈴聲", textColor: UIColor.white, fontSize: 20, alignment: .left)
            lbAlarmSoundDetail = createLabel(in: cell, text: "🈚️ >", textColor: UIColor.systemBlue, fontSize: 16, alignment: .right)
            if let clockToDisplay = clock {
                lbAlarmSoundDetail?.text = alarmSoundText(from: clockToDisplay.sound) + " >"
            }
        case .snoozeRow:
            // 第四行：設置偷懶模式的開關
        _ = createLabel(in: cell, text: "偷懶模式", textColor: UIColor.white, fontSize: 20, alignment: .left)
        let font = UIScreen.main.bounds.width
        let padding: CGFloat = Constants.padding
        let switchWidth: CGFloat = Constants.switchWidth
        let swtSnooze = UISwitch(frame: CGRect(x: font - 11*padding, y: (cell.contentView.bounds.height - 31)/2, width: switchWidth, height: 31))
        swtSnooze.onTintColor = UIColor.systemBlue
        swtSnooze.thumbTintColor = UIColor.white
        swtSnooze.tintColor = UIColor.lightGray
        swtSnooze.isOn = clock?.isSnooze ?? false // 設置 swtSnooze 的初始狀態
        swtSnooze.addTarget(self, action: #selector(snoozeSwitchChanged(_:)), for: .valueChanged) // 添加開關事件處理
        cell.contentView.addSubview(swtSnooze)

        }
        cell.backgroundColor = .clear  // 設置單元格的背景顏色為透明
        cell.selectionStyle = .none    // 設置單元格的選擇風格為無
    }

    // 創建標籤
    func createLabel(in cell: ToolBoxTableViewCell, text: String, textColor: UIColor, fontSize: CGFloat, alignment: NSTextAlignment) -> UILabel {
        let padding: CGFloat = 8
        let label = UILabel(frame: CGRect(x: padding, y: 0, width: cell.contentView.bounds.width , height: cell.contentView.bounds.height))
        label.text = text
        label.textColor = textColor
        label.textAlignment = alignment
        label.font = UIFont.systemFont(ofSize: fontSize)
        cell.contentView.addSubview(label) // 將創建的標籤添加到單元格內容視圖中
        return label
    }
    
    // 創建文字輸入框
    func createTextField(in cell: ToolBoxTableViewCell, placeholder: String, textColor: UIColor, alignment: NSTextAlignment, keyboardType: UIKeyboardType) -> UITextField {
        let padding: CGFloat = 8
        let font = UIScreen.main.bounds.width
        let textField = UITextField(frame: CGRect(x: 55,
                                                  y: 0,
                                                  width: font - 12*padding,
                                                  height: cell.contentView.bounds.height))
        textField.placeholder = placeholder
        textField.textColor = textColor
        textField.textAlignment = alignment
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.isUserInteractionEnabled = true
        textField.delegate = self
        cell.contentView.addSubview(textField) // 將創建的文字輸入框添加到單元格內容視圖中
        return textField
    }
    
    // 從聲音文件名稱獲取相應的鬧鐘聲音文本
    func alarmSoundText(from sound: String) -> String {
        
        switch sound {
        case "oioi":
            return "喔咿喔咿"
        case "gugugu":
            return "啾啾啾"
        case "kaka":
            return "嘎嘎嘎"
        case "pupu":
            return "蒩蒩蒩"
        default:
            return "🈚️"  // 預設值或未知的聲音檔案名稱
        }
    }
    
    // 表格視圖的行數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return TableRow.allCases.count
    }
    
    // 表格視圖選取行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch TableRow(rawValue: indexPath.row) {
        case .repeatRow:     // 選擇重複行時的處理
            handleRepeatRowSelection()
        case .tagRow:        // 選擇標籤行時的處理
            handleTagRowSelection(at: indexPath)
        case .soundRow:      // 選擇聲音行時的處理
            handleSoundRowSelection()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)  // 取消選擇該行
    }
    
    // 處理重複行選擇
    func handleRepeatRowSelection() {
        let winRepeat = RepeatViewController()
        if let repeatText = lbRepeatDetail?.text {
            winRepeat.setSelectedDays(from: repeatText)
        }
        winRepeat.delegate = self
        let RepeatController = UINavigationController(rootViewController: winRepeat)
        present(RepeatController, animated: true, completion: nil)
    }

    // 處理標籤行選擇
    func handleTagRowSelection(at indexPath: IndexPath) {
        if let cell = tvToolBox.cellForRow(at: indexPath) as? ToolBoxTableViewCell,
            let txfTag = cell.contentView.subviews.first(where: { $0 is UITextField }) as? UITextField {
            txfTag.becomeFirstResponder()
        }
    }

    // 處理聲音行選擇
    func handleSoundRowSelection() {
        let winSound = SoundViewController()
        if let soundText = lbAlarmSoundDetail?.text {
            winSound.setSelectedSound(from: soundText)
        }
        winSound.delegate = self
        let SoundController = UINavigationController(rootViewController: winSound)
        present(SoundController, animated: true, completion: nil)
    }

    // 更新鬧鐘資料
    func updateClock(_ clock: ClockTable) {
        do {
            let realm = try Realm()                                  // 嘗試創建Realm的實例
            try realm.write {                                        // 開始寫入事務
                let dateFormatter = DateFormatter()                  // 創建日期格式器
                dateFormatter.dateFormat = "a hh:mm"                 // 設置日期格式
                clock.time = dateFormatter.string(from: dpTime.date) // 設置鬧鐘的時間
                clock.days = String((lbRepeatDetail?.text ?? "").dropLast(2)) // 設置鬧鐘的重複天數
                if let cell = tvToolBox.cellForRow(at: IndexPath(row: 1, section: 0)) as? ToolBoxTableViewCell,
                   let txfTag = cell.contentView.subviews.first(where: { $0 is UITextField }) as? UITextField {
                    // 設置鬧鐘的標籤
                    clock.tag = (txfTag.text?.isEmpty ?? true) ? "鬧鐘" : (txfTag.text!)
                }
                clock.sound = alarmSoundFileName ?? ""               // 設置鬧鐘的聲音文件名
            }
        } catch {
            // 處理與Realm相關的錯誤
            print("Error writing to Realm: \(error)")
        }
    }
    // MARK: - IBAction
    // 儲存按鈕的點擊處理
    @objc func nbSafe() {
        do {
            let realm = try Realm() // 嘗試創建Realm的實例
            // 根據是否正在編輯現有鬧鐘，決定是更新還是創建新的鬧鐘
            let clockToSave = isEditingExistingClock ? self.clock : ClockTable()

            if let clock = clockToSave {
                updateClock(clock)       // 更新或創建鬧鐘
                if !isEditingExistingClock {
                    try realm.write {
                        realm.add(clock) // 如果是創建新的鬧鐘，則將其添加到Realm中
                        clock.isSnooze = isSnoozeEnabled // 使用isSnoozeEnabled屬性更新鬧鐘的isSnooze屬性
                    }
                }
            }
            delegate?.didAddClock()      // 通知代理已添加鬧鐘
            self.dismiss(animated: true, completion: nil) // 關閉視圖控制器
        } catch {
            // 處理與Realm相關的錯誤
            print("Error initializing Realm or saving data: \(error)")
        }
    }

     
    @objc func nbCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {
            if let clock = clock {
                DataManager.shared.deleteClock(clock)
                delegate?.didAddClock()
            }
            self.dismiss(animated: true, completion: nil) // 關閉視圖控制器
        }
    
    @objc func snoozeSwitchChanged(_ sender: UISwitch) {
        isSnoozeEnabled = sender.isOn
        if let clockToUpdate = self.clock {
            let realm = try! Realm()
            try! realm.write {
                clockToUpdate.isSnooze = sender.isOn  // 更新鬧鐘的isSnooze屬性
            }
        }
    }

}

// MARK: - Extension
extension AddViewController {
    // 定義當按下鍵盤上的返回鍵時，鍵盤應如何回應
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 讓當前的文字輸入框失去焦點，使鍵盤消失
        return true
    }
}
extension AddViewController {
    // 定義當選擇了重複的天數時應如何更新UI
    func didChangeDaySelection(selectedDays: [String]) {
        
        let weekdays = ["1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣"]
        let weekends = ["6️⃣", "7️⃣"]
        
        // 根據選擇的天數，更新重複詳情標籤的文字
        if selectedDays.isEmpty {
            lbRepeatDetail?.text = "我就僅此奮鬥一次 >"
            return
        } else if selectedDays.count == 7 {
            lbRepeatDetail?.text = "持續奮鬥中💪 >"
            return
        } else if weekdays.allSatisfy({selectedDays.contains($0)}) && selectedDays.count == 5 {
            lbRepeatDetail?.text = "社畜模式🐷 >"
            return
        } else if weekends.allSatisfy({selectedDays.contains($0)}) && selectedDays.count == 2 {
            lbRepeatDetail?.text = "充實的假日✨ >"
            return
        } else {
            lbRepeatDetail?.text = selectedDays.joined(separator: ", ") + " >"
        }
    }
}

extension AddViewController {
    // 定義當選擇了鬧鐘聲音時應如何更新UI
    func didSelectedAlarmSound(_ alarmSoundText: String) {
        DispatchQueue.main.async {
            self.lbAlarmSoundDetail?.text = alarmSoundText + " >"
        }
    }
    // 定義當選擇了鬧鐘聲音文件名稱時應如何更新相關變數
    func didSelectedAlarmSoundFileName(_ alarmSoundFileName: String) {
            self.alarmSoundFileName = alarmSoundFileName
        }
}
// MARK: - Protocol
protocol RepeatWeekDelegate: AnyObject {
    // 定義一個協議，允許代理對象響應選擇了重複的天數的事件
    func didChangeDaySelection(selectedDays: [String])
}

protocol AlarmSoundDelegate: AnyObject {
    // 定義一個協議，允許代理對象響應選擇了鬧鐘聲音的事件
    func didSelectedAlarmSound(_ alarmSound: String)
    func didSelectedAlarmSoundFileName(_ alarmSoundFileName: String)
}

protocol AddViewControllerDelegate: AnyObject {
    // 定義一個協議，允許代理對象響應添加鬧鐘的事件
    func didAddClock()
}


