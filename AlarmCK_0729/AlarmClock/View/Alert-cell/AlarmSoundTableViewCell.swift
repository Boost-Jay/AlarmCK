//
//  AlarmSoundTableViewCell.swift
//  AlarmCK_0729
//
//  Created by 王柏崴 on 2023/8/2.
//

import UIKit

class AlarmSoundTableViewCell: UITableViewCell {

    // 定義一個標籤來顯示文字
    var label: UILabel = {
        let label = UILabel()
        label.textColor = .white // 設置文字顏色
        label.font = UIFont.systemFont(ofSize: 20) // 設置字體大小
        label.textAlignment = .center // 將文字對齊到中間
        return label
    }()
    
    // 初始化方法
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label) // 將標籤添加到單元格內容視圖中
    }
    
    // 布局子視圖方法
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 確保標籤的尺寸佔滿整個單元格，使文字顯示在中間
        label.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
    }
    
    // 由於這個方法尚未實現，所以將其標記為錯誤
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
