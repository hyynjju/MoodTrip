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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: 240, height: 180)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SimplePlaceCardCell.self, forCellWithReuseIdentifier: SimplePlaceCardCell.reuseIdentifier)
        collectionView.dataSource = self

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            collectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
        if #available(iOS 15.0, *) {
            let focusedCamera = MKMapCamera()
            focusedCamera.centerCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780) // Seoul
            focusedCamera.altitude = 3000000
            focusedCamera.pitch = 0
            mapView.setCamera(focusedCamera, animated: false)
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

extension SavedMapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarkedPlaces.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimplePlaceCardCell.reuseIdentifier, for: indexPath) as? SimplePlaceCardCell else {
            return UICollectionViewCell()
        }
        let place = bookmarkedPlaces[indexPath.item]
        cell.configure(with: place)
        return cell
    }
}

class SimplePlaceCardCell: UICollectionViewCell {
    static let reuseIdentifier = "SimplePlaceCardCell"
    
    private let placeImageView = UIImageView()
    private let gradientOverlay = UIView()
    private let gradientLayer = CAGradientLayer()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .clear

        placeImageView.contentMode = .scaleAspectFill
        placeImageView.clipsToBounds = true
        placeImageView.layer.cornerRadius = 12
        placeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(placeImageView)

        gradientOverlay.translatesAutoresizingMaskIntoConstraints = false
        placeImageView.addSubview(gradientOverlay)

        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientOverlay.layer.addSublayer(gradientLayer)

        nameLabel.font = .appFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        placeImageView.addSubview(nameLabel)

        descriptionLabel.font = .appFont(ofSize: 14)
        descriptionLabel.textColor = .white.withAlphaComponent(0.8)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        placeImageView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            placeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            placeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            placeImageView.heightAnchor.constraint(equalToConstant: 120),

            gradientOverlay.leadingAnchor.constraint(equalTo: placeImageView.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor),
            gradientOverlay.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor),
            gradientOverlay.heightAnchor.constraint(equalTo: placeImageView.heightAnchor, multiplier: 0.7),

            nameLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -2),
            nameLabel.leadingAnchor.constraint(equalTo: placeImageView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: -12),

            descriptionLabel.bottomAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: -12),
            descriptionLabel.leadingAnchor.constraint(equalTo: placeImageView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: -12)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientOverlay.bounds
    }

    func configure(with place: Place) {
        nameLabel.text = place.name
        descriptionLabel.text = place.description
        placeImageView.image = nil

        if let url = URL(string: place.imageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self else { return }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.placeImageView.image = image
                        self.placeImageView.bringSubviewToFront(self.gradientOverlay)
                        self.placeImageView.bringSubviewToFront(self.nameLabel)
                        self.placeImageView.bringSubviewToFront(self.descriptionLabel)
                        self.setNeedsLayout()
                    }
                }
            }.resume()
        } else {
            placeImageView.image = UIImage(named: "placeholderImage")
            placeImageView.bringSubviewToFront(gradientOverlay)
            placeImageView.bringSubviewToFront(nameLabel)
            placeImageView.bringSubviewToFront(descriptionLabel)
            setNeedsLayout()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        placeImageView.image = nil
        nameLabel.text = nil
        descriptionLabel.text = nil
    }
}
