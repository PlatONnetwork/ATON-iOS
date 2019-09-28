//
//  AppDelegate+MonkeyTest.swift
//  platonWallet
//
//  Created by Admin on 16/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import SwiftMonkeyPaws

var paws: MonkeyPaws?
var window: UIWindow?

extension AppDelegate {
    func setupMonkeyTest() {
        #if DEBUG
        if CommandLine.arguments.contains("--MonkeyPaws") {
            paws = MonkeyPaws(view: window!)
        }
        #endif
    }
}
