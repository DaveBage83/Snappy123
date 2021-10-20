//
//  Store.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Combine

typealias Store<State> = CurrentValueSubject<State, Never>

// MARK: -

extension ObservableObject {
    func loadableSubject<Value>(_ keyPath: WritableKeyPath<Self, Loadable<Value>>) -> LoadableSubject<Value> {
        let defaultValue = self[keyPath: keyPath]
        return .init(get: { [weak self] in
            self?[keyPath: keyPath] ?? defaultValue
        }, set: { [weak self] in
            self?[keyPath: keyPath] = $0
        })
    }
}
