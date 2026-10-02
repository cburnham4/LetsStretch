//
//  SettingsViewController.swift
//  LetsStretch
//

import UIKit

final class SettingsViewController: UIViewController {

    private let card = UIView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let valueLabel = UILabel()
    private let slider = UISlider()
    private let rangeLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = AppTheme.background
        navigationController?.isNavigationBarHidden = false
        buildUI()
        loadCurrentValue()
    }

    private func buildUI() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = AppTheme.surface
        card.layer.cornerRadius = 18
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 10
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.addSubview(card)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Time between stretches"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = AppTheme.ink
        card.addSubview(titleLabel)

        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.text = "Countdown before each stretch starts so you can get into position."
        detailLabel.font = .systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = AppTheme.inkSecondary
        detailLabel.numberOfLines = 0
        card.addSubview(detailLabel)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 36, weight: .bold)
        valueLabel.textColor = AppTheme.accent
        valueLabel.textAlignment = .center
        card.addSubview(valueLabel)

        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = Float(AppSettings.minRestSeconds)
        slider.maximumValue = Float(AppSettings.maxRestSeconds)
        slider.isContinuous = true
        slider.tintColor = AppTheme.accent
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderEnded(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        card.addSubview(slider)

        rangeLabel.translatesAutoresizingMaskIntoConstraints = false
        rangeLabel.text = "\(AppSettings.minRestSeconds)–\(AppSettings.maxRestSeconds) seconds"
        rangeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        rangeLabel.textColor = AppTheme.inkSecondary
        rangeLabel.textAlignment = .center
        card.addSubview(rangeLabel)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),

            detailLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            valueLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 20),

            slider.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            slider.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 12),

            rangeLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            rangeLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            rangeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 10),
            rangeLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
    }

    private func loadCurrentValue() {
        let seconds = AppSettings.restSecondsBetweenStretches
        slider.value = Float(seconds)
        updateValueLabel(seconds)
    }

    private func updateValueLabel(_ seconds: Int) {
        valueLabel.text = seconds == 1 ? "1 second" : "\(seconds) seconds"
    }

    @objc private func sliderChanged(_ sender: UISlider) {
        let seconds = Int(sender.value.rounded())
        sender.value = Float(seconds)
        updateValueLabel(seconds)
    }

    @objc private func sliderEnded(_ sender: UISlider) {
        let seconds = Int(sender.value.rounded())
        AppSettings.restSecondsBetweenStretches = seconds
        updateValueLabel(seconds)
    }
}
