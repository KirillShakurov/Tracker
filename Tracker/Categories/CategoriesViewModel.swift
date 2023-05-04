//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Kirill on 02.05.2023.
//

import UIKit

protocol CategoriesViewModelDelegate: AnyObject {
    func didUpdateCategories()
    func didSelectCategory(_ category: TrackerCategory)
}

final class CategoriesViewModel: NSObject {
    
    // MARK: - Public properties
    weak var delegate: CategoriesViewModelDelegate?

    let view: CategoriesViewController

    // MARK: - Private properties
    private let trackerCategoryStore = TrackerCategoryStore()

    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            delegate?.didUpdateCategories()
        }
    }

    private(set) var selectedCategory: TrackerCategory? = nil {
        didSet {
            guard let selectedCategory else { return }
            delegate?.didSelectCategory(selectedCategory)
        }
    }

    // MARK: - Lifecycle
    init(selectedCategory: TrackerCategory?, view: CategoriesViewController) {
        self.selectedCategory = selectedCategory
        self.view = view
        super.init()
        trackerCategoryStore.delegate = self
    }

    func didLoadView() {
        delegate = view
        loadCategories()
    }
    
    // MARK: - Public
    
    func loadCategories() {
        categories = getCategoriesFromStore()
    }
    
    func selectCategory(at indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
    }
    
    func handleCategoryFormConfirm(data: TrackerCategory.Data) {
        if categories.contains(where: { $0.id == data.id }) {
            updateCategory(with: data)
        } else {
            addCategory(with: data.label)
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) {

        try? trackerCategoryStore.deleteCategory(category)
        loadCategories()
        if category == selectedCategory {
            selectedCategory = nil
        }
    }

    // MARK: - Private

    private func getCategoriesFromStore() -> [TrackerCategory] {
        do {
            let categories = try trackerCategoryStore.categoriesCoreData.map {
                try trackerCategoryStore.makeCategory(from: $0)
            }
            return categories
        } catch {
            return []
        }
    }

    private func addCategory(with label: String) {
        do {
            try trackerCategoryStore.makeCategory(with: label)
            loadCategories()
        } catch {}
    }

    private func updateCategory(with data: TrackerCategory.Data) {
        do {
            try trackerCategoryStore.updateCategory(with: data)
            loadCategories()
        } catch {}
    }

    private func editCategory(_ category: TrackerCategory) {
        let addCategoryViewController = CategoryFormViewController(data: category.data)
        addCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addCategoryViewController)
        view.present(navigationController, animated: true)
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate() {
        categories = getCategoriesFromStore()
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ListItemView.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCategory(at: indexPath)
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let category = categories[indexPath.row]

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

    private func showDeleteAlert(_ category: TrackerCategory) {
        let alert = UIAlertController(
            title: nil,
            message: "Эта категория точно не нужна?",
            preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteCategory(category)
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        view.present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let categoryCell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier) as? CategoryCell else { return UITableViewCell() }
        let category = categories[indexPath.row]
        let isSelected = selectedCategory == category
        var position: ListItemView.Position

        switch indexPath.row {
        case 0:
            position = categories.count == 1 ? .alone : .first
        case categories.count - 1:
            position = .last
        default:
            position = .middle
        }

        categoryCell.configure(with: category.label, isSelected: isSelected, position: position)
        return categoryCell
    }
}

// MARK: - CategoryFormViewControllerDelegate
extension CategoriesViewModel: CategoryFormViewControllerDelegate {
    func didConfirm(_ data: TrackerCategory.Data) {
        handleCategoryFormConfirm(data: data)
        view.dismiss(animated: true)
    }
}

