//
//  AsyncOperation.swift
//  OperationQueueExample
//

import Foundation

class AsyncOperation: Operation {
    
   enum OperationState: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
          return "is" + rawValue.capitalized
        }
    }
    
    private let stateQueue = DispatchQueue(label: "async.operation.state", attributes: .concurrent)

    private var rawState: OperationState = .ready

    var state: OperationState {
        get {
            return stateQueue.sync(execute: {
                rawState
            })
        }
        set {
            let oldKey = rawState.keyPath
            let newKey = newValue.keyPath
            willChangeValueNotify(forKeys: [oldKey, newKey])
            
            stateQueue.sync(flags: .barrier, execute: {
                rawState = newValue
            })
            
            didChangeValueNotify(forKeys: [oldKey, newKey])
        }
    }

    private func willChangeValueNotify(forKeys keys: [String]) {
        keys.forEach {
            willChangeValue(forKey: $0)
        }
    }
    
    private func didChangeValueNotify(forKeys keys: [String]) {
        keys.forEach {
            didChangeValue(forKey: $0)
        }
    }
    
    public final override var isReady: Bool {
        return state == .ready && super.isReady
    }

    public final override var isExecuting: Bool {
        return state == .executing
    }

    public final override var isFinished: Bool {
        return state == .finished
    }

    public final override var isAsynchronous: Bool {
        return true
    }


    public final override func start() {
        if isCancelled {
            finish()
            return
        }

        state = .executing
        main()
    }

    open override func main() {
        fatalError("Subclasses must implement `main`.")
    }

    public final func finish() {
       if !isFinished { state = .finished }
    }
}
