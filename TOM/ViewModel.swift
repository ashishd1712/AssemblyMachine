//
//  ViewModel.swift
//  TOM
//
//  Created by Ashish Dutt on 03/08/23.
//

import Foundation
import RegexBuilder

class ViewModel: ObservableObject{
    @Published var registers = [String : Int]()
    @Published var zx = 0
    
    @Published var log = ""
    private var lineNumber = 0
    
    func reset() {
        registers = [
            "AX":0,
            "BX":0,
            "CX":0,
            "DX":0,
            "EX":0,
            "FX":0,
            "GX":0,
            "HX":0
        ]
        zx = 0
        
        log = "Resetting all registers to their defaults..."
        lineNumber = 0
    }
    
    func run(code: String){
        reset()
        guard code.isEmpty == false else { return }
        let movRegex = Regex { "MOV "; matchDigits(); ", "; matchRegisters() }
        let addRegex = Regex { "ADD "; matchRegisters(); ", "; matchRegisters() }
        let subRegex = Regex { "SUB "; matchRegisters(); ", "; matchRegisters() }
        let copyRegex = Regex { "COPY "; matchRegisters(); ", "; matchRegisters() }
        let andRegex = Regex { "AND "; matchRegisters(); ", "; matchRegisters() }
        let orRegex = Regex { "OR "; matchRegisters(); ", "; matchRegisters() }
        let cmpRegex = Regex { "CMP "; matchRegisters(); ", "; matchRegisters() }
        let jmpRegex = Regex { "JMP "; matchDigits() }
        let jeqRegex = Regex { "JEQ "; matchDigits() }
        let jneqRegex = Regex { "JNEQ "; matchDigits() }
        
        
        let lines = code.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        var commandsUsed = 0
        while lineNumber < lines.count {
            let line = lines[lineNumber]
            
            if let match = line.wholeMatch(of: movRegex) {
                mov(value: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: addRegex){
                add(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: subRegex){
                sub(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: copyRegex){
                copy(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: andRegex){
                and(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: orRegex){
                or(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: cmpRegex){
                cmp(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: jmpRegex){
                jmp(to: match.output.1)
            } else if let match = line.wholeMatch(of: jeqRegex){
                jeq(to: match.output.1)
            } else if let match = line.wholeMatch(of: jneqRegex){
                jneq(to: match.output.1)
            } else {
                addlog("*** ERROR: Unknown command; Remember, all commands and registers are case-sensitive. ***")
            }
            
            lineNumber += 1
            commandsUsed += 1
            guard commandsUsed < 10_000 else{
                addlog("*** ERROR: Too many commands; exiting. ***")
                return
            }
        }
        
    }
    
    private func matchDigits() -> TryCapture<(Substring, Int)> {
        TryCapture{
            OneOrMore(.digit)
        } transform: { number in
            Int(number)
        }
    }
    
    private func matchRegisters() -> Capture<(Substring, String)> {
        Capture{
            "A"..."H"
            "X"
        }transform: { match in
            String(match)
        }
    }
    
    private func addlog(_ message: String){
        log += "\nLine \(lineNumber + 1): \(message)"
    }
    
    private func clamp(register: String) -> Bool {
        if registers[register, default: 0] < 0 {
            addlog("*** WARNING: Line \(lineNumber + 1) has set \(register) to a value below 0. It has been clamped to 0.***")
            registers[register] = 0
            return true
        } else if registers[register, default: 0] > 255 {
            addlog("*** WARNING: Line \(lineNumber + 1) has set \(register) to a value above 255. It has been clamped to 255.***")
            registers[register] = 255
            return true
        }
        return false
    }
    
    private func mov(value: Int, destination: String){
        registers[destination] = value
        if clamp(register: destination){ } else {
            addlog("Moving \(value) into \(destination)")
        }
    }
    
    private func add(source: String, destination: String){
        registers[destination, default: 0] += registers[source, default: 0]
        if clamp(register: destination){ } else {
            addlog("Adding \(source) to \(destination)")
        }
    }
    private func sub(source: String, destination: String){
        registers[destination, default: 0] -= registers[source, default: 0]
        if clamp(register: destination){ } else {
            addlog("Subtracting \(source) from \(destination)")
        }
    }
    
    private func copy(source: String, destination: String){
        registers[destination, default: 0] = registers[source, default: 0]
        if clamp(register: destination){ } else {
            addlog("Copying \(source) to \(destination)")
        }
    }
    
    private func and(source: String, destination: String){
        registers[destination, default: 0] &= registers[source, default: 0]
        if clamp(register: destination){ } else {
            addlog("ANDing \(source) with \(destination)")
        }
    }
    
    private func or(source: String, destination: String){
        registers[destination, default: 0] |= registers[source, default: 0]
        if clamp(register: destination){ } else {
            addlog("ORing \(source) with \(destination)")
        }
    }
    
    private func cmp(source: String, destination: String){
        zx = registers[destination, default: 0] == registers[source, default: 0] ? 1 : 0
        if clamp(register: destination){ } else {
            addlog("Comparing \(source) with \(destination)")
        }
    }
    
    private func jeq(to line: Int){
        if zx == 1 {
            addlog("ZX is 1. Jumping to line \(line)")
            lineNumber = line - 2
        }
    }
    
    private func jneq(to line: Int){
        if zx == 0 {
            addlog("ZX is 0. Jumping to line \(line)")
            lineNumber = line - 2
        }
    }
    
    private func jmp(to line: Int){
        addlog("Jumping to line \(line)")
        lineNumber = line - 2
    }
}
