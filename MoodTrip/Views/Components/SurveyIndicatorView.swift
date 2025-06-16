import UIKit

class SurveyIndicatorView: UIView {
    
    var numberOfQuestions: Int = 0 {
        didSet {
            // 질문 수가 변경되면 인디케이터를 다시 설정합니다.
            setupIndicators()
            updateIndicator(for: currentQuestionIndex) // 현재 인덱스에 맞춰 업데이트
        }
    }
    var currentQuestionIndex: Int = 0 {
        didSet {
            // 현재 인덱스가 변경되면 인디케이터의 상태를 업데이트합니다.
            updateIndicator(for: currentQuestionIndex)
        }
    }
    
    private let indicatorGap: CGFloat = 6 // 각 인디케이터 사이의 간격
    private let indicatorColor = UIColor(hex: "#73C2FF") // 완료된 인디케이터 색상
    
    private var indicatorViews: [UIView] = [] // 각 인디케이터 뷰를 저장할 배열
    private let stackView = UIStackView() // 인디케이터들을 담을 스택 뷰
    
    init(numberOfQuestions: Int) {
        self.numberOfQuestions = numberOfQuestions
        super.init(frame: .zero)
        setupStackView()
        setupIndicators() // 초기 인디케이터 설정
        updateIndicator(for: currentQuestionIndex) // 초기 상태 업데이트
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 스택 뷰 초기 설정
    private func setupStackView() {
        stackView.axis = .horizontal // 가로 방향으로 정렬
        stackView.spacing = indicatorGap // 인디케이터 사이 간격 설정
        stackView.alignment = .center // 세로 중앙 정렬
        stackView.distribution = .fillEqually // 모든 인디케이터가 같은 너비를 가지도록
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20), // 양쪽 20픽셀 마진
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20), // 양쪽 20픽셀 마진
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // 인디케이터 뷰들을 생성하고 스택 뷰에 추가합니다.
    private func setupIndicators() {
        // 기존 인디케이터 뷰들을 제거합니다.
        indicatorViews.forEach { $0.removeFromSuperview() }
        indicatorViews.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for _ in 0..<numberOfQuestions {
            let indicator = UIView()
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.backgroundColor = .white.withAlphaComponent(0.1) // 미완료 상태 (0.1 오퍼시티 흰색)
            indicator.layer.cornerRadius = 2
            indicator.clipsToBounds = true
            stackView.addArrangedSubview(indicator)
            indicatorViews.append(indicator) // 배열에 추가하여 나중에 쉽게 접근
            
            NSLayoutConstraint.activate([
                indicator.heightAnchor.constraint(equalToConstant: 4) // 인디케이터 높이 8픽셀
                // width는 distribution = .fillEqually에 의해 자동으로 분배됩니다.
            ])
        }
    }
    
    // 현재 질문 인덱스에 따라 인디케이터의 색상을 업데이트합니다.
    func updateIndicator(for index: Int) {
        for (i, indicator) in indicatorViews.enumerated() {
            if i <= index {
                indicator.backgroundColor = indicatorColor // 완료된 인디케이터 (73C2FF)
            } else {
                indicator.backgroundColor = .white.withAlphaComponent(0.1) // 미완료된 인디케이터 (0.1 오퍼시티 흰색)
            }
        }
    }
}

// Hex 색상 사용을 위한 UIColor 확장 (이미 있다면 생략 가능)
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
