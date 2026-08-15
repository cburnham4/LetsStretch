//
//  RoutineCell.swift
//  LetsStretch
//
//  Created by Carl Burnham on 8/5/17.
//  Copyright © 2017 Carl Burnham. All rights reserved.
//

import UIKit
import Kingfisher

class RoutineCell: UITableViewCell {

    @IBOutlet weak var routineImage: UIImageView!
    @IBOutlet weak var routineNameLabel: UILabel!

    private let cardView = UIView()
    private let chevronView = UIImageView()
    private var didSetupChrome = false

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupChromeIfNeeded()
        styleContent()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        routineImage.kf.cancelDownloadTask()
        routineImage.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupChromeIfNeeded()

        let inset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        cardView.frame = contentView.bounds.inset(by: inset)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let alpha: CGFloat = highlighted ? 0.92 : 1
        UIView.animate(withDuration: 0.15) {
            self.cardView.alpha = alpha
            self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.985, y: 0.985) : .identity
        }
    }

    func configure(with routine: Routine) {
        setupChromeIfNeeded()
        styleContent()
        routineNameLabel.text = routine.name
        routineImage.backgroundColor = AppTheme.accentSoft

        // Prefer bundled icon as a fast placeholder; final art comes from content downloadURL.
        let placeholder: UIImage? = {
            if let icon = AppTheme.routineIconName(for: routine.name),
               let image = UIImage(named: icon) {
                return image
            }
            return UIImage(named: "standing_yoga_stretch")
        }()

        if let url = URL(string: routine.imageURL), !routine.imageURL.isEmpty {
            routineImage.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [.transition(.fade(0.2))]
            )
        } else {
            routineImage.image = placeholder
        }
    }

    private func setupChromeIfNeeded() {
        guard !didSetupChrome else { return }
        didSetupChrome = true

        cardView.backgroundColor = AppTheme.surface
        cardView.layer.cornerRadius = 18
        cardView.layer.cornerCurve = .continuous
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.insertSubview(cardView, at: 0)

        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.tintColor = AppTheme.inkSecondary.withAlphaComponent(0.55)
        chevronView.contentMode = .scaleAspectFit
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(chevronView)

        NSLayoutConstraint.activate([
            chevronView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            chevronView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12),
            chevronView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    private func styleContent() {
        routineNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        routineNameLabel.textColor = AppTheme.ink

        routineImage.contentMode = .scaleAspectFill
        routineImage.clipsToBounds = true
        routineImage.layer.cornerRadius = 24
        routineImage.layer.borderWidth = 0
        routineImage.backgroundColor = AppTheme.accentSoft
    }
}
