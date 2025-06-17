import UIKit
import MapKit

class SavedMapViewController: UIViewController {
    
    var place: Place?
    
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
    private var bookmarkedPlaces: [Place] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tabBar = self.tabBarController?.tabBar {
            let transparentAppearance = UITabBarAppearance()
            transparentAppearance.configureWithTransparentBackground()
            tabBar.standardAppearance = transparentAppearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = transparentAppearance
            }
        }
        view.backgroundColor = .clear
        setupMapView()
        loadBookmarkedPlaces()
        displayBookmarkedPlacesOnMap()
        if #available(iOS 15.0, *) {
            var globeCamera = MKMapCamera()
            globeCamera.centerCoordinate = CLLocationCoordinate2D(latitude: 35.8, longitude: 127.5)
            globeCamera.pitch = 0
            globeCamera.altitude = 30000000 // High altitude for initial globe view
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let focusedCamera = MKMapCamera()
                focusedCamera.centerCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780) // Example coordinate (Seoul)
                focusedCamera.altitude = 3000000
                UIView.animate(withDuration: 2.0, animations: {
                    self.mapView.setCamera(focusedCamera, animated: true)
                })
            }
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

    private func loadBookmarkedPlaces() {
        bookmarkedPlaces = BookmarkManager.getBookmarkedPlaces()
    }

    private func displayBookmarkedPlacesOnMap() {
        for place in bookmarkedPlaces {
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            mapView.addAnnotation(annotation)
        }
    }
}
