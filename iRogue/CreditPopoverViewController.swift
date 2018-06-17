//
//  CreditPopoverViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 6/2/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import UIKit

class CreditPopoverViewController : UIViewController {
    
    var toValue = String()
    var titleValue = String()
    var linkValue : String?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var creditTo: UILabel!
    @IBOutlet weak var creditTitle: UILabel!
    @IBOutlet weak var creditLink: UITextView!
    @IBOutlet weak var exitButton: UIButton!
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.cornerRadius = 10.0
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // exitButton.setTitleColor(.white, for: .normal)

        pinBackground(backgroundView, to: stackView)
        print("CreditPopoverViewController did load")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        creditTo.text = toValue
        creditTitle.text = titleValue
        creditLink.text = linkValue
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
    }
    
}

public extension UIView {
    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}
