//
//  CercaAppWidget.swift
//  CercaAppWidget
//
//  Created by Eduardo González on 21/1/25.
//

import Combine
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

final class AsyncLocation: NSObject, CLLocationManagerDelegate {
    private let manager: CLLocationManager
    private let locationSubject: PassthroughSubject<Result<CLLocation, Error>, Never> = .init()

    var isAuthorizedForWidgetUpdates: Bool {
        manager.isAuthorizedForWidgetUpdates
    }

    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        locationSubject.send(.success(location))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.send(.failure(error))
    }

    enum Errors: Error {
        case missingOutput
    }

    func requestLocation() async throws -> CLLocation {
        let result: Result<CLLocation, Error> = try await withUnsafeThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var didReceiveValue = false
            cancellable = locationSubject.sink(
                receiveCompletion: { _ in
                    if !didReceiveValue {
                        // subject completed without a value…
                        continuation.resume(throwing: Errors.missingOutput)
                    }
                },
                receiveValue: { value in
                    // Make sure we only send a value once!
                    guard !didReceiveValue else {
                        return
                    }
                    didReceiveValue = true
                    // Cancel current sink
                    cancellable?.cancel()
                    // We either got a location or an error
                    continuation.resume(returning: value)
                }
            )
            // Now that we monitor locationSubject, ask for the location
            manager.requestLocation()
        }
        switch result {
        case .success(let location):
            // We got the location!
            return location
        case .failure(let failure):
            // We got an error :(
            throw failure
        }
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> LocationEntry {
       let entry = LocationEntry(date: Date(), value: .failure(.noLocation))
        print("Getting placeholder for widget \(entry)")
        return entry
    }

    func getSnapshot(in context: Context, completion: @escaping (LocationEntry) -> ()) {
        // Get last known location
        let entry = LocationEntry(date: Date(), value: .failure(.noLocation))
        print("Getting snapshot for widget \(entry)")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let value: Entry.Value
            let location = AsyncLocation()
            if location.isAuthorizedForWidgetUpdates {
                do {
                    let location = try await location.requestLocation()
                    value = .success(location)
                } catch {
                    value = .failure(.noLocation)
                }
            } else {
                value = .failure(.unauthorized)
            }
            let entry = LocationEntry(date: .now, value: value)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
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
        }
    }
}

struct CercaAppWidget: Widget {
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
    CercaAppWidget()
} timeline: {
    LocationEntry(date: .now, value: .failure(.noLocation))
}
