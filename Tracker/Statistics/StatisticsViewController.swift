//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Kirill on 30.03.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Статистика"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()

    private let emptyDataView: UIView = {
        let emptyDataView = UIView()
        emptyDataView.translatesAutoresizingMaskIntoConstraints = false
//        emptyDataView.text = "Нет данных"
//        emptyDataView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return emptyDataView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupContent()

        loadData()
    }

    private func setupContent() {
        view.addSubview(titleLabel)
        view.addSubview(emptyDataView)

        NSLayoutConstraint.activate([
        titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),

        emptyDataView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        emptyDataView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        emptyDataView.widthAnchor.constraint(equalTo: view.widthAnchor),
        emptyDataView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func loadData() {

    }

}

