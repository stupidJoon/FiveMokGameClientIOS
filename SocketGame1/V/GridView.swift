//
//  GridView.swift
//  SocketGame1
//
//  Created by 유준상 on 11/02/2019.
//  Copyright © 2019 유준상. All rights reserved.
//

import UIKit

class GridView: UIView {
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GridView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
