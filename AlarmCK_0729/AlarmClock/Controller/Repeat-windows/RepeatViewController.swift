//
//  RepeatViewController.swift
//  AlarmCK_0729
//
//  Created by 王柏崴 on 2023/7/31.
//

import UIKit

class RepeatViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tvAlarmWeek: UITableView!
    
    // MARK: - Variables
    weak var delegate: RepeatWeekDelegate?  // 定義一個弱引用的代理，用於與其他ViewController進行通信。
    var selectedDays: [String] = []  // 定義一個選定的天數列表。
    
    // 定義一個Day結構，它有兩個String屬性：symbol和label。
    struct Day {
        var symbol: String
        var label: String
    }
    
    // 定義一週的天數，包括從星期一到星期日的資料。
    let daysOfWeek: [Day] = [
        Day(symbol: "1️⃣", label: "Mon."),
        Day(symbol: "2️⃣", label: "Tue."),
        Day(symbol: "3️⃣", label: "Wed."),
        Day(symbol: "4️⃣", label: "Thu."),
        Day(symbol: "5️⃣", label: "Fri."),
        Day(symbol: "6️⃣", label: "Sat."),
        Day(symbol: "7️⃣", label: "Sun.")
    ]
    
    // 定義一些預設的天數選擇方案。
    let predefinedDays: [String: [String]] = [
        "我就僅此奮鬥一次 >": [],
        "持續奮鬥中💪 >": ["1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣"],
        "社畜模式🐷 >": ["1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣"],
        "充實的假日✨ >": ["6️⃣", "7️⃣"]
    ]
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tvAlarmWeek.reloadData()  // 重新加載表格數據。
        setupUI()                 // 設定用戶界面。
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvAlarmWeek.reloadData()  // 重新加載表格數據。
    }
    // MARK: - UI Settings
    func setupUI() {
        setupNavigation()   // 設定導航欄。
        setuptvAlarmWeek()  // 設定表格視圖。
    }
    
    // 設定導航欄的方法。
    func setupNavigation() {
        self.title = "每週計畫"
        // 創建一個返回按鈕，並將其添加到導航項目的左側。
        let btnLeft = UIBarButtonItem(title: "返回",
                                      image: UIImage(systemName: "arrowshape.turn.up.left.circle.fill"),
                                      target: self,
                                      action: #selector(nbBack))
        
        navigationItem.leftBarButtonItem = btnLeft  // 將返回按鈕設置為導航欄的左按鈕
    }
    
    // 設定表格視圖的方法。
    func setuptvAlarmWeek() {
        tvAlarmWeek.backgroundColor = .lightGray  // 設定表格的背景色為淺灰色。
        tvAlarmWeek.delegate = self               // 設定表格視圖的代理為當前的ViewController。
        tvAlarmWeek.dataSource = self             // 設定表格視圖的數據源為當前的ViewController。
        tvAlarmWeek.register(AlarmWeekTableViewCell.self,
                             forCellReuseIdentifier: "cellIdentifier")  // 註冊表格視圖的單元格類型。
        tvAlarmWeek.layer.cornerRadius = 10       // 設定表格的邊角為圓角。
        tvAlarmWeek.layer.masksToBounds = true    // 開啟邊界裁剪。
        tvAlarmWeek.isScrollEnabled = false       // 禁止滾動表格視圖。
        tvAlarmWeek.layer.borderWidth = 0.5       // 設定表格的邊界寬度。
        tvAlarmWeek.rowHeight = 35                // 設定表格行的高度。
    }
    
    // 這個方法用於配置每一行的單元格。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 從表格視圖中取出一個可重用的單元格。
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier",
                                                 for: indexPath) as! AlarmWeekTableViewCell
        // 從daysOfWeek數組中取出當前行對應的天數數據。
        let day = daysOfWeek[indexPath.row]
        // 檢查單元格內容視圖是否已經有子視圖，如果沒有，則創建標籤和圖像視圖。
        if cell.contentView.subviews.isEmpty {
            // 創建標籤並設定其屬性。
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.white
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 20)
            cell.contentView.addSubview(label)
            
            // 創建圖像視圖並設定其屬性。
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(systemName: "checkmark.circle.fill")
            imageView.tintColor = UIColor.blue
            cell.contentView.addSubview(imageView)
            
            // 設定自動佈局約束
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
                label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                label.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -8),
                
                imageView.widthAnchor.constraint(equalToConstant: 25),
                imageView.heightAnchor.constraint(equalToConstant: 25),
                imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
                imageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
        }
        
        // 假設標籤和圖片視圖是細胞內容視圖的第一個和第二個子視圖，然後更新它們的內容。
        let label = cell.contentView.subviews[0] as! UILabel
        let imageView = cell.contentView.subviews[1] as! UIImageView
        
        // 設定標籤的文字為當前天的名稱。
        label.text = day.label
        // 如果當前的天數已被選中，則顯示圖像視圖，否則隱藏它。
        imageView.isHidden = !selectedDays.contains(day.symbol)
        
        // 設定單元格的背景色和選擇風格。
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    // 這個方法根據給定的字符串來設定selectedDays。
    func setSelectedDays(from string: String) {
        if let days = predefinedDays[string] {
            selectedDays = days          // 如果該字符串在predefinedDays字典中有對應的值，則更新selectedDays。
        } else {
            selectedDays.removeAll()     // 如果該字符串不在predefinedDays字典中，則清空selectedDays。
            
            // 定義一個包含一周所有符號的數組。
            let symbols = ["1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣"]

            // 檢查給定的字符串是否包含每一個符號。
            for symbol in symbols {
                if string.contains(symbol) {
                    selectedDays.append(symbol)  // 如果包含，則將該符號添加到detectedDays中。
                }
            }
        }
    }
    
    // 這個方法返回表格視圖的行數。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return daysOfWeek.count  // 返回daysOfWeek的數量，代表一周的天數。
        }
    
    // 這個方法處理用戶選擇表格視圖的某一行時的行為。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let day = daysOfWeek[indexPath.row]  // 根據選擇的行來獲取天數。
            
        // 檢查選擇的天是否已在selectedDays中。
        if let index = selectedDays.firstIndex(of: day.symbol) {
            selectedDays.remove(at: index)  // 如果已在，則從selectedDays中移除。
        } else {
            selectedDays.append(day.symbol)  // 如果不在，則添加到selectedDays中。
        }
        
        // 重新加載選擇的行，以更新界面。
        tableView.reloadRows(at: [indexPath], with: .automatic)
        saveUserSelection()  // 保存用戶的選擇。
    }
    
    // 這個方法將selectedDays保存到UserDefaults中，以便在應用重啟後還可以獲取。
    func saveUserSelection() {
            UserDefaults.standard.set(selectedDays, forKey: "selectedDays")
        }
    
    // MARK: - IBAction
    @objc func nbBack() {
        selectedDays.sort()  // 在傳遞selectedDays之前對其進行排序。
        // 通知代理有關選擇的天數的更改。
        delegate?.didChangeDaySelection(selectedDays: selectedDays)
        // 關閉當前的視圖控制器。
        self.dismiss(animated: true, completion: nil)    }
}
