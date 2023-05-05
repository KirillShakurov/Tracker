//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Kirill on 02.05.2023.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didConfirm(_ category: TrackerCategory)
}

final class CategoriesViewController: UIViewController {
    
    // MARK: - Layout elements
    
    private let categoriesTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        table.separatorStyle = .none
        table.allowsMultipleSelection = false
        table.backgroundColor = .clear
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        return table
    }()

    private let notFoundView = NotFoundView(label: "Привычки и события можно объединить по смыслу")
    private lazy var addButton: UIButton = {
        let button = Button(title: "Добавить категорию")
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        button.layer.cornerRadius = 16
        return button
    }()
    
    // MARK: - Properties
    
    weak var delegate: CategoriesViewControllerDelegate?
    private let viewModel: CategoriesViewModel

    // MARK: - Lifecycle

    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContent()
        setupConstraints()
        viewModel.didLoadView()
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapAddButton() {
        let addCategoryViewController = CategoryFormViewController()
        addCategoryViewController.delegate = viewModel
        let navigationController = UINavigationController(rootViewController: addCategoryViewController)
        present(navigationController, animated: true)
    }
}

// MARK: - Layout methods

private extension CategoriesViewController {
    func setupContent() {
        title = "Категория"
        view.backgroundColor = .white
        view.addSubview(categoriesTableView)
        view.addSubview(addButton)
        view.addSubview(notFoundView)
        
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // categoriesTableView
            categoriesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            // addButton
            addButton.leadingAnchor.constraint(equalTo: categoriesTableView.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: categoriesTableView.trailingAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            // notFoundView
            notFoundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            notFoundView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            notFoundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }

    private func editCategory(_ category: TrackerCategory) {
        let addCategoryViewController = CategoryFormViewController(data: category.data)
        addCategoryViewController.delegate = viewModel
        let navigationController = UINavigationController(rootViewController: addCategoryViewController)
        present(navigationController, animated: true)
    }


    private func showDeleteAlert(_ category: TrackerCategory) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(category)
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}

// MARK: - CategoriesViewModelDelegate

extension CategoriesViewController: CategoriesViewModelDelegate {
    func didUpdateCategories() {
        notFoundView.isHidden =  !viewModel.categories.isEmpty
        categoriesTableView.reloadData()
    }
    
    func didSelectCategory(_ category: TrackerCategory) {
        delegate?.didConfirm(category)
    }
}


// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel.configureCell(tableView: tableView, indexPath)
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ListItemView.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath)
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let category = viewModel.categories[indexPath.row]

        return UIContextMenuConfiguration(actionProvider:  { _ in
            UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.editCategory(category)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    self?.showDeleteAlert(category)
                }
            ])
        })
    }

}



