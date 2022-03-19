//
//  ChatsTableViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 9.01.2022.
//

import UIKit

class ChatsTableViewController: UITableViewController {

    
    var allRecents: [RecentChat] = []
    var filteredRecents: [RecentChat]  = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        setSearchBarToView()
        dowlandRecentChat()
    }
    
    @IBAction func composeBarPressed(_ sender: Any) {
        
        let userView  = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "userFrame") as! UsersTableViewController
        
        navigationController?.pushViewController(userView, animated: true)
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredRecents.count : allRecents.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        goToChatRoom(recent:searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row])
        
        //goto chat room
    }
    
    func goToChatRoom(recent: RecentChat)  {
        
        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        
        let chatView = ChatViewController(chatId: recent.chatRoomId, recepinetId: recent.receiverId, recepientName: recent.receiverName)
        chatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatView, animated: true)
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell

        // Configure the cell...
        
        cell.configure(recent:  searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBGColor")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
            
            FirebaseRecentListener.shared.deleteRecent(recent)
            
            searchController.isActive ? self.filteredRecents.remove(at: indexPath.row) : allRecents.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
    }
    
    func dowlandRecentChat(){
        
        FirebaseRecentListener.shared.dowlandRecentChatsFromFireStore { (allChats) in
            self.allRecents = allChats
            
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
        
        filteredRecents = allRecents.filter({(recent)->Bool in
            
            return recent.receiverName.lowercased().contains(searchText.lowercased())
            
        })
        tableView.reloadData()
    }
}

extension ChatsTableViewController  : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

