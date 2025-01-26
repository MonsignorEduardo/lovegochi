//
//  Minimapa.swift
//  Minimapa
//
//  Created by Eduardo González on 24/1/25.
//

import CoreLocation
import SwiftUI
import WidgetKit

struct LocationEntry: TimelineEntry {
    enum Error: Swift.Error {
        /// Location is not authorized for the widget.
        case unauthorized
        /// For some other reason, location was not available.
        case noLocation
    }

    typealias Value = Result<CLLocation, Error>

    let date: Date
    let value: Value
}

struct Provider: TimelineProvider {
    let locationManager = LocationManager()

    func placeholder(in context: Context) -> LocationEntry {
        let entry = LocationEntry(date: Date(), value: .failure(.noLocation))
        print("Getting placeholder for widget \(entry)")
        return entry
    }

    func getSnapshot(in context: Context, completion: @escaping (LocationEntry) -> ()) {
        // TODO: Get last known location
        let entry = LocationEntry(date: Date(), value: .failure(.noLocation))
        print("Getting snapshot for widget \(entry)")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        if locationManager.isAuthorizedForWidgetUpdates{
            Task {
                do {
                    let location = try await locationManager.currentLocation
                    let entry = LocationEntry(date: Date(), value: .success(location))
                    print("Getting timeline for widget \(entry)")
                    completion(Timeline(entries: [entry], policy: .never))
                }
                
                catch {
                    print("Error getting location")
                }
            }
        }
        else{
            print("Location not authorized")
            let entry = LocationEntry(date: Date(), value: .failure(.unauthorized))
            completion(Timeline(entries: [entry], policy: .never))
        }
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct CercaAppWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
            Divider()
            Text("Location:")
            switch entry.value {
            case .success(let location):
                Text(location.description)
            case .failure(let error):
                Text(error.localizedDescription)
            }
        }.task {
            print("Widget entry view task")
            print("Entry: \(entry.value)")
        }
    }
}

struct Minimapa: Widget {
    let kind: String = "CercaAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                CercaAppWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CercaAppWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemSmall) {
    Minimapa()
} timeline: {
    LocationEntry(date: .now, value: .failure(.noLocation))
}
