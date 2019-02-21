//
//  SelectRoomTableViewCell.swift
//  SocketGame1
//
//  Created by 유준상 on 09/02/2019.
//  Copyright © 2019 유준상. All rights reserved.
//

import UIKit

enum roomStateEnum: String {
    case waiting = "Waiting"
    case playing = "Playing"
}

class SelectRoomTableViewCell: UITableViewCell {
    @IBOutlet var roomNameLabel: UILabel!
    @IBOutlet var roomPlayerNumberLabel: UILabel!
    @IBOutlet var roomStateLabel: UILabel!
    @IBOutlet var roomStateView: UIView!
    
    var roomNumber: Int = 0 {
        didSet {
            roomNameLabel.text = "\(roomNumber)번 방"
        }
    }
    var roomPlayerNumber: Int = 0 {
        didSet {
            roomPlayerNumberLabel.text = "\(roomPlayerNumber)/2"
        }
    }
    var roomState: roomStateEnum = .waiting {
        didSet {
            switch roomState {
            case .waiting:
                roomStateView.backgroundColor = UIColor.green
            case .playing:
                roomStateView.backgroundColor = UIColor.red
            }
            roomStateLabel.text = roomState.rawValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = roomStateView.backgroundColor
        super.setSelected(selected, animated: animated)
        if selected == true {
            roomStateView.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = roomStateView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if highlighted == true {
            roomStateView.backgroundColor = color
        }
    }
}
