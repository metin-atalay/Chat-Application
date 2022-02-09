//
//  UserTableViewCell.swift
//  Messanger
//
//  Created by Metin Atalay on 8.01.2022.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    public func configureC(_ user: User) {
        usernameLabel.text = user.username
        statusLabel.text = user.status
        setAvatarImage(user.avatarLink)
        
    }
    func setAvatarImage(_ link: String) {
        if  link != "" {
            FileStorage.dowlandImage(imageUrl: link, completion: { (avatar) in
                self.avatarImage.image = avatar?.circleMasked
            })
        } else {
            self.avatarImage.image = UIImage(named: "avatar")?.circleMasked
        }
    }

}
