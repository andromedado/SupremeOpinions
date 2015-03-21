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
    private let dbPath : String
    private let db : FMDatabase

    init(name:String) {
        self.name = name
        dbPath = FileManager.instance().dbDir.stringByAppendingPathComponent(name + ".db")
        db = FMDatabase(path: dbPath)
    }

    class func opinionsDb() -> Database {
        return _opinionsDb
    }

}
