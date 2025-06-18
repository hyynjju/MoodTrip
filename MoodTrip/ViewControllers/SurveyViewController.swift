import UIKit

class SurveyViewController: UIViewController {
    var currentQuestionIndex = 0
    var scores: [String: Int] = [:]
    var questions: [(key: String, question: String, options: [(String, Int)])] = []
    
    // SurveyIndicatorView 인스턴스 추가 (이전 답변에서 누락되었을 수 있어 추가)
    private var surveyIndicatorView: SurveyIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupQuestions()
        setupSurveyIndicator() // 인디케이터 설정 호출
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
            (
                key: "calm",
                question: "How do you feel now?",
                options: [
                    ("😄 Very Happy", 100),
                    ("😊 Happy", 80),
                    ("😐 Okay", 60),
                    ("😕 Slightly Upset", 40),
                    ("😠 Angry", 20)
                ]
            ),
            (
                key: "family",
                question: "Who are you traveling with?",
                options: [
                    ("👤 Alone", 50),
                    ("🧑‍🤝‍🧑 Partner", 70),
                    ("👨‍👩‍👦 Family", 90),
                    ("👫 Friends", 80),
                    ("👥 Group", 60)
                ]
            ),
            (
                key: "nature",
                question: "What kind of place do you want?",
                options: [
                    ("🏙 City", 40),
                    ("🏞 Mountain", 70),
                    ("🌳 Nature", 80),
                    ("🏖 Beach", 90),
                    ("🏕 Countryside", 60)
                ]
            ),
            (
                key: "activity",
                question: "What activity are you in the mood for?",
                options: [
                    ("🎨 Arts & Culture", 60),
                    ("🛍 Shopping", 50),
                    ("🍽 Food Tour", 80),
                    ("🚶‍♂️ Walking", 70),
                    ("📸 Photo Spot", 90),
                    ("🎢 Adventure", 100)
                ]
            ),
            (
                key: "intensity",
                question: "How active should your trip be?",
                options: [
                    ("🛋 Totally relaxing", 10),
                    ("🧘 Gentle walk", 30),
                    ("🚶 Casual stroll", 50),
                    ("🥾 Light hiking", 70),
                    ("🚴 Active exploring", 90),
                    ("🧗 Intense adventure", 100)
                ]
            )
        ]
    }
    
    // SurveyIndicatorView를 초기화하고 뷰에 추가하는 함수
    private func setupSurveyIndicator() {
        surveyIndicatorView = SurveyIndicatorView(numberOfQuestions: questions.count)
        surveyIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(surveyIndicatorView)
        
        NSLayoutConstraint.activate([
            surveyIndicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            surveyIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            surveyIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            surveyIndicatorView.heightAnchor.constraint(equalToConstant: 40) // 인디케이터 뷰의 높이
        ])
    }
    
    func showCurrentQuestion() {
        // 기존 뷰 제거 (인디케이터 뷰는 제거하지 않음)
        view.subviews.forEach {
            if $0 != surveyIndicatorView { // 인디케이터 뷰는 제거하지 않음
                $0.removeFromSuperview()
            }
        }
        
        // 인디케이터 업데이트
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
            // Store selected label and score in UserDefaults as array of dictionaries
            var storedAnswers = UserDefaults.standard.dictionary(forKey: "surveyAnswers") as? [String: Any] ?? [:]
            let selectedLabel = q.options.first(where: { $0.1 == score })?.0 ?? "Unknown"
            var history = storedAnswers[q.key] as? [[String: Any]] ?? []
            history.append(["label": selectedLabel, "score": score])
            storedAnswers[q.key] = history
            UserDefaults.standard.setValue(storedAnswers, forKey: "surveyAnswers")
            self.currentQuestionIndex += 1
            self.showCurrentQuestion()
        }
        
        questionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionView)
        NSLayoutConstraint.activate([
            questionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            questionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            questionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            questionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }
    
    func goToResult() {
        let places = JSONLoader.loadPlaces(from: "places")
        // ⭐️ 수정: SurveyViewController의 scores를 사용하여 매칭 점수 계산
        let best = places.max(by: {
            var score1 = 0
            for (key, userScore) in self.scores {
                let placeScore = $0.scores[key] ?? 0
                score1 += 100 - abs(userScore - placeScore)
            }
            
            var score2 = 0
            for (key, userScore) in self.scores {
                let placeScore = $1.scores[key] ?? 0
                score2 += 100 - abs(userScore - placeScore)
            }
            return score1 < score2
        })
        
        let vc = ResultViewController()
        vc.place = best
        vc.userScores = self.scores // ⭐️ 중요: ResultViewController로 userScores 전달
        vc.fromSurvey = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 이 matchingScore 함수는 ResultViewController의 userScores로 대체되므로, 여기서는 사용되지 않음.
    // 하지만 JSONLoader에서 사용될 수 있으므로 일단 유지.
    func matchingScore(_ place: Place) -> Int {
        var score = 0
        for (key, userScore) in scores {
            let placeScore = place.scores[key] ?? 0
            score += 100 - abs(userScore - placeScore)
        }
        return score
    }
}
