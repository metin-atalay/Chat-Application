//
//  ChatViewController.swift
//  Messanger
//
//  Created by Metin Atalay on 18.01.2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChatViewController: MessagesViewController {
    
    let leftBarButtonView : UIView = {
       return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    var gallery: GalleryController!
    
    private var chatId = ""
    private var recepientId = ""
    private var recepientName = ""
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    var mkMessages: [MKMessage] = []
    var allLocalMessage: Results<LocalMessage>!
    
    var notificationToken : NotificationToken?
    
    let realm = try! Realm()
    
    var displayingMessageCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var typingCounter = 0
    
    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName = ""
    var audioDuration: Date!
    
    init(chatId: String, recepinetId: String, recepientName: String){
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recepientId = recepinetId
        self.recepientName = recepientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = recepientName
        
        navigationItem.largeTitleDisplayMode = .never
        createTypingObserver()
        
        configureMeessageCollectionView()
        configureGestureRecognizer()
        configureMessageInputBar()
        
        configureLeftBarButton()
        configureCustomTitle()
        
        loadChats()
        listenForNewChats()
        listenForReadStatusChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        audioController.stopAnyOngoingPlaying()
    }
    
    private func configureMeessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController
    }
    
    private func configureGestureRecognizer(){
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        
        
    }
    
    private func configureMessageInputBar() {
        
        messageInputBar.delegate = self
        
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus",withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 30.0))
        
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        attachButton.onTouchUpInside { item in
            self.actionAttachMessage()
        }
        
        micButton.image = UIImage(systemName: "mic.fill")
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        micButton.addGestureRecognizer(longPressGesture)
        
        updateMicButtonStatus(show: true)
        
        //add gesture recognizer
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    private func loadChats(){
        let  predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        
        allLocalMessage = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: "date", ascending: true)
        
        if  allLocalMessage.isEmpty {
            checkForOldChats()
        }
        
        notificationToken = allLocalMessage.observe({ (changes: RealmCollectionChange) in
            
            switch changes {
            case .initial:
                print("we have \(self.allLocalMessage.count) messages")
                self.insertMesssages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            case .update(_,  _, let insertions, _) :
                for index in insertions {
                    print("new message \(self.allLocalMessage[index].message)")
                    self.insertMessage(self.allLocalMessage[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            case .error(let error):
                print("Error on new insertions ", error.localizedDescription)
            
            }
            
        })
    }
    
    private func listenForNewChats(){
        
        FirebaseMessageListner.shared.listenForNewChats(User.currentId, collenctionId: chatId, lastMessageDate: lastMessageDate())
        
    }
    
    private func checkForOldChats() {
        FirebaseMessageListner.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    private func insertMesssages(){
        
        maxMessageNumber = allLocalMessage.count - displayingMessageCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGE
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessage[i])
        }
        
      /*  for message in allLocalMessage {
            insertMessage(message)
        } */
    }
    
    @objc func  recordAudio(){
       
        switch longPressGesture.state {
        case .began:
            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioFileName )
        case .ended:
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                
                let audioD = audioDuration.interval(ofComponent: .second, from: Date())
                
                 messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil,audioDuration: audioD)
            } else {
                print("no audio file")
            }
            
            audioFileName = ""
         @unknown default:
            print("unknown")
        }
        
    }
    
    private func insertMessage(_ localMessage: LocalMessage){
        
        
       if localMessage.senderId != User.currentId {
            markMessageAsRead(localMessage)
        }

        
        let incoming = IncomingMessage(_collectionView: self)
        
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessageCount += 1
        
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGE
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed(){
            insertOlderMessage(allLocalMessage[i])
            
        }
    }
    
    
    private func insertOlderMessage(_ localMessage: LocalMessage){
        
        let incoming = IncomingMessage(_collectionView: self)
        
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        
        displayingMessageCount += 1
        
    }
    
    func messageSend(text: String?, photo: UIImage?,video: Video?, audio: String? , location: String?,audioDuration: Float = 0.0) {
        
        //print("sending message..",text as Any)
        
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio,audioDuration : audioDuration, location: location, memberIds: [User.currentId,recepientId])
        
    }
    
    private func configureLeftBarButton(){
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain,
                                                                 target: self, action: #selector(self.backButtonPress))]
    }
    
    @objc func backButtonPress() {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        self.removeListeners()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func configureCustomTitle() {
        
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        titleLabel.text = recepientName
        
    }
    
    func updateMicButtonStatus(show: Bool) {
        
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refreshController.isRefreshing {
            
            if displayingMessageCount < allLocalMessage.count {
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
        
    }
    
    func createTypingObserver() {
        
        FirebaseTypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping)  in
        
            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
            
        }
        
    }

    func typingIndicatorUpdate(){
        
        typingCounter += 1
        
        FirebaseTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 ) {
            self.typingCounterStop()
        }
        
    }
    
    func typingCounterStop(){
        typingCounter -= 1
        
        print ("test..")
        
        if typingCounter == 0 {
            
            FirebaseTypingListener.saveTypingCounter(typing: false, chatRoomId: self.chatId)
            
        }
    }
    
    
    func removeListeners(){
        FirebaseTypingListener.shared.removeTypingListener()
        FirebaseMessageListner.shared.removeListeners()
    }
    
    
    func updateTypingIndicator(_ show: Bool) {
        subTitleLabel.text = show ? "Typing..." : ""
    }
    
    private func lastMessageDate() -> Date {
        
        let lastMessageDate =  allLocalMessage.last?.date ?? Date()
        
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
        
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        
        if localMessage.senderId != User.currentId  {

            FirebaseMessageListner.shared.updateMessageInFireStore(localMessage, memberIds: [User.currentId, self.recepientId])
        }
    }
    
    private func listenForReadStatusChange() {
        
        FirebaseMessageListner.shared.listenForReadStatusChange(User.currentId, collectionId: chatId) { (updatedMessage) in
            
            if updatedMessage.status != kSENT {
                self.updateMessage(updatedMessage)
            }
        }
    }
    
    //MARK: - UpdateReadMessagesStatus
    func updateMessage(_ localMessage: LocalMessage) {

        for index in 0 ..< mkMessages.count {

            let tempMessage = mkMessages[index]

            if localMessage.id == tempMessage.messageId {

                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate

                RealmManager.shared.saveToRealm(localMessage)

                if mkMessages[index].status == kREAD {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    private func showImageGallery(camera: Bool) {
        
        gallery = GalleryController()
        gallery.delegate = self
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    private func actionAttachMessage() {
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
            
            self.showImageGallery(camera: true)
        }
        
        let shareMedia = UIAlertAction(title: "Library", style: .default) { (alert) in
            
            self.showImageGallery(camera: false)
        }

        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert) in
            
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            } else {
                print("no access to location")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")

        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
    }
    
}

extension ChatViewController : GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first!.resolve { (image) in
                
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        print("selected video")
        
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        
        self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
