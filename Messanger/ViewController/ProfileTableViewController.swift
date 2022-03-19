//
//  PrfofileTableViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 8.01.2022.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
   public  var user: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        setupUI()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        headerView.backgroundColor = UIColor(named:  "tableviewBGColor")
        return headerView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            print("start chating with ", user!.username)
            
            let chatId = startChat(user1: User.currentUser!, user2: user!)
            let chatView = ChatViewController(chatId: chatId, recepinetId: user!.id, recepientName: user!.username)
            chatView.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatView, animated: true)
            
        }
        
    }
    
    private func setupUI() {
        
        if  user != nil {
            self.title = user?.username
            usernameLabel.text = user?.username
            statusLabel.text = user?.status
            
            if user?.avatarLink != nil {
                FileStorage.dowlandImage(imageUrl: user!.avatarLink) { (avatar) in
                    self.avatarImage.image = avatar?.circleMasked
                }
            }
            
            
            
        }
        
    }

}
