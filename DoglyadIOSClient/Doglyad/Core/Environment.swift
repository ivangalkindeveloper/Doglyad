//
//  Environment.swift
//  Doglyad
//
//  Created by Иван Галкин on 05.10.2025.
//

import Foundation

protocol EnvironmentProtocol: AnyObject {
    var baseURL: URL { get }
}

final class EnvironmentBase: EnvironmentProtocol {
    init(
        baseURL: URL
    ) {
        self.baseURL = baseURL
    }
    
    let baseURL: URL
}
