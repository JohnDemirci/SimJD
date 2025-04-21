import MapKit
import SwiftUI
import Combine

struct SimulatorGeolocationView: View {
    @State private var viewModel: SimulatorGeolocationViewModel

    init(viewModel: SimulatorGeolocationViewModel) {
        self.viewModel = viewModel
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
                viewModel.didSelectSelectLocation()
            }
        }
    }
}
