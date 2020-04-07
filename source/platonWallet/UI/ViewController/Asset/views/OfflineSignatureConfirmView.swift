//
//  OfflineSignatureConfirmView.swift
//  platonWallet
//
//  Created by Admin on 24/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class OfflineSignatureQRCodeView: UIView {

    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(1.0)
        }
    }
}

class OfflineSignatureScanView: UIView {

    let scanButton = UIButton()
    let textView = UITextView()

    var scanCompletion: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        scanButton.setImage(UIImage(named: "textField_icon_scan"), for: .normal)
        scanButton.addTarget(self, action: #selector(scanAction), for: .touchUpInside)
        addSubview(scanButton)
        scanButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.width.equalTo(20)
        }

        textView.layer.borderColor = UIColor(rgb: 0x1861FE).cgColor
        textView.layer.borderWidth = 1
        textView.backgroundColor = UIColor(rgb: 0xFAFDFF)
        textView.textColor = .black
        textView.contentInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isEditable = false
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(scanButton.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview()
            make.height.equalTo(122)
        }
    }

    @objc func scanAction() {
        scanCompletion?()
    }
}

protocol ViewContentProtocol {
    var contentView: UIView { get }
}

enum ConfirmViewType: ViewContentProtocol {
    case qrcodeGenerate(contentView: OfflineSignatureQRCodeView)
    case qrcodeScan(contentView: OfflineSignatureScanView)

    var contentView: UIView {
        get {
            switch self {
            case .qrcodeScan(let contentView):
                return contentView
            case .qrcodeGenerate(let contentView):
                return contentView
            }
        }
    }
}

class OfflineSignatureConfirmView: UIView {

    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let submitBtn = PButton()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "1.icon_shut down"), for: .normal)
        return button
    }()

    var type: ConfirmViewType!
    var onCompletion: (() -> Void)?
    var onDismiss: (() -> Void)?
    var observer: NSKeyValueObservation?

    convenience init(confirmType: ConfirmViewType) {
        self.init(frame: .zero)
        type = confirmType
        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        backgroundColor = .white

        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }

        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
            make.height.width.equalTo(32)
        }

        let lineV = UIView()
        lineV.backgroundColor = common_line_color
        addSubview(lineV)
        lineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }

        descriptionLabel.textColor = common_darkGray_color
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(lineV.snp.bottom).offset(16)
        }

        let contentView = type.contentView
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        submitBtn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        addSubview(submitBtn)
        submitBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.top.equalTo(contentView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }

        submitBtn.style = .blue

        if contentView is OfflineSignatureScanView {
            observer = (contentView as? OfflineSignatureScanView)?.textView.observe(\.text, options: [.new, .initial], changeHandler: { (textView, _) in
                self.submitBtn.style = textView.text.count > 0 ? .blue : .disable
            })
        }
    }

    @objc func submitAction() {
        onCompletion?()
    }

    @objc func closeAction() {
        onDismiss?()
    }
}
