//
//  DiagnosticsRepository.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

protocol DiagnosticsRepositoryProtocol {
    func isOnBoardingCompleted() -> Bool
}

final class DiagnosticsRepository: DiagnosticsRepositoryProtocol {
    func isOnBoardingCompleted() -> Bool {false}
}

