import UIKit

class SurveyViewController: UIViewController {
    var currentQuestionIndex = 0
    var scores: [String: Int] = [:]
    var questions: [(key: String, question: String, options: [(String, Int)])] = []

    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black
            setupQuestions()
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

    func showCurrentQuestion() {
        view.subviews.forEach { $0.removeFromSuperview() }

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
            questionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            questionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            questionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            questionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
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
