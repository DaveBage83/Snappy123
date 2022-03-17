//
//  Publisher+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 04/08/2021.
//

import Combine

extension Publisher where Failure == Never {
    
    /// Use this, most of the time, instead of .assign, as it keeps a weak reference
    public func assignWeak<Root>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> AnyCancellable where Root: AnyObject {
        sink { [weak object] (value) in
            guard let object = object else { return }
            object[keyPath: keyPath] = value
        }
    }
}

extension Publisher where Output == Void {
    func sink(receiveCompletion: @escaping ((Subscribers.Completion<Failure>) -> Void)) -> AnyCancellable {
        sink(receiveCompletion: receiveCompletion, receiveValue: {})
    }
}
