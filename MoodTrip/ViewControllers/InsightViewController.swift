import UIKit
import DGCharts

class InsightViewController: UIViewController {
    
    private var answers: [String: Int] = [:]
    
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    
    // Chart views for animation
    private var barChart: BarChartView!
    private var pieChart: PieChartView!
    private var lineChart: LineChartView!
    private let customTitleLabel = UILabel()
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewDidLoad()
        setupUI()
        loadAnswers()
        setupScrollView()
        setupChartsAndSummary()
        addBottomGradientOverlay()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateChartsEntrance()
    }
    
    private func setupUI() {
        // Modern gradient background
        view.backgroundColor = UIColor.black
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0).cgColor,
            UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Modern navigation
        // title = "Insights"
        // navigationController?.navigationBar.prefersLargeTitles = true // Disabled large titles
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        // Custom title label
        customTitleLabel.text = "Insights"
        customTitleLabel.textColor = .white
        customTitleLabel.font = .appFont(ofSize: 32, weight: .bold)
        customTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        // Move title label into contentView so it scrolls with content
        contentView.addArrangedSubview(customTitleLabel)
    }
    
    private func loadAnswers() {
        var aggregatedCounts: [String: [Int: Int]] = [:]
        
        let defaults = UserDefaults.standard
        for (key, value) in defaults.dictionaryRepresentation() {
            if key.starts(with: "surveyAnswers"), let answerDict = value as? [String: Any] {
                for (qKey, rawScore) in answerDict {
                    if let score = rawScore as? Int {
                        var scoreMap = aggregatedCounts[qKey, default: [:]]
                        scoreMap[score, default: 0] += 1
                        aggregatedCounts[qKey] = scoreMap
                    } else if let scoreList = rawScore as? [Double] {
                        for s in scoreList {
                            let intScore = Int(s)
                            var scoreMap = aggregatedCounts[qKey, default: [:]]
                            scoreMap[intScore, default: 0] += 1
                            aggregatedCounts[qKey] = scoreMap
                        }
                    }
                }
            }
        }
        
        var latestAnswers: [String: Int] = [:]
        for (qKey, scoreMap) in aggregatedCounts {
            let mostFrequent = scoreMap.max(by: { $0.value < $1.value })?.key ?? 0
            latestAnswers[qKey] = mostFrequent
        }
        self.answers = latestAnswers
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        contentView.axis = .vertical
        contentView.spacing = 32
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -200),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48)
        ])
    }
    
    private func setupChartsAndSummary() {
        // Removed summary card
        
        // Activity chart with modern card container
        barChart = createActivityChart()
        let activityDescription = getActivityDescription()
        let activityCard = createChartCard(title: "✶ Activity Style", chart: barChart, description: activityDescription)
        contentView.addArrangedSubview(activityCard)
        
        // Companion chart
        pieChart = createCompanionChart()
        let companionDescription = getCompanionDescription()
        let companionCard = createChartCard(title: "✶ Companion Type", chart: pieChart, description: companionDescription)
        contentView.addArrangedSubview(companionCard)
        
        // Mood trend chart
        lineChart = createMoodChart()
        let moodDescription = getMoodDescription()
        let moodCard = createChartCard(title: "✶ Mood Trend", chart: lineChart, description: moodDescription)
        contentView.addArrangedSubview(moodCard)
    }
    
    // Removed createSummaryCard (Balanced Explorer component)
    
    private func createChartCard(title: String, chart: ChartViewBase, description: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.03)
        container.layer.cornerRadius = 24
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(white: 1.0, alpha: 0.08).cgColor
        // Add subtle shadow
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.3
        container.layer.shadowOffset = CGSize(width: 0, height: 8)
        container.layer.shadowRadius = 16

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(white: 0.9, alpha: 1.0)
        titleLabel.font = .appFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // New: Percentage and Top Category labels (replace descriptionLabel)
        let percentageLabel = UILabel()
        percentageLabel.textColor = UIColor.white
        percentageLabel.font = .appFont(ofSize: 50, weight: .bold)
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.textAlignment = .left
        percentageLabel.adjustsFontSizeToFitWidth = true

        let topCategoryLabel = UILabel()
        topCategoryLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        topCategoryLabel.font = .appFont(ofSize: 24, weight: .bold)
        topCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        topCategoryLabel.textAlignment = .left
        topCategoryLabel.adjustsFontSizeToFitWidth = true

        // Logic to extract top category and percentage from chart data (for activity and companion)
        if let barChart = chart as? BarChartView, let dataSet = barChart.data?.dataSets.first as? BarChartDataSet, dataSet.entryCount > 0 {
            // Find the max entry
            if let maxEntry = dataSet.entries.max(by: { $0.y < $1.y }),
               let index = dataSet.entries.firstIndex(where: { $0.y == maxEntry.y }),
               let xAxis = barChart.xAxis.valueFormatter as? IndexAxisValueFormatter,
               index < xAxis.values.count
            {
                let total = dataSet.entries.reduce(0.0) { $0 + $1.y }
                let percent = total > 0 ? Int((maxEntry.y / total) * 100) : 0
                percentageLabel.text = "\(percent)%"
                topCategoryLabel.text = xAxis.values[index]
            }
        } else if let pieChart = chart as? PieChartView, let dataSet = pieChart.data?.dataSets.first as? PieChartDataSet, dataSet.entryCount > 0 {
            if let maxEntry = dataSet.entries.max(by: { $0.y < $1.y }),
               let index = dataSet.entries.firstIndex(where: { $0.y == maxEntry.y }),
               index < dataSet.entries.count
            {
                let total = dataSet.entries.reduce(0.0) { $0 + $1.y }
                let percent = total > 0 ? Int((maxEntry.y / total) * 100) : 0
                percentageLabel.text = "\(percent)%"
                topCategoryLabel.text = (maxEntry as? PieChartDataEntry)?.label ?? ""
            }
        } else {
            percentageLabel.text = ""
            topCategoryLabel.text = ""
        }

        chart.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)
        container.addSubview(percentageLabel)
        container.addSubview(topCategoryLabel)
        container.addSubview(chart)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            percentageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            percentageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            percentageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            topCategoryLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor, constant: -8),
            topCategoryLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            topCategoryLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            chart.topAnchor.constraint(equalTo: topCategoryLabel.bottomAnchor, constant: 16),
            chart.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            chart.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chart.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            chart.heightAnchor.constraint(equalToConstant: 240)
        ])

        return container
    }
    
    private func createActivityChart() -> BarChartView {
        let chart = BarChartView()
        chart.backgroundColor = .clear
        chart.noDataText = ""
        chart.legend.enabled = false
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = false
        chart.xAxis.labelRotationAngle = -45
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.pinchZoomEnabled = false

        var barEntries: [BarChartDataEntry] = []
        var barLabels: [String] = []

        if let activityCounts = aggregatedLabelCountsForKey("activity") {
            // Sort by descending value
            let sorted = activityCounts.sorted { $0.value > $1.value }
            for (index, entry) in sorted.enumerated() {
                barEntries.append(BarChartDataEntry(x: Double(index), y: Double(entry.value)))
                barLabels.append(smartTruncateLabel(entry.key))
            }
        }

        let barDataSet = BarChartDataSet(entries: barEntries)
        // Set color opacity progressively (starting from #73C2FF full opacity)
        barDataSet.colors = []
        let baseRed: CGFloat = 0.45
        let baseGreen: CGFloat = 0.76
        let baseBlue: CGFloat = 1.0
        let baseAlpha: CGFloat = 1.0
        let count = max(1, barEntries.count)
        for i in 0..<barEntries.count {
            // Fade opacity for each bar (full opacity for first, then decrease)
            let opacity = max(0.25, baseAlpha - CGFloat(i) * 0.2)
            let color = UIColor(red: baseRed, green: baseGreen, blue: baseBlue, alpha: opacity)
            barDataSet.colors.append(color)
        }
        barDataSet.valueTextColor = UIColor(white: 0.9, alpha: 1.0)
        barDataSet.valueFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        barDataSet.drawValuesEnabled = false
        // Round bar corners if available
        #if canImport(DGCharts)
        if barDataSet.responds(to: Selector(("setBarRoundingCorners:"))) {
            // Just in case, use Objective-C runtime for compatibility
            barDataSet.setValue(15, forKey: "barCornerRadius")
            barDataSet.setValue(15, forKey: "barRoundingCorners") // .allCorners
        }
        #endif

        let barData = BarChartData(dataSet: barDataSet)
        barData.barWidth = 0.6
        chart.data = barData

        // Add x-axis labels below each bar
        chart.xAxis.enabled = true
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelFont = .appFont(ofSize: 12, weight: .bold)
        chart.xAxis.labelTextColor = UIColor(white: 0.9, alpha: 1.0)
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: barLabels)
        chart.xAxis.granularity = 1

        return chart
    }
    
    private func createCompanionChart() -> PieChartView {
        let chart = PieChartView()
        chart.backgroundColor = .clear
        chart.noDataText = ""
        chart.legend.enabled = false
        chart.drawEntryLabelsEnabled = false
        chart.drawHoleEnabled = true
        chart.holeRadiusPercent = 0.4
        chart.transparentCircleRadiusPercent = 0.45
        chart.holeColor = .clear
        chart.rotationEnabled = false
        chart.highlightPerTapEnabled = false

        var pieEntries: [PieChartDataEntry] = []
        if let familyCounts = aggregatedLabelCountsForKey("family") {
            // Sort by descending value
            let sorted = familyCounts.sorted { $0.value > $1.value }
            for (label, count) in sorted {
                pieEntries.append(PieChartDataEntry(value: Double(count), label: smartTruncateLabel(label)))
            }
        }

        let pieDataSet = PieChartDataSet(entries: pieEntries)
        // Custom color per entry, blue with decreasing opacity
        pieDataSet.colors = []
        let baseRed: CGFloat = 0.45
        let baseGreen: CGFloat = 0.76
        let baseBlue: CGFloat = 1.0
        var opacity: CGFloat = 1.0
        for _ in 0..<pieEntries.count {
            pieDataSet.colors.append(UIColor(red: baseRed, green: baseGreen, blue: baseBlue, alpha: opacity))
            opacity = max(0.2, opacity - 0.2)
        }
        pieDataSet.valueTextColor = UIColor(white: 0.9, alpha: 1.0)
        pieDataSet.valueFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        // Enable value drawing and set value formatter/font
        pieDataSet.drawValuesEnabled = true
        pieDataSet.valueFormatter = DefaultValueFormatter(decimals: 0)
        pieDataSet.valueFont = .appFont(ofSize: 12, weight: .bold)
        pieDataSet.sliceSpace = 2

        let pieData = PieChartData(dataSet: pieDataSet)
        chart.data = pieData

        // Enable pie slice labels
        chart.drawEntryLabelsEnabled = true
        chart.entryLabelColor = UIColor(white: 0.9, alpha: 1.0)
        chart.entryLabelFont = .appFont(ofSize: 12, weight: .bold)

        return chart
    }
    
    private func createMoodChart() -> LineChartView {
        let chart = LineChartView()
        chart.backgroundColor = .clear
        chart.noDataText = ""
        chart.legend.enabled = false
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = false
        chart.xAxis.enabled = false
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.pinchZoomEnabled = false
        
        var lineEntries: [ChartDataEntry] = []
        if let calmEntries = UserDefaults.standard.dictionary(forKey: "surveyAnswers")?["calm"] as? [[String: Any]] {
            let recentEntries = calmEntries.suffix(7)
            for (index, entry) in recentEntries.enumerated() {
                if let score = entry["score"] as? Int {
                    lineEntries.append(ChartDataEntry(x: Double(index), y: Double(score)))
                }
            }
        }
        
        let lineDataSet = LineChartDataSet(entries: lineEntries)
        lineDataSet.colors = [UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)]
        lineDataSet.lineWidth = 3
        lineDataSet.circleRadius = 6
        lineDataSet.circleColors = [UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)]
        lineDataSet.circleHoleRadius = 3
        lineDataSet.circleHoleColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        lineDataSet.valueTextColor = UIColor(white: 0.9, alpha: 1.0)
        lineDataSet.valueFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        lineDataSet.drawValuesEnabled = false
        lineDataSet.mode = .cubicBezier
        lineDataSet.cubicIntensity = 0.2
        
        // Add gradient fill
        let gradientColors = [
            UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.0).cgColor,
            UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.3).cgColor
        ]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        lineDataSet.fillAlpha = 1.0
        lineDataSet.fill = LinearGradientFill(gradient: gradient, angle: 90.0)
        lineDataSet.drawFilledEnabled = true

        chart.data = LineChartData(dataSet: lineDataSet)

        // Add average label
        if let lastScore = lineEntries.last?.y {
            let average = lineEntries.map(\.y).reduce(0, +) / Double(lineEntries.count)
            let attributedText = NSMutableAttributedString()

            let numberAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.appFont(ofSize: 50, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(1.0)
            ]
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.appFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]

            let numberString = NSAttributedString(string: "\(Int(average))", attributes: numberAttributes)
            let labelString = NSAttributedString(string: " pts", attributes: labelAttributes)
            attributedText.append(numberString)
            attributedText.append(labelString)

            let avgLabel = UILabel()
            avgLabel.attributedText = attributedText
            avgLabel.translatesAutoresizingMaskIntoConstraints = false
            chart.addSubview(avgLabel)
            NSLayoutConstraint.activate([
                avgLabel.topAnchor.constraint(equalTo: chart.topAnchor, constant: -20),
                avgLabel.leadingAnchor.constraint(equalTo: chart.leadingAnchor, constant: 12)
            ])
        }

        return chart
    }
    
    private func animateChartsEntrance() {
        // Initial state - hidden
        let allViews = [barChart, pieChart, lineChart].compactMap { $0?.superview }
        
        for view in allViews {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 50)
        }
        
        // Animate entrance with staggered timing
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.barChart.superview?.alpha = 1
            self.barChart.superview?.transform = .identity
        } completion: { _ in
            self.barChart.animate(yAxisDuration: 1.2, easingOption: .easeOutCubic)
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.pieChart.superview?.alpha = 1
            self.pieChart.superview?.transform = .identity
        } completion: { _ in
            self.pieChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.2, easingOptionX: .easeOutCubic, easingOptionY: .easeOutCubic)
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.7, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.lineChart.superview?.alpha = 1
            self.lineChart.superview?.transform = .identity
        } completion: { _ in
            self.lineChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.2, easingOptionX: .easeOutCubic, easingOptionY: .easeOutCubic)
        }
    }
    
    private func aggregatedLabelCountsForKey(_ key: String) -> [String: Int]? {
        var result: [String: Int] = [:]
        
        let defaults = UserDefaults.standard
        for (k, value) in defaults.dictionaryRepresentation() {
            if k.starts(with: "surveyAnswers"),
               let answerDict = value as? [String: Any],
               let val = answerDict[key] {
                if let history = val as? [[String: Any]] {
                    for item in history {
                        if let label = item["label"] as? String {
                            result[label, default: 0] += 1
                        }
                    }
                }
            }
        }
        return result.isEmpty ? nil : result
    }

    // MARK: - Description Methods

    private func getActivityDescription() -> String {
        return ""
    }

    private func getCompanionDescription() -> String {
        return ""
    }

    private func getMoodDescription() -> String {
        if let calmEntries = UserDefaults.standard.dictionary(forKey: "surveyAnswers")?["calm"] as? [[String: Any]] {
            let scores = calmEntries.compactMap { $0["score"] as? Int }
            if !scores.isEmpty {
                let average = Double(scores.reduce(0, +)) / Double(scores.count)
                let trend = scores.count > 1 ? (scores.last! > scores.first! ? "상승" : "안정") : "안정"
                return "평균 평온도는 \(String(format: "%.1f", average))점이며, 전반적으로 \(trend) 추세를 보입니다. 꾸준한 자기관리가 돋보입니다."
            }
        }
        return "감정 상태를 꾸준히 기록하며 자신을 돌아보는 시간을 갖고 있습니다."
    }

    private func aggregatedCountsForKey(_ key: String) -> [Int: Int]? {
        var result: [Int: Int] = [:]
        
        let defaults = UserDefaults.standard
        for (k, value) in defaults.dictionaryRepresentation() {
            if k.starts(with: "surveyAnswers"), let answerDict = value as? [String: Any], let val = answerDict[key] {
                if let scoreList = val as? [[String: Any]] {
                    for entry in scoreList {
                        if let score = entry["score"] as? Int {
                            result[score, default: 0] += 1
                        }
                    }
                } else if let score = val as? Int {
                    result[score, default: 0] += 1
                }
            }
        }
        return result.isEmpty ? nil : result
    }
}

private extension InsightViewController {
    func addBottomGradientOverlay() {
        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.bringSubviewToFront(gradientView)

        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 120)
        ])

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(1.0).cgColor,
            UIColor.black.withAlphaComponent(1.0).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120)

        gradientView.layer.addSublayer(gradientLayer)
    }
}

    // MARK: - Helper Methods

    /// Truncate and abbreviate activity/family labels for chart display.
    private func smartTruncateLabel(_ label: String) -> String {
        let abbreviations: [String: String] = [
            "🎨 Arts & Culture": "Culture",
            "🛍 Shopping": "Shop",
            "🍽 Food Tour": "Food",
            "🚶‍♂️ Walking": "Walk",
            "📸 Photo Spot": "Photo",
            "🎢 Adventure": "Adventure"
        ]
        return abbreviations[label] ?? label
    }
