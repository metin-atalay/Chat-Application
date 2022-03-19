//
//  FileStorage.swift
//  Messanger
//
//  Created by Metin Atalay on 5.01.2022.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FileStorage {
    
    class func uploadImage(_ image : UIImage, dictionary: String, completion: @escaping(_ documentLink : String?) -> Void){
        
        let storageRef = storage.reference(forURL: kStorageURL).child(dictionary)
        
        let imageData =  image.jpegData(compressionQuality: 0.6)
        
        var task : StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if  error != nil {
                print("error occured in file updload \(error?.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (dowlandUrl, error) in
                
                guard let url = dowlandUrl else {
                    
                    completion(nil)
                    return
                    
                }
                completion(dowlandUrl?.absoluteString)
            }
            
        })
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }

    }
    
    //MARK: - Video
    class func uploadVideo(_ video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
        
        let storageRef = storage.reference(forURL: kStorageURL).child(directory)
                
        var task: StorageUploadTask!
        
        task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("error uploading video \(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                
                guard let downloadUrl = url  else {
                    completion(nil)
                    return
                }
                
                completion(downloadUrl.absoluteString)
            }
        })
        
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    class func saveFileLocally(fileData : NSData, fileName: String) {
        let docUrl = getDocumentsURL().appendingPathComponent(fileName,isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
    
    class func dowlandImage(imageUrl : String, completion: @escaping(_ image: UIImage?) -> Void) {
        
        print("URL is " , imageUrl)
       let imageName = fileNameFrom(fileURL: imageUrl)
        
        if fileExistsAtPath(path: imageName) {
            print("file is exists")
            
            if let fileContent = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageName)) {
                
                completion(fileContent)
                
            } else {
                print("Could not covenrt image")
                completion(UIImage(named: "avatar"))
            }
            
        } else{
            print("dowlanding image = ", imageUrl)
            
            if imageUrl != "" {
                
                let documentURL = URL(string: imageUrl)
                
                let dowlandQueue = DispatchQueue(label: "imageDowlandLabel")
                
                dowlandQueue.async {
                    let data = NSData(contentsOf: documentURL!)
                    
                    if  data != nil {
                        
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageName)
                        
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                        
                    } else {
                        print("Could not dowland image = ", imageUrl)
                        completion(nil)
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
    class func downloadVideo(videoLink: String, completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileURL: videoLink) + ".mov"

        if fileExistsAtPath(path: videoFileName) {
                
            completion(true, videoFileName)
            
        } else {

            let downloadQueue = DispatchQueue(label: "VideoDownloadQueue")
            
            downloadQueue.async {
                
                let data = NSData(contentsOf: videoUrl!)
                
                if data != nil {
                    
                    //Save locally
                    FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                    
                    DispatchQueue.main.async {
                        completion(true, videoFileName)
                    }
                    
                } else {
                    print("no document in database")
                }
            }
        }
    }

    
    //MARK: - Audio
    class func uploadAudio(_ audioFileName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void) {
        
        let fileName = audioFileName + ".m4a"
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
                
        var task: StorageUploadTask!
        
        if fileExistsAtPath(path: fileName) {
            
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)) {
                
                task = storageRef.putData(audioData as Data, metadata: nil, completion: { (metadata, error) in
                    
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    
                    if error != nil {
                        print("error uploading audio \(error!.localizedDescription)")
                        return
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        
                        guard let downloadUrl = url  else {
                            completion(nil)
                            return
                        }
                        
                        completion(downloadUrl.absoluteString)
                    }
                })
                
                
                task.observe(StorageTaskStatus.progress) { (snapshot) in
                    
                    let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                    ProgressHUD.showProgress(CGFloat(progress))
                }
            } else {
                print("nothing to upload (audio)")
            }
        }
    }

    class func downloadAudio(audioLink: String, completion: @escaping (_ audioFileName: String) -> Void) {
        
        let audioFileName = fileNameFrom(fileURL: audioLink) + ".m4a"

        if fileExistsAtPath(path: audioFileName) {
                
            completion(audioFileName)
            
        } else {

            let downloadQueue = DispatchQueue(label: "AudioDownloadQueue")
            
            downloadQueue.async {
                
                let data = NSData(contentsOf: URL(string: audioLink)!)
                
                if data != nil {
                    
                    //Save locally
                    FileStorage.saveFileLocally(fileData: data!, fileName: audioFileName)
                    
                    DispatchQueue.main.async {
                        completion(audioFileName)
                    }
                    
                } else {
                    print("no document in database audio")
                }
            }
        }
    }

    
    
}

// Helpers

func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String)  -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
