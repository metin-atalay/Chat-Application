//
//  SettingsTableViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 2.01.2022.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView ()

    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBGColor")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 10.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }
    
    @IBAction func telAFriendPressed(_ sender: Any) {
        
    }
    
    @IBAction func termAndConditionsPressed(_ sender: Any) {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 && indexPath.section == 0 {
            performSegue(withIdentifier: "settingsToEditProfileSeg", sender: self)
        }
        
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        FirebaseUserListener.shared.logOut { (error) in
            if error == nil {
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
                
            }else {
            
            }
            
        }
    }
    
    private func showUserInfo(){
        if let user = User.currentUser {
            userNameLabel.text = user.username
            statusLabel.text = user.status
            appVersionLabel.text = "App version: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")"
            
            if user.avatarLink != "" {
                
                FileStorage.dowlandImage(imageUrl: user.avatarLink) { (avatar) in
                    
                    self.avatarImage.image = avatar?.circleMasked
                    
                }
                
            }
            
        }
    }
    
}
