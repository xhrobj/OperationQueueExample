//
//  BeersFetchOperation.swift
//  OperationQueueExample
//

import Foundation

final class BeersFetchOperation: AsyncOperation {
    
    var result: Result<[JSON.Beer], Error>?
    private let endpointPath: String
    
    init(endpointPath: String) {
        self.endpointPath = endpointPath
    }
    
    override func main() {
        if isCancelled {
            finish()
        }
        NetworkManager.shared.fetch(endpointPath: endpointPath) {
            (beersJson: [JSON.Beer]) in
            self.result = .success(beersJson)
            self.finish()
        }
    }
}
