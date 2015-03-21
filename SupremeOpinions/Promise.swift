//
//  Promise.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/21/15.
//
//

import Foundation

typealias Callback = (AnyObject?) -> AnyObject?
typealias VoidCallback = (AnyObject?) -> ()
typealias Executor = (VoidCallback, VoidCallback) -> ()

@objc
protocol Thenable {
    func then(callback : Callback) -> protocol<Thenable>;
    func then(callback : Callback, errorCallback : Callback) -> protocol<Thenable>;
}

private enum State {
    case Pending, Fulfilled, Rejected
}

class Promise : Thenable
{
    //Consumer need not hold on to me after creating me,
    //But I need to hang around until resolution
    private var strongReference : Promise?

    private var state : State = .Pending
    private var finalResolution : AnyObject?

    private var successCallbacks : [VoidCallback] = []
    private var failureCallbacks : [VoidCallback] = []

    init(executor: Executor) {
        weak var weakSelf = self
        strongReference = self
        executor({ (resolution) in
            if let strongSelf = weakSelf {
                strongSelf.setState(.Fulfilled, with: resolution)
                strongSelf.strongReference = nil
            }
            }, {  (rejection) in
                if let strongSelf = weakSelf {
                    strongSelf.setState(.Rejected, with: rejection)
                    strongSelf.strongReference = nil
                }
        })
    }

    func then(callback: Callback) -> protocol<Thenable> {
        return Promise({ (resolver, rejector) -> () in
            switch (self.state) {
            case .Pending:
                self.successCallbacks.append({ (res) in
                    resolver(callback(res))
                })
                self.failureCallbacks.append({ (err) in
                    rejector(err)
                })
            case .Fulfilled:
                resolver(callback(self.finalResolution))
            case .Rejected:
                rejector(self.finalResolution)
            }
        })
    }

    func then(callback: Callback, errorCallback: Callback) -> protocol<Thenable> {
        return Promise({ (resolver, rejector) -> () in
            switch (self.state) {
            case .Pending:
                self.successCallbacks.append({ (res) in
                    resolver(callback(res))
                })
                self.failureCallbacks.append({ (err) in
                    rejector(errorCallback(err))
                })
            case .Fulfilled:
                resolver(callback(self.finalResolution))
            case .Rejected:
                rejector(errorCallback(self.finalResolution))
            }
        })
    }

    private func setState(state: State, with resolution:AnyObject?) {
        if (self.state != .Pending) {
            println("***This promise is already settled")
            return
        }
        if let furtherPromise = resolution as? Thenable {
            weak var weakSelf = self
            furtherPromise.then({ (res) -> AnyObject? in
                if let strongSelf = weakSelf {
                    strongSelf.setState(.Fulfilled, with: res)
                }
                return nil
            }, errorCallback: { (err) -> AnyObject? in
                if let strongSelf = weakSelf {
                    strongSelf.setState(.Rejected, with: err)
                }
                return nil
            })
            println("Further deferred the resolution of this promise because I got a thenable back")
            return
        }
        self.state = state
        switch (self.state) {
        case .Rejected:
            for failure in self.failureCallbacks {
                failure(resolution)
            }
        case .Fulfilled:
            for success in self.successCallbacks {
                success(resolution)
            }
        default:
            ()
        }
        self.finalResolution = resolution
        self.successCallbacks = []
        self.failureCallbacks = []
    }

    deinit {
        println("***Promise is de-initializing...")
    }

}

