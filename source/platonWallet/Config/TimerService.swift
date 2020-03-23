//
//  TimerService.swift
//  platonWallet
//
//  Created by Admin on 19/2/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

class TimerService {

    static let shared = TimerService()

    var enterBackgroundTimeStamp: TimeInterval?

    func startObserver(_ complete: ((Bool) -> Void)?) {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.enterBackgroundTimeStamp = Date().timeIntervalSince1970
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
            let currentTimeStamp = Date().timeIntervalSince1970
            if let lastTimeStamp = self?.enterBackgroundTimeStamp, currentTimeStamp - lastTimeStamp > TimeInterval(180) {
                complete?(true)
            } else {
                complete?(false)
            }
        }
    }
}
