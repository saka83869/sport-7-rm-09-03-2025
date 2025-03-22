//
//  Ex.swift
//  Runner
//
//  Created by DEV APP on 20/3/25.
//

import Foundation

extension NSObject {
    // Generic function to handle throwing methods
    func executeWithCatch<T>(
        _ function: () throws -> T,
        key: String,
        catchHandler: ((Error) -> Void)? = nil
    ) -> T? {
        do {
            // Execute the throwing function
            return try function()
        } catch {
            print(error)
            return nil
        }
    }
    
}

func printLog(_ message: String,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
    
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("📍[\(fileName):\(line)] \(function) ➔ \(message)")
    #endif
}
