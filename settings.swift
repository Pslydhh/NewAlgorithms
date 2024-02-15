/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Debug setting controls for the globe module.
*/

import SwiftUI

/// Debug setting controls for the globe module.
struct GlobeSettings: View {
    @Environment(ViewModel.self) private var model

    var body: some View {
        @Bindable var model = model
        
        VStack {
            Text("Globe module debug settings")
                .font(.title)
            Form {
                EarthSettings(configuration: $model.globeEarth)
                Section("System") {
                    Grid(alignment: .leading, verticalSpacing: 20) {
                        Button("Reset") {
                            model.globeEarth = .globeEarthDefault
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    GlobeSettings()
        .frame(width: 500)
        .environment(ViewModel())
}

/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A modifier for adding a developer settings button.
*/

import SwiftUI

/// A Boolean that determines the visibility of a debug settings button.
///
/// It can be helpful during development to have real time control over
/// aspects of your app's models and content. For example, you might want
/// to tune a scaling factor so a scaled entity feels just right when
/// in Full Space. Set the `showDebugSettings` parameter to `true` to
/// make a button appear as an ornament in the app's main window that enables
/// you configure certain aspects of each module. You would set this to
/// `false`, or remove the settings configuration logic entirely, before
/// shipping the app.
let showDebugSettings = false

extension View {
    /// Adds a button in an ornament that opens a settings panel.
    func settingsButton(
        module: Module
    ) -> some View {
        self.modifier(
            SettingsButtonModifier(module: module)
        )
    }
}

/// A modifier that adds a button that opens a settings panel.
private struct SettingsButtonModifier: ViewModifier {
    var module: Module

    @State private var showSettings = false

    func body(content: Content) -> some View {
        content
            .ornament(
                visibility: showDebugSettings ? .visible : .hidden,
                attachmentAnchor: .scene(.bottom)
            ) {
                Button {
                    showSettings = true
                } label: {
                    Label("Settings", systemImage: "gear")
                        .labelStyle(.iconOnly)
                }
                .popover(isPresented: $showSettings) {
                    module.settingsView
                        .padding(.vertical)
                        .frame(width: 500, height: 400)
                }
            }
    }
}

extension Module {
    @ViewBuilder
    fileprivate var settingsView: some View {
        switch self {
        case .globe: GlobeSettings()
        case .orbit: OrbitSettings()
        case .solar: SolarSystemSettings()
        }
    }
}
