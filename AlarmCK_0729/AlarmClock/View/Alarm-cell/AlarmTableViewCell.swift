//
//  AlarmTableViewCell.swift
//  AlarmCK_0729
//
//  Created by 王柏崴 on 2023/7/31.
//

import UIKit
import RealmSwift

class AlarmTableViewCell: UITableViewCell {

    @IBOutlet weak var lbAlarmTime: UILabel!
    @IBOutlet weak var lbAlarmDays: UILabel!
    @IBOutlet weak var swtAction: UISwitch!
    
    var clock: ClockTable?
    static let identified = "AlarmTableViewCell"
    var isSwiping: Bool = false {
        didSet {
            swtAction.isHidden = isSwiping
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateLabelColor() {
        if swtAction.isOn {
            lbAlarmTime.textColor = .black
            lbAlarmDays.textColor = .black
        } else {
            lbAlarmTime.textColor = .systemGray
            lbAlarmDays.textColor = .systemGray
        }
    }
}
