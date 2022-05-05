//
//  ContentView.swift
//  Instructions
//
//  Created by Yulia Sorokopud on 04.05.2022.
//

import RealityKit
import ARKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {

    func makeUIView(context: Context) -> ARView {
        let arView = CustomARView(frame: .zero)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
