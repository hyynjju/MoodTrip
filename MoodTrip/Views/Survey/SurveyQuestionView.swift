import UIKit

class SurveyQuestionView: UIView {
    var selectedScore: Int?
    var onSelect: ((Int) -> Void)?
    
    private let pointColor = UIColor(hex: "#73C2FF")
    
    init(question: String, options: [(String, Int)]) {
        super.init(frame: .zero)
        setupUI(question: question, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(question: String, options: [(String, Int)]) {
        // 질문 라벨
        let label = UILabel()
        label.text = question
        label.textColor = .white
        label.font = .happyFont(ofSize: 24)
        label.textAlignment = .left // ✅ 왼쪽 정렬
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        var previous: UIView? = label
        
        for (title, score) in options {
            let button = GradientButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .appFont(ofSize: 17)
            button.contentHorizontalAlignment = .left // ✅ 텍스트 왼쪽 정렬
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) // ✅ 왼쪽 패딩
            button.layer.cornerRadius = 12
            button.clipsToBounds = true
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
            button.layer.borderWidth = 2 // ✅ 항상 2픽셀
            button.backgroundColor = .clear
            button.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(button)
            
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                button.heightAnchor.constraint(equalToConstant: 52),
                button.topAnchor.constraint(equalTo: previous!.bottomAnchor, constant: 20)
            ])
            
            // 터치 이벤트
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
            
            // 선택 시
            button.addAction(UIAction(handler: { _ in
                print("✅ 버튼 눌림: \(title)")
                self.selectedScore = score
                self.onSelect?(score)
            }), for: .touchUpInside)
            
            previous = button
        }
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        sender.backgroundColor = pointColor.withAlphaComponent(0.2)
        sender.layer.borderColor = pointColor.cgColor
        sender.layer.borderWidth = 2
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        sender.backgroundColor = .clear
        sender.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        sender.layer.borderWidth = 2 // ✅ 유지
    }
}
