//
//  SoundViewController.swift
//  AlarmCK_0729
//
//  Created by 王柏崴 on 2023/7/31.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tvAlarmSound: UITableView!
    
    // MARK: - Variables
    weak var delegate: AlarmSoundDelegate?
    var alarmSoundText: String?
    var alarmSound: String?
    var audioPlayer: AVAudioPlayer?

    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvAlarmSound.register(AlarmSoundTableViewCell.self, forCellReuseIdentifier: "AlarmSoundTableViewCell")
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - UI Settings
    
    func setupUI() {
        setupNavigation()
        setupAlarmSound()
    }
    
    func setupNavigation() {
        
        self.title = "鈴聲"
        let btnLeft = UIBarButtonItem(title: "返回", image: UIImage(systemName: "arrowshape.turn.up.left.circle.fill"), target: self, action: #selector(nbBack))
        
        navigationItem.leftBarButtonItem = btnLeft
        
    }
    
    func setupAlarmSound() {
        tvAlarmSound.backgroundColor = .lightGray
        tvAlarmSound.delegate = self
        tvAlarmSound.dataSource = self
        tvAlarmSound.layer.cornerRadius = 10
        tvAlarmSound.layer.masksToBounds = true
        tvAlarmSound.isScrollEnabled = false
        tvAlarmSound.layer.borderWidth = 0.5
        tvAlarmSound.rowHeight = 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmSoundTableViewCell", for: indexPath) as! AlarmSoundTableViewCell
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        var font = UIScreen.main.bounds.width
        let padding: CGFloat = 8
        
        switch indexPath.row {
            
        case 0:
            let lb1 = UILabel(frame: CGRect(x: 0, y: 0, width: font - padding*6, height: cell.contentView.bounds.height))
            lb1.text = "喔咿喔咿"
            lb1.textColor = .white
            lb1.font = UIFont.systemFont(ofSize: 20)
            lb1.textAlignment = .center
            cell.contentView.addSubview(lb1)
            
            let img1 = UIImageView(frame: CGRect(x: padding, y: 5, width: 25, height: 25))
            img1.image = UIImage(systemName: "checkmark.circle.fill")
            img1.tintColor = UIColor.blue
            img1.isHidden = true
            cell.contentView.addSubview(img1)
            
        case 1:
            let lb2 = UILabel(frame: CGRect(x: 0, y: 0, width: font - padding*6, height: cell.contentView.bounds.height))
            lb2.text = "啾啾啾"
            lb2.textColor = .white
            lb2.font = UIFont.systemFont(ofSize: 20)
            lb2.textAlignment = .center
            cell.contentView.addSubview(lb2)
            
            let img2 = UIImageView(frame: CGRect(x: padding, y: 5, width: 25, height: 25))
            img2.image = UIImage(systemName: "checkmark.circle.fill")
            img2.tintColor = UIColor.blue
            img2.isHidden = true
            cell.contentView.addSubview(img2)
            
        case 2:
            let lb3 = UILabel(frame: CGRect(x: 0, y: 0, width: font - padding*6, height: cell.contentView.bounds.height))
            lb3.text = "嘎嘎嘎"
            lb3.textColor = .white
            lb3.font = UIFont.systemFont(ofSize: 20)
            lb3.textAlignment = .center
            cell.contentView.addSubview(lb3)
            
            let img3 = UIImageView(frame: CGRect(x: padding, y: 5, width: 25, height: 25))
            img3.image = UIImage(systemName: "checkmark.circle.fill")
            img3.tintColor = UIColor.blue
            img3.isHidden = true
            cell.contentView.addSubview(img3)
            
        case 3:
            let lb4 = UILabel(frame: CGRect(x: 0, y: 0, width: font - padding*6, height: cell.contentView.bounds.height))
            lb4.text = "蒩蒩蒩"
            lb4.textColor = .white
            lb4.font = UIFont.systemFont(ofSize: 20)
            lb4.textAlignment = .center
            cell.contentView.addSubview(lb4)
            
            let img4 = UIImageView(frame: CGRect(x: padding, y: 5, width: 25, height: 25))
            img4.image = UIImage(systemName: "checkmark.circle.fill")
            img4.tintColor = UIColor.blue
            img4.isHidden = true
            cell.contentView.addSubview(img4)
            
        default:
            break
        }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedSoundText: String
        var selectedSound: String
        
        if indexPath.row == 0 {
            let cell = tableView.cellForRow(at: indexPath) as! AlarmSoundTableViewCell
            for subview in cell.contentView.subviews {
                if subview is UIImageView {
                    subview.isHidden = false
                }
            }
            alarmSoundText = "喔咿喔咿"
        } else if indexPath.row == 1 {
            let cell = tableView.cellForRow(at: indexPath) as! AlarmSoundTableViewCell
            for subview in cell.contentView.subviews {
                if subview is UIImageView {
                    subview.isHidden = false
                }
            }
            
        alarmSoundText = "啾啾啾"
        } else if indexPath.row == 2 {
            let cell = tableView.cellForRow(at: indexPath) as! AlarmSoundTableViewCell
            for subview in cell.contentView.subviews {
                if subview is UIImageView {
                    subview.isHidden = false
                }
            }
            
        alarmSoundText = "嘎嘎嘎"
        } else if indexPath.row == 3 {
            let cell = tableView.cellForRow(at: indexPath) as! AlarmSoundTableViewCell
            for subview in cell.contentView.subviews {
                if subview is UIImageView {
                    subview.isHidden = false
                }
            }
            
        alarmSoundText = "蒩蒩蒩"
        }
        switch indexPath.row {
            case 0:
                selectedSoundText = "喔咿喔咿"
                selectedSound = "oioi"
            
            case 1:
                selectedSoundText = "啾啾啾"
                selectedSound = "gugugu"
            case 2:
                selectedSoundText = "嘎嘎嘎"
                selectedSound = "kaka"
            case 3:
                selectedSoundText = "蒩蒩蒩"
                selectedSound = "pupu"
            default:
                return
            }
        alarmSoundText = selectedSoundText
        alarmSound = selectedSound
        
        // Get the URL of the audio file
        if let audioURL = Bundle.main.url(forResource: selectedSound, withExtension: "caf") {
            do {
                // Initialize the audio player and start playing the audio
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.play()
            } catch {
                print("Failed to play the audio file: \(error)")
            }
        }
        
        // Now, let's update the visibility of the checkmark for all cells.
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? AlarmSoundTableViewCell {
                for subview in cell.contentView.subviews {
                    if let imageView = subview as? UIImageView {
                        imageView.isHidden = row != indexPath.row
                    }
                }
            }
        }


        // Now, let's update the visibility of the checkmark for all cells.
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? AlarmSoundTableViewCell {
                for subview in cell.contentView.subviews {
                    if let imageView = subview as? UIImageView {
                        imageView.isHidden = row != indexPath.row
                    }
                }
            }
        }
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    // MARK: - IBAction
    @objc func nbBack() {
        if let alarmSoundText = alarmSoundText {
            delegate?.didSelectedAlarmSound(alarmSoundText)
        }
        if let alarmSound = alarmSound {
            delegate?.didSelectedAlarmSoundFileName(alarmSound)
        }
        self.dismiss(animated: true, completion: nil)
    }}
// MARK: - Extension

// MARK: - Protocol
 
我希望你能幫我把前60行功能的註解用繁體中文寫出來
