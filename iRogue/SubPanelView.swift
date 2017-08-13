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
    
    private var minWidth: CGFloat?
    private var minHeight: CGFloat?
    
    private lazy var leftTopView: UIView = { [unowned self] in
        return self.arrangedSubviews[0]
    }()

    private lazy var rightBottomView: UIView = { [unowned self] in
        return self.arrangedSubviews[1]
    }()
    
    public func setup(minWidth: CGFloat, minHeight: CGFloat) {
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
        return (self.axis == .horizontal && (self.minWidth! < 0.0
            || self.frame.width >= 2.0 * self.minWidth!))
        || (self.axis == .vertical && (self.minHeight! < 0.0
            || self.frame.height >= 2.0 * self.minHeight!))
    }
    
    public func showBoth(favored: PanelEnum) {
        if (!self.canFitBoth()) {
            if (favored == .LeftTop) {
                showLeftTopOnly()
                return
            }
            if (favored == .RightBottom) {
                showRightBottomOnly()
                return
            }
        }
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.rightBottomView.isHidden = false
            self.leftTopView.isHidden = false
        })
    }
}
