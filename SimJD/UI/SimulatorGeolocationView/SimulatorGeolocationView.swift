import MapKit
import SwiftUI
import Combine

struct SimulatorGeolocationView: View {
    let simulator: Simulator // Assume Simulator contains simulator-specific details like ID.
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var searchText = ""
    @State private var errorMessage: String?
    @State private var selectedLocation: CLLocationCoordinate2D?

    var body: some View {
        VStack {
            TextField("Enter a location", text: $searchText, onCommit: searchLocation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Map(coordinateRegion: $region, annotationItems: selectedLocation.map { [$0] } ?? []) { location in
                MapPin(coordinate: location)
            }
            .frame(height: 400)
            .cornerRadius(10)
            .padding()
            .onTapGesture(coordinateSpace: .global) { location in
                selectLocation(at: location)
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            if let selectedLocation = selectedLocation {
                Button("Set Simulator Location") {
                    updateSimulatorLocation(coordinate: selectedLocation)
                }
                .padding()
            }
        }
        .padding()
    }

    private func searchLocation() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchText) { placemarks, error in
            if let error = error {
                self.errorMessage = "Error finding location: \(error.localizedDescription)"
                return
            }

            guard let placemark = placemarks?.first, let location = placemark.location else {
                self.errorMessage = "Location not found."
                return
            }

            self.errorMessage = nil
            let coordinate = location.coordinate
            self.region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            self.selectedLocation = coordinate
        }
    }

    private func selectLocation(at location: CGPoint) {
        let mapView = MKMapView()
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        self.selectedLocation = coordinate
        self.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }

    private func updateSimulatorLocation(coordinate: CLLocationCoordinate2D) {
        let command = """
        xcrun simctl location \(simulator.id) set \(coordinate.latitude) \(coordinate.longitude)
        """
        runShellCommand(command)
    }

    @MainActor
    private func runShellCommand(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]
        task.launch()
        task.waitUntilExit()
    }
}
