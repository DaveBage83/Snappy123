//
//  Store.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 15/09/2021.
//

import Combine

typealias Store<State> = CurrentValueSubject<State, Never>

