//
//  MainView.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/25.
//

import SwiftUI

struct MainView: View {
    let stepViewModel: StepViewModel
    var body: some View {
        HStack {
            StepView(stepViewModel: stepViewModel)
                .frame(maxWidth: 500, alignment: .center)
            Divider()
            Spacer()
            RepoView(repoViewModel: RepoViewModel())
                .foregroundColor(.white)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(stepViewModel: StepViewModel())
    }
}
