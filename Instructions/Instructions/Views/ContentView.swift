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
    @State var editingMode: Bool = false
    @ObservedObject var arViewModel = ARViewModel()
    var body: some View {
        ZStack {
            ARViewContainer(arView: arViewModel.arView).edgesIgnoringSafeArea(.all)
            VStack {
                TopMenu(editingMode: $arViewModel.editingMode)
                Spacer()
                ButtonView(imageName: "cube.fill") {
                    arViewModel.addNewEntity()
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    let arView: ARView

    func makeUIView(context: Context) -> ARView {
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
