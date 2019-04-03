//
//  imageCollectionViewCell.swift
//  ImageGallery 3
//
//  Created by Apple on 15/03/19.
//  Copyright © 2019 Ztack. All rights reserved.
//

import UIKit

class imageCollectionViewCell: UICollectionViewCell {
    var backgroundImage: UIImage?{
        didSet{
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
        self.layer.cornerRadius = cornerRadius
    }
}
extension imageCollectionViewCell{
    var cornerRadius: CGFloat{
        return CGFloat(3.0)
    }
}
