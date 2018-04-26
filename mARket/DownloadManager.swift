// Copyright 2017, Ralf Ebert
// License   https://opensource.org/licenses/MIT
// Source    https://www.ralfebert.de/snippets/ios/urlsession-background-downloads/

import Foundation
import Gzip
import Light_Untar
import ModelIO
import SceneKit.ModelIO

class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {

    static var shared = DownloadManager()

    typealias ProgressHandler = (Float) -> ()

    var onProgress : ProgressHandler? {
        didSet {
            if onProgress != nil {
                let _ = activate()
            }
        }
    }

    override private init() {
        super.init()
    }

    func activate() -> URLSession {
        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")

        // Warning: If an URLSession still exists from a previous download, it doesn't create a new URLSession object but returns the existing one with the old delegate object attached!
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }

    private func calculateProgress(session : URLSession, completionHandler : @escaping (Float) -> ()) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            let progress = downloads.map({ (task) -> Float in
                if task.countOfBytesExpectedToReceive > 0 {
                    return Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
                } else {
                    return 0.0
                }
            })
            completionHandler(progress.reduce(0.0, +))
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        if totalBytesExpectedToWrite > 0 {
            if let onProgress = onProgress {
                calculateProgress(session: session, completionHandler: onProgress)
            }
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            debugPrint("Progress \(downloadTask) \(progress)")
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        debugPrint("Download finished: \(location)")
        
        let tempDocumentsURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?
        var gzFileUrl = tempDocumentsURL!.appendingPathComponent(urlStringForItemDownload)
        var tarFileUrl = tempDocumentsURL!.appendingPathComponent(urlStringForItemDownload)
        let finalUrl = tempDocumentsURL!.appendingPathComponent(urlStringForItemDownload)

        gzFileUrl.appendPathExtension("gz")
        tarFileUrl.appendPathExtension("tar")

        let arrayOfFileNames = ["\(urlStringForItemDownload).gz", "\(urlStringForItemDownload).tar", urlStringForItemDownload]

        self.removeFiles(files: arrayOfFileNames)

        do{
            try FileManager.default.copyItem(at: location, to: gzFileUrl)
        }catch{
            print("error when moving zip to dest path")
        }

        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let searchURL = NSURL(fileURLWithPath: path)
        if var pathComponent = searchURL.appendingPathComponent(urlStringForItemDownload) {
            pathComponent.appendPathExtension("gz")
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
            } else {
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }

        let decompressedData: Data
        do{
            let compressedData = try Data(contentsOf: gzFileUrl)
            if compressedData.isGzipped {
                print("IN GZIPPED")
                decompressedData = try! compressedData.gunzipped()
                do{
                    try decompressedData.write(to: tarFileUrl)
                }catch{
                    print("Error writing to URL")
                }
                print("was ungzipped")
            } else {
                print("WASN'T ungzipped")
            }

        }catch{
            print("error while converting url to data")
        }

        if var pathComponent = searchURL.appendingPathComponent(urlStringForItemDownload) {
            pathComponent.appendPathExtension("tar")
            let filePath = pathComponent.path
            print("filepath is:")
            print(filePath)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
            } else {
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }

        do{
            let compressedData = try! Data(contentsOf: tarFileUrl)
            try FileManager.default.createFilesAndDirectories(at: finalUrl, withTarData: compressedData) { (float) in
                if var pathComponent = searchURL.appendingPathComponent("\(urlStringForItemDownload)/\(urlStringForItemDownload)") {
                    pathComponent.appendPathExtension("obj")
                    let filePath = pathComponent.path
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: filePath) {
                        print("FILE AVAILABLE")
                    } else {
                        print("FILE NOT AVAILABLE")
                    }
                } else {
                    print("FILE PATH NOT AVAILABLE")
                }
            }
            
        }catch{
            print("error whil untarring")
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("Task completed: \(task), error: \(String(describing: error))")
    }

    func removeFiles(files : Array<String>){

        for file in files {

            let fileNameToDelete = file
            var filePath = ""

            // Find documents directory on device
            let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)

            if dirs.count > 0 {
                let dir = dirs[0] //documents directory
                filePath = dir.appendingFormat("/" + fileNameToDelete)
                //print("Local path = \(filePath)")

            } else {
                print("Could not find local directory to store file")
                return
            }


            do {
                let fileManager = FileManager.default

                // Check if file exists
                if fileManager.fileExists(atPath: filePath) {
                    try fileManager.removeItem(atPath: filePath)
                } else {
                    print("File does not exist")
                }

            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
    }
}
