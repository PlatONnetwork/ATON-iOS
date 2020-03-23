//
//  WebCommonViewController.swift
//  platonWallet
//
//  Created by Admin on 7/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import WebKit
import Localize_Swift

class WebCommonViewController: BaseViewController {

    lazy var webView = { () -> WKWebView in
        let wk = WKWebView()
        wk.uiDelegate = self
        wk.navigationDelegate = self
        wk.allowsBackForwardNavigationGestures = true
        return wk
    }()

    public var navigationTitle: String?
    public var requestUrl: String?

    override var innerLeftBarButtonItem: UIBarButtonItem? {
        didSet {
            if let customView = innerLeftBarButtonItem?.customView, let backButton = customView.subviews.first(where: { $0 is UIButton }) as? UIButton {
                backButton.removeTarget(self, action: #selector(back), for: .touchUpInside)
                backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIViewController_backround

        super.leftNavigationTitle = Localized("loading")
        if let titleString = navigationTitle {
            super.leftNavigationTitle = titleString
        }

        let barItemMore = UIBarButtonItem(image: UIImage(named: "3.icon_more"), style: .done, target: self, action: #selector(more))
        barItemMore.tintColor = .black

        let barItemRefresh = UIBarButtonItem(image: UIImage(named: "3.icon_refresh"), style: .done, target: self, action: #selector(reload))
        barItemRefresh.tintColor = .black

        let barItemExit = UIBarButtonItem(image: UIImage(named: "3.icon_exit"), style: .done, target: self, action: #selector(close))
        barItemExit.tintColor = .black

        navigationItem.rightBarButtonItems = [barItemMore, barItemRefresh, barItemExit]

        // Do any additional setup after loading the view.
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loadRequest()
    }

    private func loadRequest() {
//        showLoadingHUD()
        guard let urlString = requestUrl else {
            hideLoadingHUD()
            return
        }
        let httpsUrl = (urlString.hasPrefix("https://") || urlString.hasPrefix("http://")) ? urlString : "https://" + urlString

        guard let url = URL(string: httpsUrl) else {
            hideLoadingHUD()
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @objc private func reload() {
        webView.reload()
    }

    @objc private func goBack() {
        if webView.backForwardList.backList.count == 0 {
            close()
            return
        }

        webView.goBack()
    }

    @objc private func close() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func more() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let copylinkAction = UIAlertAction(title: Localized("alert_sheet_copylink_action"), style: .default) { [weak self] _ in
            guard let url = self?.webView.url?.absoluteString else { return }
            let pasteboard = UIPasteboard.general
            pasteboard.string = url
            self?.navigationController?.showMessage(text: Localized("ExportVC_copy_success"))
        }

        let browserAction = UIAlertAction(title: Localized("alert_sheet_browser_action"), style: .default) { [weak self] _ in
            guard let url = self?.webView.url else { return }
            UIApplication.shared.openURL(url)
        }

        let cancelAction = UIAlertAction(title: Localized("alert_sheet_cancel_action"), style: .cancel) { (_) in

        }
        controller.addAction(copylinkAction)
        controller.addAction(browserAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)

    }

}

extension WebCommonViewController: WKUIDelegate {

}

extension WebCommonViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoadingHUD()
        guard navigationTitle == nil else {
            return
        }
        titleLabel?.localizedText = webView.title
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideLoadingHUD()
    }
}
