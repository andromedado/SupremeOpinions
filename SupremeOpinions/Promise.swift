//
//  Promise.swift
//  SupremeOpinions
//
//  Created by Shad Downey on 3/21/15.
//
//

protocol Thenable {
    typealias 😃
    typealias 😱
    func then<😺>(callback : (😃) -> 😺) -> Promise<😺, 😱>;
    func then<😺, 🙀>(callback : (😃) -> 😺, errorCallback : (😱) -> 🙀) -> Promise<😺, 🙀>;
}

private enum State {
    case Pending, Fulfilled, Rejected
}

class Promise<😃, 😱> : Thenable
{
    //Consumer need not hold on to me after creating me,
    //But I need to hang around until resolution - which consumer controls
    private var strongReference : Promise?

    private var state : State = .Pending
    private var finalResolution : 😃?
    private var finalError : 😱?

    private var successCallbacks : [(😃) -> ()] = []
    private var failureCallbacks : [(😱) -> ()] = []

    init(executor: ((😃) -> (), (😱) -> ()) -> ()) {
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

    func then<😺>(callback: (😃) -> 😺) -> Promise<😺, 😱> {
        return Promise<😺, 😱>(executor: { (resolver, rejector) -> () in
            switch (self.state) {
            case .Pending:
                self.successCallbacks.append({ (res) in
                    resolver(callback(res))
                })
                self.failureCallbacks.append({ (err) in
                    rejector(err)
                })
            case .Fulfilled:
                println("final resolution \(self.finalResolution)")
                resolver(callback(self.finalResolution!))
            case .Rejected:
                rejector(self.finalError!)
            }
        })
    }

    func then<😺, 🙀>(callback: (😃) -> 😺, errorCallback: (😱) -> 🙀) -> Promise<😺, 🙀> {
        return Promise<😺, 🙀>(executor: { (resolver, rejector) -> () in
            switch (self.state) {
            case .Pending:
                self.successCallbacks.append({ (res) in
                    resolver(callback(res))
                })
                self.failureCallbacks.append({ (err) in
                    rejector(errorCallback(err))
                })
            case .Fulfilled:
                println("final resolution \(self.finalResolution)")
                resolver(callback(self.finalResolution!))
            case .Rejected:
                rejector(errorCallback(self.finalError!))
            }
        })
    }

    private func setState(state: State, resolution:😃?, error:😱?) {
        if (self.state != .Pending) {
            println("***This promise is already settled")
            return
        }
//        if resolution is Thenable {
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
            println("Further deferred the resolution of this promise because I got a --thenable-- Promise back")
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
//        println("***Promise is de-initializing...")
    }

}


func timedSuccessPromise<😃>(delay:NSTimeInterval, success:😃) -> Promise<😃, Void> {
    return Promise<😃, Void>(executor: { (successCallback, err) -> () in
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            successCallback(success)
        }
    })
}

func timedFailurePromise<😱>(delay:NSTimeInterval, failure:😱) -> Promise<Void, 😱> {
    return Promise<Void, 😱>(executor: { (successCallback, err) -> () in
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            err(failure)
        }
    })
}

