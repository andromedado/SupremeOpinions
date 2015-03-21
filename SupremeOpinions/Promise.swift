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

class Promise<R, E>// : Thenable
{
    //Consumer need not hold on to me after creating me,
    //But I need to hang around until resolution
    private var strongReference : Promise?

    private var state : State = .Pending
    private var finalResolution : R?
    private var finalError : E?

    private var successCallbacks : [(R) -> ()] = []
    private var failureCallbacks : [(E) -> ()] = []

    init(executor: ((R) -> (), (E) -> ()) -> ()) {
        weak var weakSelf = self
        strongReference = self
        executor({ (resolution) in
            if let strongSelf = weakSelf {
                strongSelf.setState(.Fulfilled, resolution: resolution, error: nil)
                strongSelf.strongReference = nil
            }
            }, {  (rejection) in
                if let strongSelf = weakSelf {
                    strongSelf.setState(.Rejected, resolution: nil, error: rejection)
                    strongSelf.strongReference = nil
                }
        })
    }

    func then<A>(callback: (R) -> A) -> Promise<A, E> {
        return Promise<A, E>({ (resolver, rejector) -> () in
            switch (self.state) {
            case .Pending:
                self.successCallbacks.append({ (res) in
                    resolver(callback(res))
                })
                self.failureCallbacks.append({ (err) in
                    rejector(err)
                })
            case .Fulfilled:
                resolver(callback(self.finalResolution!))
            case .Rejected:
                rejector(self.finalError!)
            }
        })
    }

    func then<A, B>(callback: (R) -> A, errorCallback: (E) -> B) -> Promise<A, B> {
        return Promise<A, B>({ (resolver, rejector) -> () in
            switch (self.state) {
            case .Pending:
                self.successCallbacks.append({ (res) in
                    resolver(callback(res))
                })
                self.failureCallbacks.append({ (err) in
                    rejector(errorCallback(err))
                })
            case .Fulfilled:
                resolver(callback(self.finalResolution!))
            case .Rejected:
                rejector(errorCallback(self.finalError!))
            }
        })
    }

    private func setState(state: State, resolution:R?, error:E?) {
        if (self.state != .Pending) {
            println("***This promise is already settled")
            return
        }
        if let furtherPromise = resolution as? Promise {
            weak var weakSelf = self
            furtherPromise.then({ (res) -> AnyObject? in
                if let strongSelf = weakSelf {
                    strongSelf.setState(.Fulfilled, resolution: res, error: nil)
                }
                return nil
            }, errorCallback: { (err) -> AnyObject? in
                if let strongSelf = weakSelf {
                    strongSelf.setState(.Rejected, resolution: nil, error: err)
                }
                return nil
            })
            println("Further deferred the resolution of this promise because I got a thenable back")
            return
        }
        self.state = state
        switch (self.state) {
        case .Rejected:
            self.finalError = error
            for failure in self.failureCallbacks {
                failure(error!)
            }
        case .Fulfilled:
            self.finalResolution = resolution
            for success in self.successCallbacks {
                success(resolution!)
            }
        default:
            ()
        }
        self.successCallbacks = []
        self.failureCallbacks = []
    }

    deinit {
        println("***Promise is de-initializing...")
    }

}

