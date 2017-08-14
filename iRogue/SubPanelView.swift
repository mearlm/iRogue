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

    public func showLeftTopOnly() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.rightBottomView.isHidden = true
            self.leftTopView.isHidden = false
        })
    }
    
    public func showRightBottomOnly() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.rightBottomView.isHidden = false
            self.leftTopView.isHidden = true
        })
    }
    
    private func canFitBoth() -> Bool {
        if (self.axis == .horizontal) {
            if let mwidth = self.minWidth {
                return self.frame.width >= mwidth.lt + mwidth.rb
            }
            return true
        }
        if let mheight = self.minHeight {
            return self.frame.height >= mheight.lt + mheight.rb
        }
        return true
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
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.rightBottomView.isHidden = false
            self.leftTopView.isHidden = false
        })
        return true
    }
}
