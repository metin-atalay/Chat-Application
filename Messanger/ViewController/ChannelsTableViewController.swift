//
//  ChannelsTableViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 5.02.2022.
//


import UIKit

class ChannelsTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var channelSegmentOutlet: UISegmentedControl!
    
    //MARK: - Vars
    var allChannels: [Channel] = []
    var subscribedChannels: [Channel] = []

    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .always
        self.title = "Channel"

        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        
        tableView.tableFooterView = UIView()
        
        downloadAllChannels()
        downloadSubscribedChannels()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

       // return 1
        return channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels.count : allChannels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelTableViewCell
        
        let channel = channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]

        cell.configure(channel: channel)
        
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if channelSegmentOutlet.selectedSegmentIndex == 1 {

            showChannelView(channel: allChannels[indexPath.row])
        } else {
            showChat(channel: subscribedChannels[indexPath.row])
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if channelSegmentOutlet.selectedSegmentIndex == 1 {
            return false
        } else {
            //return true
           return subscribedChannels[indexPath.row].adminId != User.currentId
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var channelToUnfollow = subscribedChannels[indexPath.row]
            subscribedChannels.remove(at: indexPath.row)

            
            if let index = channelToUnfollow.memberIds.firstIndex(of: User.currentId) {
                channelToUnfollow.memberIds.remove(at: index)
            }
            
            FirebaseChannelListener.shared.saveCannel(channelToUnfollow)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    
    //MARK: - IBActions
    @IBAction func channelSegmentValueChanged(_ sender: Any) {
        
        tableView.reloadData()
    }
    
    //MARK: - Download channels
    private func downloadAllChannels() {
        
        FirebaseChannelListener.shared.downloadAllChannels { (allChannels) in
            
            self.allChannels = allChannels
            
            if self.channelSegmentOutlet.selectedSegmentIndex == 1 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func downloadSubscribedChannels() {
        FirebaseChannelListener.shared.downloadSubscribedChannels { (subscribedChannels) in
            
            self.subscribedChannels = subscribedChannels
            if self.channelSegmentOutlet.selectedSegmentIndex == 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if self.refreshControl!.isRefreshing {
            self.downloadAllChannels()
            self.refreshControl!.endRefreshing()
        }
    }

    //MARK: - Navigation
    private func showChannelView(channel: Channel) {
        
       let channelVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "channelView") as! ChannelDetailTableViewController
        
        channelVC.channel = channel
        channelVC.delegate = self
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    private func showChat(channel: Channel) {

        let channelChatVC = ChannelChatViewController(channel: channel)
        
        channelChatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(channelChatVC, animated: true)
    }
}


extension ChannelsTableViewController : ChannelDetailTableViewControllerDelegate {
    
    func didClickFollow() {
        self.downloadAllChannels()
    }
    
}
