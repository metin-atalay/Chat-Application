//
//  EditProfileTableViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 4.01.2022.
//

import UIKit
import Gallery
import ProgressHUD

class EditProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var userName: UITextField!
    
    var gallery : GalleryController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        showUserInfo()
        
        configureUsername()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserInfo()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBGColor")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 30.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "editStatusSeg", sender: self)
        }

    }
    
    func showUserInfo(){
        if User.currentUser != nil {
            status.text = User.currentUser?.status
            userName.text = User.currentUser?.username
            
            if User.currentUser?.avatarLink != nil {
                FileStorage.dowlandImage(imageUrl: User.currentUser!.avatarLink) { (image) in
                    self.avatarImage.image = image?.circleMasked
                }
            }
        }
    }
    
    private func configureUsername(){
        userName.delegate = self
        userName.clearButtonMode = .whileEditing
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        openGallery()
    }
    
    private func openGallery() {
    
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab,.cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery, animated: true, completion: nil)
        
    }
    
    private func updateAvatarImaage(_ avatarImage : UIImage) {
        
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        
        FileStorage.uploadImage(avatarImage, dictionary: fileDirectory) { (avatarLink) in
            
            if var user = User.currentUser {
                user.avatarLink = avatarLink ?? ""
                saveUserLocally(user)
                FirebaseUserListener.shared.saveUserToFirestore(user)
            }
        }
        
        FileStorage.saveFileLocally(fileData: (avatarImage.jpegData(compressionQuality: 1.0)) as! NSData, fileName: User.currentId)
        
    }
}


extension EditProfileTableViewController :UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userName {
            if var user = User.currentUser {
                user.username = textField.text!
                saveUserLocally(user)
                FirebaseUserListener.shared.saveUserToFirestore(user)
            }
            
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}

extension EditProfileTableViewController: GalleryControllerDelegate{
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first?.resolve(completion: { (avatar) in
                
                if avatar != nil {
                    self.updateAvatarImaage(avatar!)
                    self.avatarImage.image = avatar?.circleMasked
                } else {
                    ProgressHUD.showError("Couldn't select an image")
                }
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
