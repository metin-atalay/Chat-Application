//
//  StatusTableViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 8.01.2022.
//

import UIKit

class StatusTableViewController: UITableViewController {
    
    var allStatus : [String] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadStatus()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allStatus.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text =  allStatus[indexPath.row]
        cell.accessoryType = allStatus[indexPath.row] == User.currentUser?.status ? .checkmark : .none
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        updateStatus(indexPath)
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBGColor")
        return headerView
    }
    
    func updateStatus(_ indexPath: IndexPath){
        
        let status = allStatus[indexPath.row]
        
        if var user = User.currentUser {
            user.status = status
            saveUserLocally(user)
            FirebaseUserListener.shared.saveUserToFirestore(user)
            tableView.reloadData()
        }
        
    }
    
    func loadStatus(){
        allStatus = userDefaults.object(forKey: kSTATUS) as! [String]
        tableView.reloadData()
    }
    
}
