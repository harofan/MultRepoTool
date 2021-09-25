//
//  MultRepoToolApp.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/25.
//

import SwiftUI

@main
struct MultRepoToolApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(stepViewModel: StepViewModel())
                .frame(minWidth: 2000, minHeight: 1000, alignment: .center)
        }
    }
}
