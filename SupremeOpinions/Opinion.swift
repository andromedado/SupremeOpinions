//
//  Opinion.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

import Foundation

class Opinion : NSObject, NSCoding {
    var sequence : Int?,
    date : String?,
    docket : String?,
    name : String?,
    summary : String?,
    author : String?,
    volumePrint : String?,
    href : NSURL?

    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        super.init()
        self.sequence = aDecoder.decodeObjectForKey("sequence") as? Int
        self.date = aDecoder.decodeObjectForKey("date") as? String
        self.docket = aDecoder.decodeObjectForKey("docket") as? String
        self.name = aDecoder.decodeObjectForKey("name") as? String
        self.summary = aDecoder.decodeObjectForKey("summary") as? String
        self.author = aDecoder.decodeObjectForKey("author") as? String
        self.volumePrint = aDecoder.decodeObjectForKey("volumePrint") as? String
        self.href = aDecoder.decodeObjectForKey("href") as? NSURL
    }

    var filePath : String {
        get {
            let opinionDir = FileManager.instance().opinionDir
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

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.sequence, forKey: "sequence")
        aCoder.encodeObject(self.date, forKey: "date")
        aCoder.encodeObject(self.docket, forKey: "docket")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.summary, forKey: "summary")
        aCoder.encodeObject(self.author, forKey: "author")
        aCoder.encodeObject(self.volumePrint, forKey: "volumePrint")
        aCoder.encodeObject(self.href, forKey: "href")
    }
}
