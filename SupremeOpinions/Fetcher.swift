//
//  Fetcher.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/8/15.
//
//

import Foundation

private let privateInstance : Fetcher = Fetcher()

class Fetcher : NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate
{
    private let slipsURL = NSURL(string: "http://www.supremecourt.gov/opinions/slipopinions.aspx")!
    private var session : NSURLSession!

    class func instance () -> Fetcher {
        return privateInstance
    }

    override init() {
        super.init()
        self.session = NSURLSession(configuration: nil, delegate: self, delegateQueue: nil)
    }

    func fetchAvailableOpinions (completionBlock: (opinions:[Opinion]) -> ()) -> () {
        let task = self.session.dataTaskWithURL(self.slipsURL, completionHandler: { (data, res, err) -> Void in
            var opinions : [Opinion] = []
            if let resStr = NSString(data: data, encoding: NSUTF8StringEncoding) {
                opinions = Extractor.extract(resStr)
            }
            completionBlock(opinions: opinions)
        })
        task.resume()
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        println("RESPONSE!")
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        println("DATA!")
    }

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        println("DONE!")
    }

}
