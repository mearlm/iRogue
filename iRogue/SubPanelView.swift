//
//  SubPanelView.swift
//  iRogue
//
//  Created by Michael McGhan on 8/12/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

class SubPanelView: UIStackView {
    public enum PanelEnum {
        case LeftTop
        case RightBottom
        case Both
        case Either
    }
    
    private var minWidth: (lt: CGFloat, rb: CGFloat)?
    private var minHeight: (lt: CGFloat, rb: CGFloat)?
    
    private lazy var leftTopView: UIView = { [unowned self] in
        return self.arrangedSubviews[0]
    }()

    private lazy var rightBottomView: UIView = { [unowned self] in
        return self.arrangedSubviews[1]
    }()
    
    public func setup(minWidth: (CGFloat, CGFloat)?, minHeight: (CGFloat, CGFloat)?) {
        self.minWidth = minWidth
        self.minHeight = minHeight
    }
    
    public func isShowLeftTop() -> Bool {
        return !self.leftTopView.isHidden
    }
    
    public func isShowRightBottom() -> Bool {
        return !self.rightBottomView.isHidden
    }
    
    public func isShowBoth() -> Bool {
        return isShowRightBottom() && isShowLeftTop()
    }
    
    public func isShowEither() -> Bool {
        return isShowRightBottom() || isShowLeftTop()
    }
    
    private func canFitBoth() -> Bool {
        if (self.axis == .horizontal) {
            if let mwidth = self.minWidth {
                return self.frame.width >= (mwidth.lt + mwidth.rb)
            }
            return true
        }
        if let mheight = self.minHeight {
            return self.frame.height >= (mheight.lt + mheight.rb)
        }
        return true
    }
    
    private func showPanels(ltHidden: Bool, rbHidden: Bool) {
//        view.frame.size = CGSize(width: self.frame.width, height: height)
//        view.heightAnchor.constraint(equalToConstant: height)
//        view.frame.size = CGSize(width: width, height: frameSize.height)
//        view.widthAnchor.constraint(equalToConstant: width)
        
//        if ((!rbHidden || !ltHidden) && !isShowEither()) {
//        }
        self.setNeedsLayout()
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.rightBottomView.isHidden = rbHidden
            self.leftTopView.isHidden = ltHidden
            self.layoutIfNeeded()
        })
    }
    
    public func showLeftTopOnly() {
        showPanels(ltHidden: false, rbHidden: true)
    }
    
    public func showRightBottomOnly() {
        showPanels(ltHidden: true, rbHidden: false)
    }
    
    public func showBoth(favored: PanelEnum) -> Bool {
        if (!self.canFitBoth()) {
            if (favored == .LeftTop) {
                showLeftTopOnly()
                return false
            }
            if (favored == .RightBottom) {
                showRightBottomOnly()
                return false
            }
        }
        
        showPanels(ltHidden: false, rbHidden: false)
        return true
    }
}
