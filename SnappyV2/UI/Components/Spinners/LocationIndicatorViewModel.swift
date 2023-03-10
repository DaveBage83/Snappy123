//
//  LocationIndicatorViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 11/01/2023.
//

import Foundation
import Combine

class LocationLoadingIndicatorViewModel: ObservableObject {
    let container: DIContainer
    
    // Constants
    struct Constants {
        struct AnimationDelay {
            static let min = 0.1
            static let mid = 0.3
            static let max = 0.5
        }
        
        struct Degrees {
            static let max = 180.0
            static let min = 0.0
        }
    }
    
    // Rotation degrees
    @Published var blueDegree: Double = 0.0
    @Published var redDegree: Double = 0.0
    @Published var blue2Degree: Double = 0.0
    
    // Flipped variables
    @Published var blueFlipped = false
    @Published var blue2Flipped = false
    @Published var redFlipped = false
    
    @Published var isReversing = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        setInitialDegree()
        setupDegrees()
        setupFlippedStates()
    }
    
    private func setInitialDegree() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.AnimationDelay.mid, execute: {
            self.blueDegree = Constants.Degrees.max
        })
    }
    
    private func setupDegrees() {
        $blueDegree
            .receive(on: RunLoop.main)
            .sink { [weak self] degree in
                guard let self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + (self.isReversing ? Constants.AnimationDelay.max : Constants.AnimationDelay.mid), execute: {
                    if degree == Constants.Degrees.max {
                        self.blueFlipped = true
                    } else if self.isReversing {
                        self.isReversing = false
                        self.blueDegree = Constants.Degrees.max
                    }
                })
                
            }
            .store(in: &cancellables)
        
        $redDegree
            .receive(on: RunLoop.main)
            .sink { [weak self] degree in
                guard let self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.AnimationDelay.mid, execute: {
                    self.blue2Flipped = degree == Constants.Degrees.max
                })
            }
            .store(in: &cancellables)
        
        $blue2Degree
            .receive(on: RunLoop.main)
            .sink { [weak self] degree in
                guard let self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.AnimationDelay.mid, execute: {
                    self.redFlipped = degree == Constants.Degrees.max
                })
                
            }
            .store(in: &cancellables)
    }
    
    private func setupFlippedStates() {
        $blueFlipped
            .receive(on: RunLoop.main)
            .sink { [weak self] flipped in
                guard let self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.AnimationDelay.min, execute: {
                    if flipped {
                        self.redDegree = Constants.Degrees.max
                    }
                })
                
            }
            .store(in: &cancellables)
        
        $blue2Flipped
            .receive(on: RunLoop.main)
            .sink { [weak self] flipped in
                guard let self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.AnimationDelay.min, execute: {
                    if flipped {
                        self.blue2Degree = Constants.Degrees.max
                        self.isReversing = true
                    } else if self.isReversing {
                        self.blueDegree = Constants.Degrees.min
                        self.blueFlipped = false
                    }
                })
            }
            .store(in: &cancellables)
        
        $redFlipped
            .receive(on: RunLoop.main)
            .sink { [weak self] flipped in
                guard let self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.AnimationDelay.min, execute: {
                    
                    if flipped {
                        self.blue2Degree = Constants.Degrees.min
                    } else {
                        self.redDegree = Constants.Degrees.min
                    }
                })
            }
            .store(in: &cancellables)
    }
}
