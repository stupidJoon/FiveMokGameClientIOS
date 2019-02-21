//
//  StartViewController.swift
//  SocketGame1
//
//  Created by 유준상 on 09/02/2019.
//  Copyright © 2019 유준상. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    @IBOutlet var selectRoomTableView: UITableView!
    
    var roomStateArr: [roomStateEnum] = [.waiting, .waiting, .waiting];
    var playerNumberArr: [Int]?
    
    @objc func setPlayerNumber(_ notification: NSNotification) {
        playerNumberArr = ([notification.userInfo!["room1"], notification.userInfo!["room2"] ,notification.userInfo!["room3"]] as! [Int])
        let roomStatusArray: [Bool] = notification.userInfo!["status"] as! [Bool]
        for (index, element) in roomStatusArray.enumerated() {
            if (element == true) {
                roomStateArr[index] = .playing
            }
            else {
                roomStateArr[index] = .waiting
            }
        }
        selectRoomTableView.reloadData()
    }
    
    func setup() {
        selectRoomTableView.dataSource = self
        selectRoomTableView.delegate = self
        selectRoomTableView.register(UINib(nibName: "SelectRoomTableViewCell", bundle: nil), forCellReuseIdentifier: "selectRoomTableViewCell")
        navigationItem.title = "방 선택"
        SingleTon.sharedInstance.gameSocket.getPlayerNumber()
        NotificationCenter.default.addObserver(self, selector: #selector(setPlayerNumber(_:)), name: Notification.Name("setPlayerNumber"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension StartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomStateArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectRoomTableViewCell") as! SelectRoomTableViewCell
        let row = indexPath.row
        if let playerNumberArrUnwrapped = playerNumberArr {
            if (playerNumberArrUnwrapped[row] >= 2) {
                cell.isUserInteractionEnabled = false
            }
            else {
                cell.isUserInteractionEnabled = true
            }
        }
        cell.roomNumber = row + 1
        cell.roomPlayerNumber = playerNumberArr?[row] ?? 0
        cell.roomState = roomStateArr[row]
        return cell
    }
}

extension StartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        SingleTon.sharedInstance.gameSocket.connectRoomSocket(roomIndex: row)
        let vc = MainGameViewController()
        vc.roomIndex = row
        navigationController?.pushViewController(vc, animated: true)
        // 눌렀을때 하이라이트 꺼지게 함
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
