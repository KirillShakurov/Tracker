//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Kirill on 02.05.2023.
//

protocol CategoriesViewModelDelegate: AnyObject {
    func didUpdateCategories()
    func didSelectCategory(_ category: TrackerCategory)
    func dismiss()
}

final class CategoriesViewModel {
    
    // MARK: - Public properties
    weak var delegate: CategoriesViewModelDelegate?

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
        loadCategories()
    }
    
    func loadCategories() {
        categories = getCategoriesFromStore()
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
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

    func getCategory(for index: Int) -> TrackerCategory {
        categories[index]
    }

    func getPosition(for index: Int) -> ListItemView.Position {
        var position: ListItemView.Position
        switch index {
        case 0:
            position = categories.count == 1 ? .alone : .first
        case categories.count - 1:
            position = .last
        default:
            position = .middle
        }
        return position
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
        delegate?.dismiss()
    }
}


