//
//  ClockView.swift
//  AlarmCK_0729
//
//  Created by 王柏崴 on 2023/8/1.
//

import UIKit

class ClockView: UIView {
    var timer: Timer?
    var hoursHand: CAShapeLayer!
    var minutesHand: CAShapeLayer!
    var secondsHand: CAShapeLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        hoursHand = CAShapeLayer()
        hoursHand.strokeColor = UIColor.black.cgColor
        layer.addSublayer(hoursHand)

        minutesHand = CAShapeLayer()
        minutesHand.strokeColor = UIColor.black.cgColor
        layer.addSublayer(minutesHand)

        secondsHand = CAShapeLayer()
        secondsHand.strokeColor = UIColor.red.cgColor
        layer.addSublayer(secondsHand)

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }

    @objc func update() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: Date())
        let hoursAngle = CGFloat(components.hour!) / 12.0 * 2.0 * .pi
        let minutesAngle = CGFloat(components.minute!) / 60.0 * 2.0 * .pi
        let secondsAngle = CGFloat(components.second!) / 60.0 * 2.0 * .pi

        hoursHand.path = UIBezierPath(arcCenter: center, radius: bounds.width / 4, startAngle: .pi / 2, endAngle: .pi / 2 + hoursAngle, clockwise: true).cgPath
        minutesHand.path = UIBezierPath(arcCenter: center, radius: bounds.width / 3, startAngle: .pi / 2, endAngle: .pi / 2 + minutesAngle, clockwise: true).cgPath
        secondsHand.path = UIBezierPath(arcCenter: center, radius: bounds.width / 2.5, startAngle: .pi / 2, endAngle: .pi / 2 + secondsAngle, clockwise: true).cgPath
    }
}

