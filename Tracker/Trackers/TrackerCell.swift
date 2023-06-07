//
//  TrackerCell.swift
//  Tracker
//
//  Created by Kirill on 30.03.2023.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapCompleteButton(of cell: TrackerCell, with tracker: Tracker)
}

final class TrackerCell: UICollectionViewCell {
    // MARK: - Layout elements
    var identifier = ""
    let billetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()
    
    let cardView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.borderColor = UIColor(red: 174 / 255, green: 175 / 255, blue: 180 / 255, alpha: 0.3).cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private let iconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        view.tag = 1
        return view
    }()

    private let pinImageView: UIImageView = {
        let pinImageView = UIImageView()
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        let pinImage = UIImage(systemName: "pin.fill")
        pinImageView.image = pinImage
        pinImageView.tintColor = .white
        return pinImageView
    }()
    
    private let emoji: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        return label
    }()
    
    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    static let identifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    var tracker: Tracker?
    private var days = 0 {
        willSet {
            daysCountLabel.text = "\(newValue.days())"
        }
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContent()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tracker = nil
        days = 0
        completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
        completeButton.layer.opacity = 1
    }
    
    // MARK: - Methods
    
    func configure(with tracker: Tracker, days: Int, isCompleted: Bool) {
        self.tracker = tracker
        self.days = days
        cardView.backgroundColor = tracker.color
        emoji.text = tracker.emoji
        trackerLabel.text = tracker.label
        completeButton.backgroundColor = tracker.color
        pinImageView.isHidden = !tracker.isPinned
        toggleCompletedButton(to: isCompleted)
    }
    
    func toggleCompletedButton(to isCompleted: Bool) {
        if isCompleted {
            completeButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completeButton.layer.opacity = 0.3
        } else {
            completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeButton.layer.opacity = 1
        }
        AnalyticService.shared.sendEvent(event: .click, parameters: ["item": "track"])
    }
    
    func increaseCount() {
        days += 1
    }
    
    func decreaseCount() {
        days -= 1
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapCompleteButton() {
        guard let tracker else { return }
        delegate?.didTapCompleteButton(of: self, with: tracker)
    }
}

// MARK: - Layout methods

private extension TrackerCell {
    func setupContent() {
        contentView.addSubview(billetView)
        billetView.addSubview(cardView)
        billetView.addSubview(iconView)
        billetView.addSubview(emoji)
        billetView.addSubview(trackerLabel)
        billetView.addSubview(pinImageView)
        contentView.addSubview(daysCountLabel)
        contentView.addSubview(completeButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // cardView
            billetView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            billetView.topAnchor.constraint(equalTo: contentView.topAnchor),
            billetView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            billetView.heightAnchor.constraint(equalToConstant: 90),

            pinImageView.trailingAnchor.constraint(equalTo: billetView.trailingAnchor, constant: -12),
            pinImageView.topAnchor.constraint(equalTo: billetView.topAnchor, constant: 18),

            cardView.leadingAnchor.constraint(equalTo: billetView.leadingAnchor),
            cardView.topAnchor.constraint(equalTo: billetView.topAnchor),
            cardView.trailingAnchor.constraint(equalTo: billetView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            // iconView
            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            // emoji
            emoji.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            // trackerLabel
            trackerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            trackerLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            // daysCountLabel
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            daysCountLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -8),
            // completeButton
            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalTo: completeButton.widthAnchor),
        ])
    }
}

extension TrackerCell {
    func getPreviewView() -> UIView {
        guard let previewView = try? billetView.copyObject() as? UIView else { return UIView() }
        if let iconView = previewView.subviews.filter({$0.tag == 1}).first {
            iconView.layer.cornerRadius = 12
        }
        previewView.frame = billetView.bounds
        return previewView
    }
}
