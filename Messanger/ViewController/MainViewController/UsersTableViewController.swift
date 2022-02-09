//
//  UsersTableViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 8.01.2022.
//

import UIKit

class UsersTableViewController: UITableViewController {

    var allUser : [User] = []
    var filteredUser: [User] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
       // createDummyUsers()
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        
        dowlandUsers()
        setSearchBarToView()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredUser.count : allUser.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        
        let user = searchController.isActive ? filteredUser[indexPath.row] : allUser[indexPath.row]
        
        cell.configureC(user)

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBGColor")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = searchController.isActive ? filteredUser[indexPath.row] : allUser[indexPath.row]
        
        showUserProfile(user)
        
    }
    
    func showUserProfile(_ user: User) {
        
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileView") as! ProfileTableViewController
        
        profileView.user = user
        
        self.navigationController?.pushViewController(profileView, animated: true)
        
        
    }
    
    func dowlandUsers(){
        FirebaseUserListener.shared.downloadAllUsersFromFirebase { (users) in
            self.allUser = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setSearchBarToView(){
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    func filteredContentForSearchText(searchText: String){
        print("Search text ", searchText)
        
        filteredUser = allUser.filter({(user)->Bool in
            
            return user.username.lowercased().contains(searchText.lowercased())
            
        })
        tableView.reloadData()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Refresh...")
        
        if self.refreshControl!.isRefreshing {
            self.dowlandUsers()
            self.refreshControl!.endRefreshing()
        }
    }
    
    
}

extension UsersTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
