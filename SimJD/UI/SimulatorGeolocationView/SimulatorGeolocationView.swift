import MapKit
import SwiftUI
import Combine

struct SimulatorGeolocationView: View {
    enum Event {
        case updatedLocation
        case couldNotUpdateLocation
        case coordinateTranslationFailed
    }

    @Bindable var simManager: SimulatorManager
    var sendEvent: (Event) -> Void

    private let position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 37.773972,
                longitude: -122.431297
            ),
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )

    @State private var marker = CLLocationCoordinate2D(
        latitude: 37.773972,
        longitude: -122.431297
    )

    var body: some View {
        MapReader { proxy in
            Map(initialPosition: position) {
                Marker("Selected Location", coordinate: marker)
            }
            .onTapGesture { position in
                if let coordinate = proxy.convert(position, from: .local) {
                    self.marker = coordinate
                } else {
                    sendEvent(.coordinateTranslationFailed)
                }
            }
        }
        .toolbar {
            Button("Select Location") {
                guard let simulator = simManager.selectedSimulator else { return }
                switch simManager.updateLocation(
                    in: simulator,
                    latitude: marker.latitude,
                    longtitude: marker.longitude
                ) {
                case .success:
                    sendEvent(.updatedLocation)
                case .failure:
                    sendEvent(.couldNotUpdateLocation)
                }
            }
        }
    }
}
