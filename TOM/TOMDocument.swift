//
//  TOMDocument.swift
//  TOM
//
//  Created by Ashish Dutt on 02/08/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct TOMDocument: FileDocument{
    var text: String
    
    static var readableContentTypes = [UTType("com.ashishd1712.TOM.source")!]
    
    init(initialString: String = ""){
        text = initialString
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents{
            text = String(decoding: data, as: UTF8.self)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
    
}
