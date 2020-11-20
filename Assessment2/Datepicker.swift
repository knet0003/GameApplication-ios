//
//  Datepicker.swift
//  Assessment2
//
//  Created by Net Keovechchta on 2020/11/20.
//

import SwiftUI

struct ContentView: View {
    @State private var sessionTime = Date()
    
    var body: some View{
        
        Form{
            DatePicker("Please enter a date" , selection: $sessionTime, in: Date()...)
        }
    }
    
    
    
    
}

