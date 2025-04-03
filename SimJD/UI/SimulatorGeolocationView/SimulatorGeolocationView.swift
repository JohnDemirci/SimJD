import MapKit
import SwiftUI
import Combine

@MainActor
@Observable
final class SimulatorGeolocationViewModel {
    typealias Event = SimulatorGeolocationView.Event
    let sendEvent: (Event) -> Void

    var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 37.773972,
                longitude: -122.431297
            ),
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )

    var marker = CLLocationCoordinate2D(
        latitude: 37.773972,
        longitude: -122.431297
    )

    init(sendEvent: @escaping (Event) -> Void) {
        self.sendEvent = sendEvent
    }

    func didTapOnMap(converter: MapProxyConversion, position: CGPoint) {
        if let coordinate = converter.convert(point: position) {
            marker = coordinate
        } else {
            sendEvent(.didFailCoordinateProxy)
        }
    }

    func didSelectSelectLocation(manager: SimulatorManager) {
        guard let simulator = manager.selectedSimulator else { return }

        switch manager.updateLocation(
            in: simulator,
            latitude: marker.latitude,
            longtitude: marker.longitude
        ) {
        case .success:
            sendEvent(.didUpdateLocation)
        case .failure:
            sendEvent(.didFailUpdateLocation)
        }
    }
}

struct SimulatorGeolocationView: View {
    enum Event {
        case didFailCoordinateProxy
        case didFailUpdateLocation
        case didUpdateLocation
    }

    private let simManager: SimulatorManager = .live
    @State private var viewModel: SimulatorGeolocationViewModel

    init(sendEvent: @escaping (Event) -> Void) {
        self.viewModel = .init(sendEvent: sendEvent)
    }

    var body: some View {
        MapReader { proxy in
            Map(position: $viewModel.position) {
                Marker("Selected Location", coordinate: viewModel.marker)
            }
            .onTapGesture { position in
                viewModel.didTapOnMap(
                    converter: MapProxyConverter(
                        proxy: proxy,
                        coordinateSpace: .local
                    ),
                    position: position
                )
            }
        }
        .toolbar {
            Button("Select Location") {
                viewModel.didSelectSelectLocation(manager: simManager)
            }
        }
    }
}
