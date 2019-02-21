//
//  SingleTon.swift
//  SocketGame1
//
//  Created by 유준상 on 11/02/2019.
//  Copyright © 2019 유준상. All rights reserved.
//

import Foundation
import SocketIO

class SingleTon {
    static let sharedInstance = SingleTon()
    
    var gameSocket: GameSocket!
}
