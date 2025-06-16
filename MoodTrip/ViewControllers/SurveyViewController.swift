import UIKit

class SurveyViewController: UIViewController {
    var currentQuestionIndex = 0
    var scores: [String: Int] = [:]
    var questions: [(key: String, question: String, options: [(String, Int)])] = []
    
    // ⭐️ 추가: SurveyIndicatorView 인스턴스
    private var surveyIndicatorView: SurveyIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupQuestions()
        
        // ⭐️ 추가: 인디케이터 뷰 설정 및 추가
        setupSurveyIndicator()
        
        showCurrentQuestion()
        
        // 네비게이션 바 틴트 컬러를 흰색으로 설정
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func setupQuestions() {
        questions = [
            (key: "calm", question: "How do you feel now?", options: [("😊 Happy", 90), ("😐 Okay", 60), ("😠 Angry", 30)]),
            (key: "family", question: "Who are you traveling with?", options: [("👤 Alone", 50), ("👪 Family", 90), ("🧑‍🤝‍🧑 Friends", 70)]),
            (key: "nature", question: "What kind of place do you want?", options: [("🏙 City", 40), ("🌳 Nature", 80), ("🏖 Beach", 90)])
        ]
    }
    
    // ⭐️ 추가: SurveyIndicatorView를 설정하는 메서드
    private func setupSurveyIndicator() {
        surveyIndicatorView = SurveyIndicatorView(numberOfQuestions: questions.count)
        surveyIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(surveyIndicatorView)
        
        NSLayoutConstraint.activate([
            surveyIndicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), // 상단 safe area에서 10포인트 아래
            surveyIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            surveyIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            surveyIndicatorView.heightAnchor.constraint(equalToConstant: 8) // 인디케이터 뷰의 높이 (실제 인디케이터 높이와 같게)
        ])
    }
    
    func showCurrentQuestion() {
        view.subviews.forEach {
            // ⭐️ 수정: surveyIndicatorView는 제거하지 않도록 필터링
            if $0 != surveyIndicatorView {
                $0.removeFromSuperview()
            }
        }
        
        // ⭐️ 추가: 인디케이터 업데이트
        surveyIndicatorView.currentQuestionIndex = currentQuestionIndex
        
        guard currentQuestionIndex < questions.count else {
            goToResult()
            return
        }
        
        let q = questions[currentQuestionIndex]
        let questionView = SurveyQuestionView(question: q.question, options: q.options)
        questionView.onSelect = { score in
            print("🎯 선택된 점수: \(score) for key \(q.key)")
            self.scores[q.key] = score
            self.currentQuestionIndex += 1
            self.showCurrentQuestion()
        }
        
        questionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionView)
        NSLayoutConstraint.activate([
            // ⭐️ 수정: 질문 뷰의 topAnchor를 인디케이터 뷰 아래에 배치
            questionView.topAnchor.constraint(equalTo: surveyIndicatorView.bottomAnchor, constant: 20),
            questionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            questionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            questionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func goToResult() {
        let places = JSONLoader.loadPlaces(from: "places")
        let best = places.max(by: { matchingScore($0) < matchingScore($1) })
        
        let vc = ResultViewController()
        vc.place = best
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func matchingScore(_ place: Place) -> Int {
        var score = 0
        for (key, userScore) in scores {
            let placeScore = place.scores[key] ?? 0
            score += 100 - abs(userScore - placeScore)
        }
        return score
    }
}
