//
//  TOMApp.swift
//  TOM
//
//  Created by Ashish Dutt on 02/08/23.
//

import SwiftUI

@main
struct TOMApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: TOMDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
