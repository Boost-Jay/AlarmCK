//
//  AlarmWeekTableViewCell.swift
//  AlarmCK_0729
//
//  Created by imac-2626 on 2023/8/1.
//

import UIKit

class AlarmWeekTableViewCell: UITableViewCell {

    // 處理單元格高亮狀態的方法
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            contentView.backgroundColor = UIColor.systemGray4 // 如果高亮，設置背景顏色為系統灰色
        } else {
            contentView.backgroundColor = UIColor.clear // 如果不高亮，設置背景顏色為透明
        }
    }

}
