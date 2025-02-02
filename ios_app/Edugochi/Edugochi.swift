//
//  CercaAppApp.swift
//  CercaApp
//
//  Created by Eduardo González on 21/1/25.
//

import SwiftData
import SwiftUI

@main
struct CercaAppApp: App {
    
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: StoredData.self)
    }
}
