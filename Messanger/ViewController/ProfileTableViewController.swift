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
    
    var users: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

   
    }

}
