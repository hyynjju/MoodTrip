// MapViewController.swift
import UIKit
import MapKit

class MapViewController: UIViewController {
    var place: Place? // ResultViewController로부터 전달받을 장소 데이터

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let mapView = MKMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.overrideUserInterfaceStyle = .dark // 다크 모드 유지
        mapView.delegate = self // 델리게이트 설정

        // 지구본 스타일 설정 (iOS 16 이상)
        if #available(iOS 16.0, *) {
            let config = MKImageryMapConfiguration(elevationStyle: .realistic)
            mapView.preferredConfiguration = config
        }

        view.addSubview(mapView)
        
        // 네비게이션 바 타이틀 설정
        title = "Map"
        navigationController?.navigationBar.prefersLargeTitles = false // 라지 타이틀 비활성화
        
        // 뒤로가기 버튼 색상 설정
        navigationController?.navigationBar.tintColor = .white

        // 장소 데이터가 있으면 해당 위치를 지도에 표시
        if let place = place {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
            annotation.coordinate = coordinate
            annotation.title = place.name
            annotation.subtitle = place.address
            mapView.addAnnotation(annotation)
            
            // 해당 위치로 지도 이동 및 확대
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000) // 5km 반경
            mapView.setRegion(region, animated: true)
        } else {
            // 장소 데이터가 없으면 지구 전체 보이게 설정
            let center = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            let camera = MKMapCamera(lookingAtCenter: center,
                                     fromDistance: 20000000, // 거리 크게 설정
                                     pitch: 0,
                                     heading: 0)
            mapView.setCamera(camera, animated: false)
        }
    }
}

// 지도에 핀이 제대로 표시되도록 MKMapViewDelegate 확장
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "PlaceAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true // 핀 탭 시 정보 표시
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) // 상세 정보 버튼
        } else {
            annotationView?.annotation = annotation
        }

        // 마커 색상 설정 (선택 사항)
        if let markerAnnotationView = annotationView as? MKMarkerAnnotationView {
            markerAnnotationView.markerTintColor = .systemBlue // 마커 색상
            markerAnnotationView.glyphText = "📍" // 마커 내부 텍스트 또는 이미지
        }

        return annotationView
    }

    // 콜아웃(말풍선)의 상세 정보 버튼 탭 시 동작 정의 (선택 사항)
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            // 핀에 대한 추가 정보 또는 외부 앱으로 연결 등
            print("Annotation Callout Tapped for: \(view.annotation?.title ?? "Unknown")")
            // 예를 들어, 해당 장소의 상세 페이지로 이동하거나, T Map, Kakao Map 등으로 외부 연결 가능
            if let place = place, let url = URL(string: "http://maps.apple.com/?ll=\(place.latitude),\(place.longitude)") {
                UIApplication.shared.open(url)
            }
        }
    }
}
