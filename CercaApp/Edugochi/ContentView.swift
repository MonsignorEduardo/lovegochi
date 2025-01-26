import Alamofire
import CoreLocation
import MapKit
import SwiftData
import SwiftUI

enum Constants {
    static let serverUrl: String = "https://4c34-79-150-30-50.ngrok-free.app"
}

struct UpdateLocationParameter: Encodable {
    let name: String
    let latitude: Double
    let longitude: Double
}

struct ContentView: View {
    @Query var dataQuery: [StoredData]
    var data: StoredData? { dataQuery.first }

    var body: some View {
        if let storedData = data {
            WithData(data: storedData)
        } else {
            NoData()
        }
    }
}

struct NoData: View {
    @State var name: String = ""
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack {
            Label("Nombre", systemImage: "person.fill")

            TextField("Ingrese su nombre", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Guardar") {
                if !name.isEmpty {
                    let data = StoredData(name: name)
                    context.insert(data)
                }
            }

        }.padding(.horizontal)
    }
}

struct WithData: View {
    var data: StoredData
    @State var locationMgr = LocationManager()
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack {
            Text("Bienvenido \(data.name)")
            Text("Latitud: \(locationMgr.location.coordinate.latitude)")
            Text("Longitud: \(locationMgr.location.coordinate.longitude)")
            Button("Borrar usuario"){
                context.delete(data)
            }
        }.task {
            let parameters = UpdateLocationParameter(name: data.name, latitude: locationMgr.location.coordinate.latitude, longitude: locationMgr.location.coordinate.longitude)

            AF.request("\(Constants.serverUrl)/api/v1/location", method: .post,
                       parameters: parameters, encoder: JSONParameterEncoder.default).validate().responseData {
                response in debugPrint(response)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StoredData.self, configurations: config)

    container.mainContext.insert(StoredData(name: "Edugochi"))

    return ContentView().modelContainer(container)
}
