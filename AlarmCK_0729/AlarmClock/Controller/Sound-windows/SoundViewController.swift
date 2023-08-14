//
//  SoundViewController.swift
//  AlarmCK_0729
//
//  Created by 王柏崴 on 2023/7/31.
//

// 匯入所需的模組
import UIKit
import AVFoundation

// 定義 SoundViewController 類別，並實現 UITableViewDelegate 和 UITableViewDataSource
class SoundViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tvAlarmSound: UITableView! // 定義關聯的視圖元件
    
    // MARK: -Struct
    struct AlarmSound {
        let description: String  // 描述鈴聲的文字
        let fileName: String     // 音檔名稱
    }

    // MARK: - 變數
    weak var delegate: AlarmSoundDelegate?  // 定義一個 weak 參考的代理
    var alarmSoundText: String?             // 儲存鬧鐘的聲音文字描述
    var alarmSound: String?                 // 儲存鬧鐘的聲音檔案名稱
    var audioPlayer: AVAudioPlayer?         // 儲存音頻播放器
    var selectedSound: String?              // 儲存已選擇的鈴聲

    let alarmSounds: [AlarmSound] = [
        AlarmSound(description: "喔咿喔咿", fileName: "oioi"),
        AlarmSound(description: "啾啾啾", fileName: "gugugu"),
        AlarmSound(description: "嘎嘎嘎", fileName: "kaka"),
        AlarmSound(description: "蒩蒩蒩", fileName: "pupu")
    ]
    
    // MARK: - 生命週期
    override func viewDidLoad() {  // 視圖加載時的生命週期方法
        super.viewDidLoad()
        
        // 註冊自訂的 TableViewCell
        tvAlarmSound.register(AlarmSoundTableViewCell.self,
                              forCellReuseIdentifier: "AlarmSoundTableViewCell")
        // 設置視圖界面
        setupUI()
    }
    
    // MARK: - UI Settings
    func setupUI() {
        setupNavigation()  // 設置導航欄
        setupAlarmSound()  // 設置鬧鐘聲音選項
    }
    
    // 設置導航欄界面
    func setupNavigation() {
        self.title = "鈴聲"                           // 設置導航欄標題為 "鈴聲"
        
        // 創建返回按鈕並設置其圖標和點擊事件
        let btnLeft = UIBarButtonItem(title: "返回", image: UIImage(systemName: "arrowshape.turn.up.left.circle.fill"), target: self, action: #selector(nbBack))
        
        navigationItem.leftBarButtonItem = btnLeft  // 將返回按鈕設置為導航欄的左按鈕
    }
    // 設置鬧鐘聲音表格界面
    func setupAlarmSound() {
        tvAlarmSound.backgroundColor = .lightGray
        
        // 設置表格的代理和數據源為自己
        tvAlarmSound.delegate = self
        tvAlarmSound.dataSource = self
        
        // 設置表格的圓角
        tvAlarmSound.layer.cornerRadius = 10
        tvAlarmSound.layer.masksToBounds = true
        
        tvAlarmSound.layer.borderWidth = 0.5    // 設置表格的邊框寬度
        tvAlarmSound.rowHeight = 35             // 設置表格行高
    }
    // 設置cell數量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmSounds.count
    }
    // 設置cell內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmSoundTableViewCell",
                                                 for: indexPath)
                                                              as! AlarmSoundTableViewCell
        let alarmSound = alarmSounds[indexPath.row]
        
        // 使用模型數據設置單元格的內容
        cell.label.text = alarmSound.description
        cell.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
        cell.imageView?.tintColor = UIColor.blue
        
        let imageView = cell .contentView.subviews[1] as! UIImageView
        // 如果當前行的索引與已選擇的索引相同，則顯示圖像視圖
        
        // 如果當前行的描述與已選擇的描述相同，則顯示圖像視圖
        imageView.isHidden = (selectedSound != alarmSound.description)
        
        // 設置單元格的其他屬性
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        return cell
    }
    
    // 在其他地方更新 selectedIndex
    func setSelectedSound(from string: String) {
        let trimmedSoundText = String(string.dropLast(2)) // 去掉描述末尾的" >"

        let descriptions = ["喔咿喔咿", "啾啾啾", "嘎嘎嘎", "蒩蒩蒩"]
        
        for description in descriptions {
            if description == trimmedSoundText {
                selectedSound = trimmedSoundText
            }
        }
    }

    func displayImageViewAndSetSoundText(for indexPath: IndexPath, in tableView: UITableView) {
        // 取得 cell
        if let cell = tableView.cellForRow(at: indexPath) as? AlarmSoundTableViewCell {
            // 遍歷 cell 中的子視圖
            for subview in cell.contentView.subviews {
                // 如果子視圖是 UIImageView，則顯示它
                if subview is UIImageView {
                    subview.isHidden = false
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 保存選中的鈴聲描述和文件名
        selectedSound = alarmSounds[indexPath.row].description
        alarmSoundText = selectedSound
        alarmSound = alarmSounds[indexPath.row].fileName
        
        // 如果能獲取到音檔的URL，則嘗試播放該音檔
        if let audioURL = Bundle.main.url(forResource: alarmSounds[indexPath.row].fileName, withExtension: "caf") {
            do {
                /// 初始化音頻播放器並開始播放音頻
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.play()
            } catch {
                print("Failed to play the audio file: \(error)")
            }
        }

        // 刷新表格來更新單元格的顯示
        tableView.reloadData()

        // 取消選中的行
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 保存用戶選擇
        saveUserSelection()
    }

    func saveUserSelection() {
        UserDefaults.standard.set(selectedSound, forKey: "selectedSound")
    }

    // MARK: - IBAction
    @objc func nbBack() {
        // 如果已選擇鈴聲文字或音檔名稱，則通過代理方法將其傳遞給其他控制器
        if let alarmSoundText = alarmSoundText {
            delegate?.didSelectedAlarmSound(alarmSoundText)
        }
        if let alarmSound = alarmSound {
            delegate?.didSelectedAlarmSoundFileName(alarmSound)
        }
        // 關閉當前視圖控制器
        self.dismiss(animated: true, completion: nil)
    }
}
