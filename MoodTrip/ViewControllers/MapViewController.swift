import UIKit
import MapKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let mapView = MKMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.overrideUserInterfaceStyle = .dark  // 다크 모드 유지

        // 지구본 스타일 설정 (iOS 16 이상)
        if #available(iOS 16.0, *) {
            let config = MKImageryMapConfiguration(elevationStyle: .realistic)
            mapView.preferredConfiguration = config
        }

        // 지구 전체 보이게 설정
        let center = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let camera = MKMapCamera(lookingAtCenter: center,
                                 fromDistance: 20000000,  // 거리 크게 설정
                                 pitch: 0,
                                 heading: 0)
        mapView.setCamera(camera, animated: false)

        view.addSubview(mapView)
    }
}
