//
//  CustomRefreshConrolView.swift
//  Page
//
//  Created by huiyun.he on 09/01/2018.
//  Copyright © 2018 Oliver Zhang. All rights reserved.
//

import Foundation
//刷新Label的text
let normalTitle = "下拉刷新"
let pullingTitle = "松开立即请求"
let refreshingTitle = "正在刷新"

//当下拉到转完圈之前一直是“下拉刷新”，刚转完之后就变成“松开立即请求”，松手之后，变成“正在刷新”，当刷新完成就恢复为“下拉刷新”（即原始状态，复原）
//第一步：考虑怎么绘制转圈？根据contentOffset值来确定高度，圈的显示多少跟contentOffset有个正比关系；怎么有转圈动画呢？应该有个参数，设置动画为true。
//第二步：监听ScrollView正在拖动的和拖动结束的状态；触摸开始，下拉，触摸结束，把这些状态变化，怎么监听动作？



enum refreshState{
    case normal
    case pulling
    case refreshing
}

class RefreshConrolView: UIRefreshControl {
    let refreshHeight: CGFloat = 60
    let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    var originalOffsetY: CGFloat?
    lazy var backgroundView: UIView = UIView()
    var refreshTarget: AnyObject?
    var refreshAction: Selector?
    lazy var imageView: UIImageView = UIImageView()
    lazy var label: UILabel = UILabel()
    lazy var pullToRefreshButton :UIButtonPullToRefresh = UIButtonPullToRefresh()
    var currentStatus: refreshState? {
        didSet{
            //根据state的改变，修改相关状态
            self.setCurrentState(currentState: currentStatus!)
        }
    }
    lazy var superScrollView: UIScrollView = UIScrollView()
    lazy var refreshingImages: [UIImage] = [UIImage]()
    
    init(target: AnyObject, refreshAction: Selector){
        super.init()
        //设置Refresh的大小
        self.frame = CGRect(x: 0, y: -60, width: screenWidth, height: 60)
        self.refreshTarget = target
        self.refreshAction = refreshAction
        setupUIInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置UI初始化
    private func setupUIInit(){
        self.tintColor = UIColor.clear
        
        self.backgroundView = UIView.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: refreshHeight))
        self.backgroundColor = UIColor.clear
        self.addSubview(self.backgroundView)
        
        self.label.textColor = UIColor.darkGray
        self.label.font = UIFont.systemFont(ofSize: 14)
        self.label.textAlignment = .left
        self.label.text = NSLocalizedString(normalTitle, comment: "")
        self.label.sizeToFit()
        self.backgroundView.addSubview(self.label)
        
        pullToRefreshButton.progress = 0
        self.backgroundView.addSubview(self.pullToRefreshButton)
        pullToRefreshButton.drawCircle()
        
        //设置最开始的状态
        self.currentStatus = refreshState.normal
        self.updateFrame()
    }
    
    //设置控件的大小
    private func updateFrame(){
        let totalWidth: CGFloat = 35 + 20 + self.label.bounds.size.width
        let imageViewX: CGFloat = (screenWidth - totalWidth) / 2
      
        self.label.frame = CGRect(x: imageViewX + 35 + 20, y: (refreshHeight - self.label.bounds.size.height)/2, width: label.bounds.size.width, height: self.label.bounds.size.height)
        self.pullToRefreshButton.frame = CGRect(x: 120, y: CGFloat(15), width: CGFloat(24), height: CGFloat(24))
    }
    
    //TODO: - 释放监听
    deinit{
        self.superScrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    //TODO: - KVO 监听用户操作
    override func willMove(toSuperview newSuperview: UIView?) {
        if (newSuperview?.isKind(of: UIScrollView.superclass()!))!{
            
            self.superScrollView = newSuperview as! UIScrollView
            self.superScrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    var endRefresh = false;
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("refreshControl fresh--\(self.isRefreshing)-- isDragging:\(self.superScrollView.isDragging) --originalOffsetY:\(self.superScrollView.contentInset.top)---值为\(self.superScrollView.contentOffset.y)")
        if self.superScrollView.isDragging && !self.isRefreshing{
            if self.originalOffsetY == nil {
                self.currentStatus = refreshState.normal
                self.originalOffsetY = -self.superScrollView.contentInset.top
            }
            let normalPullingOffset: CGFloat = self.originalOffsetY! - refreshHeight

            if self.currentStatus == refreshState.normal && self.superScrollView.contentOffset.y > normalPullingOffset{
                self.currentStatus = refreshState.normal
            }else if  self.currentStatus == refreshState.normal && self.superScrollView.contentOffset.y < normalPullingOffset{
                self.currentStatus = refreshState.pulling
            }
            
        }else if !self.superScrollView.isDragging{
            if self.currentStatus == refreshState.pulling{
                self.currentStatus = refreshState.refreshing
            }
        }
        self.pullToRefreshButton.drawCircle()
        let pullDistance: CGFloat = -self.frame.origin.y
        //      pullDistance = MIN(60, -self.frame.origin.y); 悬浮在顶部
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: pullDistance)
        let totalWidth = 35 + 20 + self.label.bounds.size.width
        let imageViewX = (screenWidth - totalWidth)/2

        self.label.frame = CGRect(x: imageViewX + 35 + 20, y: -refreshHeight + pullDistance + (refreshHeight - self.label.bounds.size.height)/2, width: self.label.frame.size.width, height: self.label.frame.size.height)
        
        self.pullToRefreshButton.frame = CGRect(x: 120, y: -refreshHeight+pullDistance+(refreshHeight-self.pullToRefreshButton.bounds.size.height)/2, width: self.pullToRefreshButton.bounds.size.width, height: self.pullToRefreshButton.bounds.size.height)
        self.pullToRefreshButton.progress = Float(pullDistance)/Float(refreshHeight)
    }
    
    
    func setCurrentState(currentState: refreshState){
        
        switch currentState{
        case refreshState.normal:
            print("切换到Normal")
            self.label.text = normalTitle
            self.label.sizeToFit()

        case refreshState.pulling:
            print("切换到Pulling")
            self.label.text = pullingTitle
            self.label.sizeToFit()
        case refreshState.refreshing:
            self.beginRefreshing()
            self.label.text = refreshingTitle
            self.label.sizeToFit()
            doRefreshAction()
        }
    }
    //刷新状态执行的方法
    fileprivate func doRefreshAction(){
        print("开始刷新动作")
        if (self.refreshTarget?.responds(to: self.refreshAction))!{
            self.refreshTarget?.performSelector(inBackground: self.refreshAction!, with: nil)
        }
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
         print("开始刷新")
    }
    override func endRefreshing() {
        super.endRefreshing()
        if self.currentStatus != refreshState.refreshing{
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let when = DispatchTime.now() + 0.4 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.currentStatus = refreshState.normal
            }
            
        }
    }
    
}

class UIButtonPullToRefresh: UIButton {
    var progress: Float = 0 {
        didSet {
            circleShape.strokeEnd = CGFloat(self.progress)
            print("progress--\(progress)")
        }
    }
    
    var circleShape = CAShapeLayer()
    public func drawCircle() {
        let x: CGFloat = 0.0
        let y: CGFloat = 0.0
        let circlePath = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: self.frame.height, height: self.frame.height), cornerRadius: self.frame.height / 2).cgPath
        circleShape.path = circlePath
        circleShape.lineWidth = 2
//        circleShape.strokeColor = UIColor.brown.cgColor
        circleShape.strokeColor = UIColor(hex: "#c2272f").cgColor
        circleShape.strokeStart = 0
        circleShape.strokeEnd = 0
        circleShape.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(circleShape)
    }
    

}

