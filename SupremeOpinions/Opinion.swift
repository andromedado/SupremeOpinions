//
//  Opinion.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

import Foundation

private let rootDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)[0] as NSURL
private let opinionDir = rootDir.URLByAppendingPathComponent("opinions").path!

class Opinion {
    var sequence : Int?,
    date : String?,
    docket : String?,
    name : String?,
    summary : String?,
    author : String?,
    volumePrint : String?,
    href : NSURL?

    init() {
        var isDir : ObjCBool = true
        if (!NSFileManager.defaultManager().fileExistsAtPath(opinionDir, isDirectory: &isDir)) {
            NSFileManager.defaultManager().createDirectoryAtPath(opinionDir, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
    }

    var filePath : String {
        get {
            if let docket = self.docket {
                return opinionDir.stringByAppendingPathComponent("\(docket).pdf")
            }
            return opinionDir.stringByAppendingPathComponent("nope.pdf")
        }
    }

    var downloaded : Bool {
        get {
            return NSFileManager.defaultManager().fileExistsAtPath(self.filePath)
        }
    }

    func download(completion:(NSError?) -> (), progress:((Float) -> ())?) -> () {
        println("Download \(self.href)")
        Fetcher.instance().fetch(opinion: self) { (data, err) -> () in
            if let progressCb = progress {
                progressCb(1)
            }
            let path = self.filePath
            if let haveData = data {
                let res = haveData.writeToFile(self.filePath, atomically: true)
                completion(nil)
                return
            }
            completion(err)
        }
    }

}
