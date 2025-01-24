import CoreLocation
import MapKit
import SwiftUI

struct ContentView: View {
    @State var currentName = "Eduardo"
    @State var locationMgr = LocationManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
                .padding()
            HStack {
                Label("Nombre:", systemImage: "person.fill")
                TextField("Nombre", text: $currentName)
            }.padding(.horizontal)
        }
        .padding()
        Map {
            if let coordinate = locationMgr.userLocation {
                Annotation("Tu ubicación", coordinate: coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }
            }
        }.mapStyle(.standard)
    }
}

#Preview {
    ContentView()
}
