//
//  FileManager.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

private let rootDir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)[0] as NSURL
private let privateOpinionDir = rootDir.URLByAppendingPathComponent("opinions").path!
private let privateCacheDir = rootDir.URLByAppendingPathComponent("cache").path!
private let privateDBDir = rootDir.URLByAppendingPathComponent("dbs").path!

private let privateInstance = FileManager()

import Foundation

class FileManager
{
    init() {
        self.ensureDirs([opinionDir, cacheDir, dbDir])
    }

    private func ensureDirs(dirs:[String]) -> () {
        var isDir : ObjCBool = true
        for dir in dirs {
            if (!NSFileManager.defaultManager().fileExistsAtPath(dir, isDirectory: &isDir)) {
                NSFileManager.defaultManager().createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
        }
    }

    class func instance() -> FileManager {
        return privateInstance
    }

    var availableOpinionsCacheFile : String {
        get {
            return cacheDir.stringByAppendingPathComponent("avop.cache")
        }
    }

    var dbDir : String {
        get {
            return privateDBDir
        }
    }

    var opinionDir : String {
        get {
            return privateOpinionDir
        }
    }

    var cacheDir : String {
        get {
            return privateCacheDir
        }
    }
}

