//
//  ViewController.swift
//  concertlight
//
//  Created by Rick Yip on 31/10/2019.
//  Copyright © 2019 gwong1si4. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let previewView: UIView = {
        let view = UIView()
        return view
    }()
    
    let popoButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.setTitle("Popo Light", for: .normal)
        return view
    }()
    
    override func viewDidLoad() {
        print("Hi")
        super.viewDidLoad()
        view.addSubview(previewView)
        previewView.frame = view.bounds
        previewView.addSubview(popoButton)
        NSLayoutConstraint.activate([
            popoButton.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -100),
            popoButton.heightAnchor.constraint(equalToConstant: 50),
            popoButton.leadingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -80),
            popoButton.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -20)
        ])
    }


}

