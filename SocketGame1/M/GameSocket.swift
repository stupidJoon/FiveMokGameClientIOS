//
//  GameSocket.swift
//  SocketGame1
//
//  Created by 유준상 on 09/02/2019.
//  Copyright © 2019 유준상. All rights reserved.
//

import Foundation
import SocketIO

// "http://54.180.57.73:3000"
// "http://localhost:3000"

class GameSocket {
    var mainSocket: SocketIOClient!
    var roomSocketDic: [Int: SocketIOClient] = [:]
    let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(false), .compress])
    
    func connectMainSocket() {
        mainSocket = manager.socket(forNamespace: "/")
        mainSocket.on(clientEvent: .connect) { _, _ in
            print("Main Socket Connected")
            self.getPlayerNumber()
        }
        mainSocket.connect()
    }
    
    func connectRoomSocket(roomIndex: Int) {
        roomSocketDic[roomIndex] = manager.socket(forNamespace: "/room\(roomIndex + 1)")
        roomSocketDic[roomIndex]?.on(clientEvent: .connect, callback: { _, _ in
            print("Room \(roomIndex + 1) Socket Connected")
        })
        roomSocketDic[roomIndex]?.on("startGame", callback: { data, _ in
            let response = data[0] as! Dictionary<String, Any>
            if (response["startGame"] as! Int == 1) {
                print("Start Game Succeeded, Your Stone Color is \(response["stone"] as! String)")
                GameModel.prepareGame(socket: self.roomSocketDic[roomIndex]!)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "disableStartGameButton"), object: nil, userInfo: nil)
                let alert = UIAlertController(title: "게임 시작!", message: "게임을 시작했습니다. 당신의 바둑돌 색갈은 \(response["stone"] as! String) 입니다", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                GameModel.setMyStoneColor(stoneColor: response["stone"] as! String)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "presentAlert"), object: nil, userInfo: ["alert": alert])
                NotificationCenter.default.post(name: Notification.Name(rawValue: "setNavigationTitle"), object: nil, userInfo: ["title": "흑돌 차례"])
            }
            else {
                let alert = UIAlertController(title: "게임 시작 실패!", message: "게임 시작을 실패했습니다. 현재 방의 인원수가 2명인지 확인해주세요", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "presentAlert"), object: nil, userInfo: ["alert": alert])
            }
        })
        roomSocketDic[roomIndex]?.on("putStone", callback: { data, _ in
            let response = data[0] as! Dictionary<String, Any>
            NotificationCenter.default.post(name: Notification.Name(rawValue: "putStone"), object: nil, userInfo: ["x": response["x"]!, "y": response["y"]!, "color": response["color"]!])
        })
        roomSocketDic[roomIndex]?.on("disconnectedOppositePlayer", callback: { _, _ in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "disconnectedOppositePlayer"), object: nil)
        })
        roomSocketDic[roomIndex]?.on("winFiveMok", callback: { data, _ in
            let response = data[0] as! Dictionary<String, Any>
            if (response["winColor"] as! String == GameModel.myStoneColor) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "winFiveMok"), object: nil)
            }
            else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "loseFiveMok"), object: nil)
            }
        })
        roomSocketDic[roomIndex]?.connect()
    }
    
    func disconnectRoomSocket(roomIndex: Int) {
        roomSocketDic[roomIndex]?.disconnect()
        print("Room \(roomIndex + 1) Socket Disconnected")
    }
    
    func sendStonePosition(x: Int, y: Int, roomIndex: Int) {
        roomSocketDic[roomIndex]?.emit("putStone", ["x": x, "y": y])
    }
    
    func getPlayerNumber() {
        mainSocket.on("getPlayerNumber", callback: { data, _ in
            let response = data[0] as! Dictionary<String, Any>
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setPlayerNumber"), object: nil, userInfo: ["room1": response["room1"]!, "room2": response["room2"]!, "room3": response["room3"]!, "status": response["status"]!])
        })
        mainSocket.emit("getPlayerNumber", "")
    }
    
    init() {
        connectMainSocket()
    }
}
