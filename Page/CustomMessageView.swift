//
//  CustomMessageView.swift
//  Page
//
//  Created by Oliver Zhang on 2018/1/17.
//  Copyright © 2018年 Oliver Zhang. All rights reserved.
//

import UIKit

enum RequestStatus: String {
    case ConnectionFailed = "连接服务器失败了"
    case ValidationFaild = "服务器出了点故障，返回的数据无法显示"
    case Success = "更新成功，内容马上显示"
    case NoConnection = "您现在没有联网，显示缓存的内容"
}

struct RequestMessage {
    private static let height: CGFloat = 20
    public static func show(_ status: RequestStatus?, in view: UIView?) {
        if let status = status,
            let view = view {
            let message = status.rawValue
            let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
            let button = UIButton(frame: frame)
            button.setTitle(message, for: .normal)
            button.setBackgroundColor(color: UIColor(hex: "#f2e5da"), forState: .normal)
            button.setTitleColor(UIColor(hex: Color.Content.headline), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.alpha = 0
            view.addSubview(button)
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                button.alpha = 1
            }, completion: { (true) in
                UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    button.center = CGPoint(x: button.center.x, y: -button.center.y)
                }, completion: { (true) in
                    button.removeFromSuperview()
                })
            })
            

            
        }
    }
}
