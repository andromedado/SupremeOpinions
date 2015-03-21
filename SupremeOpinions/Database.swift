//
//  Database.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/21/15.
//
//

import Foundation

private let _opinionsDb = Database(name: "opinions")

class Database {
    let name : String
    let dbPath : String

    init(name:String) {
        self.name = name
        dbPath = FileManager.instance().dbDir.stringByAppendingPathComponent(name + ".db")
        var sqlite3Database : sqlite3
    }

    class func opinionsDb() -> Database {
        return _opinionsDb
    }

}
