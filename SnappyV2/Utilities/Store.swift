//
//  Store.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Combine

typealias Store<State> = CurrentValueSubject<State, Never>

extension Store {
    
    subscript<T>(keyPath: WritableKeyPath<Output, T>) -> T where T: Equatable {
        get { value[keyPath: keyPath] }
        set {
            var value = self.value
            if value[keyPath: keyPath] != newValue {
                value[keyPath: keyPath] = newValue
                self.value = value
            }
        }
    }
    
}

// MARK: -

extension ObservableObject {
    func loadableSubject<Value>(_ keyPath: WritableKeyPath<Self, Loadable<Value>>) -> LoadableSubject<Value> {
        let defaultValue = self[keyPath: keyPath]
        return .init(get: { [weak self] in
            self?[keyPath: keyPath] ?? defaultValue
        }, set: { [weak self] in
            guard var self = self else { return }
            let loadableValue = $0
            guaranteeMainThread {
                self[keyPath: keyPath] = loadableValue
            }
        })
    }
}
