//
//  TrackersCellPreviewViewController.swift
//  Tracker
//
//  Created by Kirill on 03.06.2023.
//

import UIKit

final class TrackersCellPreviewViewController: UIViewController {
    private let previewView: UIView

    init(previewView: UIView) {
        self.previewView = previewView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(previewView)
        preferredContentSize = previewView.frame.size
    }
}
