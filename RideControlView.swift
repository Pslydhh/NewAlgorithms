/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view for controlling the ride while it's running.
*/

import SwiftUI
import RealityKit

struct RideControlView: View {
    @Environment(AppState.self) var appState
    @State var elapsed: Double = 0.0
    @State private var animateIn = true
    @State private var canStartRide = false
    @State private var paused = true

    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Toggle(isOn: $paused) {
                Label(shouldPauseRide ? "Play" : "Pause", systemImage: shouldPauseRide ? "play.fill" : "pause.fill")
                    .labelStyle(.iconOnly)
            }
            .toggleStyle(.button)
            .padding(.leading, 17)
            .accessibilityElement()
            .accessibilityLabel(shouldPauseRide ? Text("Play Ride") : Text("Pause Ride"))
            
            let elapsedTime = min(max(elapsed, 0), appState.rideDuration)
            ProgressView(value: elapsedTime, total: appState.rideDuration)
                .tint(.white)
                .onReceive(timer) { _ in
                    if pauseStartTime == 0 {
                        elapsed = (Date.timeIntervalSinceReferenceDate - appState.rideStartTime)
                    } else {
                        elapsed = (Date.timeIntervalSinceReferenceDate - appState.rideStartTime -
                                   (Date.timeIntervalSinceReferenceDate - pauseStartTime))
                    }
                }
                .accessibilityElement()
                .accessibilityValue(Text("\(String(format: "%2.0f", elapsed) + "percent complete.")"))
            
            Button {
                shouldCancelRide = true
                Task {
                    // Pause a moment to let the previous ride cancel.
                    try await Task.sleep(for: .seconds(0.1))
                    appState.resetRideAnimations()
                    appState.goalPiece?.stopWaterfall()
                    appState.startRide()
                    appState.music = (shouldPauseRide) ? .silent : .ride
                    appState.addHoverEffectToConnectables()
                }
            } label: {
                Label("Restart Ride", systemImage: "arrow.counterclockwise")
                    .labelStyle(.iconOnly)
            }
            .padding(.trailing, 9)
            .accessibilityElement()
            .accessibilityValue(Text("Start the ride over from the beginning."))
        }
        .opacity(animateIn ? 0.0 : 1.0)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                withAnimation(.easeInOut(duration: 0.7)) {
                    animateIn = false
                }
            }
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                canStartRide = appState.canStartRide
            }
        }
        .onDisappear {
            animateIn = true
        }
        .onChange(of: paused) {
            shouldPauseRide.toggle()
            
            if !shouldPauseRide {
                appState.rideStartTime += Date.timeIntervalSinceReferenceDate - pauseStartTime
                appState.startPiece?.setRideLights(to: true, speed: 1.0)
                appState.goalPiece?.setRideLights(to: true, speed: 1.0)
                SoundEffectPlayer.shared.resumeAll()
            } else {
                appState.startPiece?.setRideLights(to: true, speed: 0.0)
                appState.goalPiece?.setRideLights(to: true, speed: 0.0)
                SoundEffectPlayer.shared.pauseAll()
            }
            
            appState.music = shouldPauseRide ? .silent : .ride
        }
    }
}

#Preview {
    let appState = AppState()
    appState.startPiece = Entity()
    appState.goalPiece = Entity()
    return RideControlView().environment(appState)
}
