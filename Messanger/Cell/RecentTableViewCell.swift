//
//  RecentTableViewCell.swift
//  Messanger
//
//  Created by Metin Atalay on 9.01.2022.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCounterLabel: UILabel!
    @IBOutlet weak var unreadCounterBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        unreadCounterBG.layer.cornerRadius = unreadCounterBG.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     
    }
    
    func configure(recent: RecentChat){
        usernameLabel.text = recent.receiverName
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.9
        
        lastMessageLabel.text = recent.lastMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        lastMessageLabel.minimumScaleFactor = 2
        lastMessageLabel.minimumScaleFactor = 0.9

        if recent.unreadCounter  != 0 {
            self.unreadCounterLabel.text = "\(recent.unreadCounter)"
            self.unreadCounterBG.isHidden = false
        } else {
            //self.unreadCounterLabel.isHidden = true
            self.unreadCounterBG.isHidden = true
        }
        
        setAvatar(avatarLink: recent.avatarLink)
        dateLabel.text = timeElapsed(recent.date ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
        
    
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.dowlandImage(imageUrl: avatarLink) { (avatar) in
                self.avatarImage.image = avatar?.circleMasked
            }
        }
    }

}
