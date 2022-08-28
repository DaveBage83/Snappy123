//
//  SharkCardScanViewController.swift
//  SharkCardScan
//
//  Created by Gymshark on 02/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import UIKit
//import Foundation
import Combine

// this has all been imported from https://github.com/gymshark/ios-card-scan and fixed
public class SharkCardScanViewController: UIViewController {

    private var viewModel: CardScanViewModel
    private var styling: CardScanStyling
    
    private lazy var closeButton = UIButton().with {
        $0.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        $0.tintColor = .white
        $0.accessibilityLabel = String(describing: SharkCardScanViewController.self) + "." + "CloseButton"
    }
    
    private let rootStackView = UIStackView().with { $0.axis = .vertical }
    private let cameraAreaView = UIView().withAspectRatio(3 / 4, priority: .defaultHigh)
    private let overlayView = LayerContentView(contentLayer: CAShapeLayer()).with {
        $0.contentLayer.fillRule = .evenOdd
    }
    private lazy var cardView = ScannedCardView(styling: styling)
    private lazy var instructionsLabel = UILabel().withFixed(width: 288).with {
        $0.text = viewModel.insturctionText
        $0.font = styling.instructionLabelStyling.font
        $0.textColor = styling.instructionLabelStyling.color
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    public init(viewModel: CardScanViewModel, styling: CardScanStyling = DefaultStyling()) {
        self.viewModel = viewModel
        self.styling = styling
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        setupNoPermissionsAlert()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        closeButton.touchUpInside.action = viewModel.didTapClose
        viewModel.didDismiss = weakClosure(self) { (self) in
            self.dismiss(animated: true, completion: nil)
        }
        
        viewModel.update = weakClosure(self) { (self, state) in
            UIView.animate(withDuration: 0.2) {
                self.overlayView.contentLayer.fillColor = UIColor.black.withAlphaComponent(state.overlayMaskAlpha).cgColor
                self.cardView.backgroundColor = UIColor.black.withAlphaComponent(state.cuttoutBackgroundAlpha)
            }
            self.cardView.numberLabel.text = state.response?.number
            self.cardView.expiryLabel.text = state.response?.expiry
            self.cardView.holderLabel.text = state.response?.holder
        }
        
        view.withEdgePinnedContent {[
            rootStackView.withArrangedViews {[
                cameraAreaView.withEdgePinnedContent {[
                    viewModel.previewView,
                    overlayView.withVerticallyCenteredContent(safeArea: true, horizontalEdgePin: 20) {[
                        cardView
                    ]},
                    UIView().withEdgePinnedContent(.topRight(16, others: nil), safeArea: true) {[
                        closeButton
                    ]}
                ]},
                UIView().with { $0.backgroundColor = .white }.withCenteredContent {[
                    instructionsLabel
                ]}
            ]}
        ]}
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Give time for everthing to layout. Will maybe come back to but it will work fine
        DispatchQueue.main.async {
            let path = UIBezierPath(rect: self.overlayView.bounds)
            path.append(
                UIBezierPath(
                    roundedRect: self.overlayView.convert(self.cardView.bounds, from: self.cardView),
                    cornerRadius: self.cardView.layer.cornerRadius
                )
            )
            self.overlayView.contentLayer.path = path.cgPath
            
            self.viewModel.cardCuttoutInPreview(frame: self.viewModel.previewView.convert(self.cardView.bounds, from: self.cardView))
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startCamera()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopCamera()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func setupNoPermissionsAlert() {
        viewModel.$showPermissionAlert
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                guard let self = self else { return }
                if show { self.showNoPermissionAlert() }
            }
            .store(in: &cancellables)
    }
    
    func showNoPermissionAlert() {
        showAlert(style: .alert, title: Strings.Alerts.CameraPermission.title.localized, message: Strings.Alerts.CameraPermission.message.localized, actions: [UIAlertAction(title: Strings.General.ok.localized, style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            self.viewModel.showPermissionAlert = false
        })])
    }
    
    func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.view.tintColor = UIColor.black
        actions.forEach {
            alertController.addAction($0)
        }
        if style == .actionSheet && actions.contains(where: { $0.style == .cancel }) == false {
            alertController.addAction(UIAlertAction(title: Strings.General.close.localized, style: .cancel, handler: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.showPermissionAlert = false
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
