//
//  ContentView.swift
//  TOM
//
//  Created by Ashish Dutt on 02/08/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: TOMDocument
    @StateObject private var viewModel = ViewModel()
    var body: some View {
        NavigationSplitView{
            VStack{
                ForEach(viewModel.registers.keys.sorted(), id: \.self){register in
                    RegisterView(
                        name: register,
                        value: viewModel.registers[register, default: 0],
                        style: Color.blue.gradient
                    )
                }
                RegisterView(
                    name: "ZX",
                    value: viewModel.zx,
                    style: Color.red.gradient
                )
                Spacer()
            }
            .padding()
        } detail: {
            VSplitView {
                TextEditor(text: $document.text)
                    .font(.system(size: 18).monospaced())
                    .scrollContentBackground(.hidden)
                    .padding()
                TextEditor(text: .constant(viewModel.log))
                    .font(.system(size: 18).monospaced())
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .onAppear(perform: viewModel.reset)
        .toolbar {
            Button{
                viewModel.run(code: document.text)
            } label: {
                Label("Play", systemImage: "play")
                    .symbolVariant(.fill)
            }
            
            Button{
                viewModel.reset()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(TOMDocument()))
    }
}
