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
    case Pending = "正在等待服务器的响应..."
    case Hidden = ""
}

struct RequestMessage {
    private static let height: CGFloat = 20
    public static func update(_ status: RequestStatus?, with button: UIButton?, in view: UIView?) {
        if let status = status,
            let button = button,
            let view = view {
            let message = status.rawValue
            DispatchQueue.main.async {
                button.setTitle(message, for: .normal)
                if status == .Pending {
                    UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        button.center = CGPoint(x: view.center.x, y: button.frame.height/2)
                    })
                } else if status == .Hidden {
                    button.center = CGPoint(x: button.center.x, y: -button.frame.height/2)
                } else {
                    button.center = CGPoint(x: view.center.x, y: button.frame.height/2)
                    button.alpha = 0
                    
                    UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                        button.alpha = 1
                    }, completion: { (true) in
                        UIView.animate(withDuration: 0.5, delay: 1.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                            button.center = CGPoint(x: view.center.x, y: -button.frame.height/2)
                        })
                    })
                    
                }
            }
        }
    }
    
    public static func add(_ status: RequestStatus?, with button: UIButton?, in view: UIView?) {
        if let status = status,
            let view = view,
            let button = button {
            let message = status.rawValue
            let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
            button.frame = frame
            button.autoresizingMask = [.flexibleWidth]
            button.setTitle(message, for: .normal)
            button.setBackgroundColor(color: UIColor(hex: "#f2e5da"), forState: .normal)
            button.setTitleColor(UIColor(hex: Color.Content.lead), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.alpha = 0
            view.addSubview(button)
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                button.alpha = 1
            }, completion: { (true) in
                
            })
        }
    }
}
