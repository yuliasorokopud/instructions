//
//  ARViewModel.swift
//  Instructions
//
//  Created by Yulia Sorokopud on 05.05.2022.
//

import Foundation

class ARViewModel: ObservableObject {
    @Published public var editingMode = false

    let arView: ARViewManager

    func addNewEntity() {
        guard editingMode else { return }
        arView.addNewEntity()
    }

    init() {
        self.arView = ARViewManager(frame: .zero)
    }
}
