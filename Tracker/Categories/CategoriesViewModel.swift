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

final class CategoriesViewModel {
    
    // MARK: - Public properties
    weak var delegate: CategoriesViewModelDelegate?

    weak var view: CategoriesViewController?

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
    init(selectedCategory: TrackerCategory?) {
        self.selectedCategory = selectedCategory
        trackerCategoryStore.delegate = self
    }
    
    // MARK: - Public

    func didLoadView() {
        delegate = view
        loadCategories()
    }
    
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

    func configureCell(tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        guard let categoryCell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier) as? CategoryCell else { return UITableViewCell() }
        let category = categories[indexPath.row]
        categoryCell.configure(with: category.label,
                               isSelected: selectedCategory == category,
                               position: getPosition(indexPath: indexPath))
        return categoryCell
    }

    // MARK: - Private

    private func getPosition(indexPath: IndexPath) -> ListItemView.Position {
        var position: ListItemView.Position
        switch indexPath.row {
        case 0:
            position = categories.count == 1 ? .alone : .first
        case categories.count - 1:
            position = .last
        default:
            position = .middle
        }
        return position
    }

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
        try? trackerCategoryStore.makeCategory(with: label)
        loadCategories()
    }

    private func updateCategory(with data: TrackerCategory.Data) {
        try? trackerCategoryStore.updateCategory(with: data)
        loadCategories()
    }

}

// MARK: - TrackerCategoryStoreDelegate

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate() {
        categories = getCategoriesFromStore()
    }
}

// MARK: - CategoryFormViewControllerDelegate
extension CategoriesViewModel: CategoryFormViewControllerDelegate {
    func didConfirm(_ data: TrackerCategory.Data) {
        handleCategoryFormConfirm(data: data)
        view?.dismiss(animated: true)
    }
}


