//
//  CardImage.swift
//  Lez
//
//  Created by Antonija on 30/12/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import UIKit

class CardBackground: UIView {
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        self.layer.shouldRasterize = true
        self.layer.cornerRadius = 4
    }
}
