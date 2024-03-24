/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view holding buttons that add new slide pieces to the ride.
*/

import SwiftUI

struct PieceShelfTrackButtonsView: View {
    @Environment(AppState.self) var appState
    @State private var endPieceIsInRealityView = false
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            GridRow {
                ImageButton(
                    title: "Simple Ramp",
                    imageName: appState.simpleRampImageName,
                    buttonAction: { button in
                        appState.clearSelection()
                        appState.addEntityToScene(for: .slide1, material: appState.selectedMaterialType)
                    }
                )
                .disabled(appState.phase != .buildingTrack)
                .accessibilityElement()
                .accessibilityLabel(Text("Add straight slide piece."))
                
                ImageButton(
                    title: "Right Turn",
                    imageName: appState.rightTurnImageName,
                    buttonAction: { button in
                        appState.clearSelection()
                        appState.addEntityToScene(for: .slide3, material: appState.selectedMaterialType)
                    }
                )
                .disabled(appState.phase != .buildingTrack)
                .accessibilityElement()
                .accessibilityLabel(Text("Add right turn piece."))
                
                ImageButton(
                    title: "Left Turn",
                    imageName: appState.leftTurnImageName,
                    buttonAction: { button in
                        appState.clearSelection()
                        appState.addEntityToScene(for: .slide4, material: appState.selectedMaterialType)
                    }
                )
                .disabled(appState.phase != .buildingTrack)
                .accessibilityElement()
                .accessibilityLabel(Text("Add left turn piece."))
            }
            GridRow {
                ImageButton(
                    title: "Slide",
                    imageName: appState.slideImageName,
                    buttonAction: { button in
                        appState.clearSelection()
                        appState.addEntityToScene(for: .slide2, material: appState.selectedMaterialType)
                    }
                )
                .disabled(appState.phase != .buildingTrack)
                .accessibilityElement()
                .accessibilityLabel(Text("Add straight slide piece."))
                
                ImageButton(
                    title: "Spiral",
                    imageName: appState.spiralImageName,
                    buttonAction: { button in
                        appState.clearSelection()
                        appState.addEntityToScene(for: .slide5, material: appState.selectedMaterialType)
                    }
                )
                .disabled(appState.phase != .buildingTrack)
                .accessibilityElement()
                .accessibilityLabel(Text("Add spiral slide piece."))
                ImageButton(
                    title: "Finish Line",
                    imageName: appState.goalImageNamne,
                    buttonAction: { button in
                        appState.addGoalPiece()
                        appState.hideMarkerPiece()
                        appState.clearSelection()
                        appState.updateConnections()
                    }
                )
                .disabled(endPieceIsInRealityView)
                .accessibilityElement()
                .accessibilityLabel(Text("Add finish line."))
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                        endPieceIsInRealityView = appState.goalPiece?.parent != nil
                    }
                }
            }
        }
        .padding(.horizontal, 25)

    }
}

#Preview {
    PieceShelfTrackButtonsView()
        .environment(AppState())
}
