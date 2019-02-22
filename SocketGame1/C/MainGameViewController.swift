//
//  MainGameViewController.swift
//  SocketGame1
//
//  Created by 유준상 on 11/02/2019.
//  Copyright © 2019 유준상. All rights reserved.
//

import UIKit

class MainGameViewController: UIViewController {
    var gameBoardView: UIView!
    var startGameButton: UIButton!
    var gridArr: [[UIView]] = [[], [], [], [], [], [], [], [], [], []]
    var roomIndex: Int!
    
    @objc func winFiveMok(_ notification: NSNotification) {
        winGame(message: "5목을 완성했습니다")
    }
    
    @objc func loseFiveMok(_ notification: NSNotification) {
        loseGame(message: "상대방이 5목을 완성했습니다")
    }
    
    @objc func disconnectedOppositePlayer(_ notification: NSNotification) {
        winGame(message: "상대방이 나갔습니다")
    }
    
    @objc func setNavigationTitle(_ notification: NSNotification) {
        self.navigationItem.title = notification.userInfo!["title"] as? String
    }
    
    @objc func presentAlert(_ notification: NSNotification) {
        present(notification.userInfo!["alert"] as! UIAlertController, animated: true, completion: nil)
    }
    
    @objc func disableStartGameButton(_ notification: NSNotification) {
        startGameButton.isEnabled = false;
        startGameButton.setTitleColor(UIColor.gray, for: .normal)
    }
    
    @objc func gridTapGesture(_ sender: UITapGestureRecognizer) {
        if (GameModel.isMyTurn == true) {
            for i in 0..<10 {
                for j in 0..<10 {
                    if (gridArr[i][j] == sender.view!) {
                        SingleTon.sharedInstance.gameSocket.sendStonePosition(x: i, y: j, roomIndex: roomIndex)
                    }
                }
            }
        }
    }
    
    @objc func startButtonTapGesture(_ sender: UIButton) {
        let roomSocket =  SingleTon.sharedInstance.gameSocket.roomSocketDic[roomIndex]!
        roomSocket.emit("message", "startGame")
    }
    
    @objc func putStone(_ notification: NSNotification) {
        let x = notification.userInfo!["x"] as! Int
        let y = notification.userInfo!["y"] as! Int
        let color: UIColor!
        if (notification.userInfo!["color"] as! String == "black") {
            color = UIColor.black
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setNavigationTitle"), object: nil, userInfo: ["title": "백돌 차례"])
        }
        else {
            color = UIColor.white
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setNavigationTitle"), object: nil, userInfo: ["title": "흑돌 차례"])
        }
        let grid: UIView = gridArr[x][y]
        let stoneView = UIView()
        stoneView.frame = CGRect(x: grid.frame.origin.x + grid.frame.width * 0.1, y: grid.frame.origin.y + grid.frame.height * 0.1, width: grid.frame.width * 0.8, height: grid.frame.height * 0.8)
        stoneView.layer.cornerRadius = stoneView.frame.width / 2
        stoneView.backgroundColor = color
        gameBoardView.addSubview(stoneView)
        GameModel.isMyTurn = false
    }
    
    func winGame(message: String) {
        navigationItem.title = "승리"
        GameModel.isMyTurn = false
        let alert = UIAlertController(title: "승리했습니다!", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loseGame(message: String) {
        navigationItem.title = "패배"
        GameModel.isMyTurn = false
        let alert = UIAlertController(title: "패배했습니다!", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func setupLayout() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let safeHeight = statusBarHeight + navigationBarHeight
        let frameHeight = view.frame.height - safeHeight
        let frameWidth = view.frame.width
        gameBoardView = UIView()
        gameBoardView.frame = CGRect(x: 0, y: safeHeight + (frameHeight - frameWidth) / 2, width: frameWidth, height: frameWidth)
        gameBoardView.backgroundColor = UIColor.brown
        for i in 0..<10 {
            for j in 0..<10 {
                let grid = GridView.instanceFromNib()
                let gesture = UITapGestureRecognizer(target: self, action: #selector(gridTapGesture(_:)))
                grid.addGestureRecognizer(gesture)
                grid.frame = CGRect(x: frameWidth * (CGFloat(i) / 10), y: frameWidth * (CGFloat(j) / 10), width: frameWidth * 0.1, height: frameWidth * 0.1)
                gameBoardView.addSubview(grid)
                
                gridArr[i].append(grid)
            }
        }
        startGameButton = UIButton()
        startGameButton.frame = CGRect(x: frameWidth * 0.3, y: safeHeight + frameHeight * 0.9, width: frameWidth * 0.4, height: frameHeight * 0.05)
        startGameButton.setTitle("Start Game", for: .normal)
        startGameButton.setTitleColor(startGameButton.tintColor, for: .normal)
        startGameButton.addTarget(self, action: #selector(startButtonTapGesture(_:)), for: .touchUpInside)
        view.addSubview(gameBoardView)
        view.addSubview(startGameButton)
    }
    
    func setup() {
        setupLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(putStone(_:)), name: Notification.Name(rawValue: "putStone"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableStartGameButton(_:)), name: Notification.Name("disableStartGameButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentAlert(_:)), name: Notification.Name("presentAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setNavigationTitle(_:)), name: Notification.Name("setNavigationTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectedOppositePlayer(_:)), name: Notification.Name("disconnectedOppositePlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(winFiveMok(_:)), name: Notification.Name("winFiveMok"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loseFiveMok(_:)), name: Notification.Name("loseFiveMok"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SingleTon.sharedInstance.gameSocket.disconnectRoomSocket(roomIndex: roomIndex)
    }
}
