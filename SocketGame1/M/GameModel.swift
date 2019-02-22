//
//  GameModel.swift
//  SocketGame1
//
//  Created by 유준상 on 11/02/2019.
//  Copyright © 2019 유준상. All rights reserved.
//

import Foundation
import UIKit
import SocketIO

class GameModel {
    static var isMyTurn = false
    static var myStoneColor = "black"
    
    static func setMyStoneColor(stoneColor: String) {
        GameModel.myStoneColor = stoneColor
    }
    
    static func prepareGame(socket: SocketIOClient) {
        socket.on("turn", callback: { _, _ in
            isMyTurn = true
        })
    }
}
