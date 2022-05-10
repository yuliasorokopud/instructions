//
//  InstructionCreationView.swift
//  Instructions
//
//  Created by Yulia Sorokopud on 09.05.2022.
//

import SwiftUI

struct InstructionCreationView: View {
    @Binding var title: String
    @Binding var description: String
    var action: () -> Void

    var body: some View {
        VStack {
            Text("Title")
            TextField("Title", text: $title)
            Text("Description")
            TextField("Description", text: $description)
            Button("Save") {
                action()
            }
        }
    }
}
