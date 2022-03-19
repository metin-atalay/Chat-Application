//
//  ChannelDetailTableViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 6.02.2022.
//


import UIKit

protocol ChannelDetailTableViewControllerDelegate {
    func didClickFollow()
}

class ChannelDetailTableViewController: UITableViewController {

    //MARK: - IBActions
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    
    //MARK: - Vars
    var channel: Channel!
    var delegate: ChannelDetailTableViewControllerDelegate?
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        showChannelData()
        configureRightBarButton()
    }

    
    //MARK: - Configure
    private func showChannelData() {
        self.title = channel.name
        nameLabel.text = channel.name
        membersLabel.text = "\(channel.memberIds.count) Members"
        aboutTextView.text = channel.aboutChannel
        setAvatar(avatarLink: channel.avatarLink)
    }
    
    private func configureRightBarButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followChannel))
    }

    private func setAvatar(avatarLink: String) {

        if avatarLink != "" {
            FileStorage.dowlandImage(imageUrl: avatarLink) { (avatarImage) in
                
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage != nil ? avatarImage?.circleMasked : UIImage(named: "avatar")
                }
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }

    
    //MARK: - Actions
    @objc func followChannel() {
        channel.memberIds.append(User.currentId)
        FirebaseChannelListener.shared.saveCannel(channel)
        delegate?.didClickFollow()
        self.navigationController?.popViewController(animated: true)
    }


}

