//
//  album.swift
//  ImageGallery 3
//
//  Created by Apple on 15/03/19.
//  Copyright © 2019 Ztack. All rights reserved.
//

import Foundation
import UIKit

struct Album{
    var photos: [UIImage?]
    var urls: [URL?]
    
    mutating func insertData(_ image: UIImage?, _ url: URL, at index: Int){
        photos.insert(image, at: index)
        urls.insert(url, at: index)
    }
}
