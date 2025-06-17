import UIKit
import MapKit

class SavedMapViewController: UIViewController {
    private let mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.mapType = .satelliteFlyover

        // Globe style on iOS 15+
        if #available(iOS 15.0, *) {
            mapView.preferredConfiguration = MKImageryMapConfiguration(elevationStyle: .realistic)
        }

        mapView.showsBuildings = true
        mapView.showsTraffic = false
        mapView.pointOfInterestFilter = .includingAll
        return mapView
    }()
    var place: Place?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupMapView()
        if #available(iOS 15.0, *) {
            var globeCamera = MKMapCamera()
            globeCamera.centerCoordinate = CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0)
            globeCamera.pitch = 0
            globeCamera.altitude = 30000000 // High altitude for globe view
            mapView.setCamera(globeCamera, animated: false)
        }
    }

    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
