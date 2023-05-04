//
//  CategoriesAssembly.swift
//  Tracker
//
//  Created by Kirill on 04.05.2023.
//

import UIKit

protocol CategoriesAssemblyProtocol {
  func buildModule(selectedCategory: TrackerCategory?) -> CategoriesViewController
}

final class CategoriesAssembly: CategoriesAssemblyProtocol {
  func buildModule(selectedCategory: TrackerCategory?) -> CategoriesViewController {
    let view = CategoriesViewController()
    let viewModel = CategoriesViewModel(selectedCategory: selectedCategory,
                                        view: view)

    view.viewModel = viewModel
    return view
  }
}

