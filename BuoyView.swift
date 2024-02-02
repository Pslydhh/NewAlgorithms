import SwiftUI

struct BuoyView: View {
    @Binding var tiltForwardBackward: Bool
    @Binding var upAndDown: Bool
    @Binding var leadingAnchorAnimate: Bool
    
    @State private var red = 1.0
    @State private var green = 1.0
    @State private var blue = 1.0
    
    let cRadius = 8.0
    
    var body: some View {
        ZStack {
            Image("buoy").overlay(Rectangle()
                .overlay(Color(red: red,green: green,blue: blue))
             ///add a corner radius only to the bottom corners
                .padding(.bottom, cRadius)
                .cornerRadius(cRadius)
                .padding(.bottom, -cRadius)
                .frame(width: 12, height: 17)
                .position(x: 112.5, y: 19.5))
            
            ///the animation for the blinking light
            .animation(Animation.easeOut(duration: 1).repeatForever(autoreverses: true),value: red)

            ///the animation for the anchor point motion
            .rotationEffect(.degrees(leadingAnchorAnimate ? 7 : -3), anchor: .leading) ///can use .bottom here too
            .animation(Animation.easeOut(duration: 0.9).repeatForever(autoreverses: true),value: leadingAnchorAnimate)
            
            ///the animation for the tilt forward and backward motion
            .rotationEffect(.degrees(tiltForwardBackward ? -20 : 15))
            .animation(Animation.easeInOut(duration: 1.0).delay(0.2).repeatForever(autoreverses: true),value: tiltForwardBackward)
            
            ///the animation for the up and down motion
            .offset(y: upAndDown ? -10 : 10)
            
            
        }.onAppear() {
            leadingAnchorAnimate.toggle()
            tiltForwardBackward.toggle()
            upAndDown.toggle()
            red = 0.5
            green = 0.5
            blue = 0.5
        }
    }
}

struct BuoyView_Previews: PreviewProvider {
    static var previews: some View {
        BuoyView(tiltForwardBackward: .constant(true), upAndDown: .constant(true), leadingAnchorAnimate: .constant(true))
    }
}


