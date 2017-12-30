//
//  PrimaryButton.swift
//  Lez
//
//  Created by Antonija on 28/12/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import UIKit

class PrimaryButton: UIButton {
    override func awakeFromNib() {
        layer.cornerRadius = 4
        layer.backgroundColor = UIColor.blue.cgColor
        self.setTitleColor(UIColor.white, for: .normal)
    }
}
