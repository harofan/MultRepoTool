//
//  RepoView.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/25.
//

import SwiftUI

struct RepoView: View {
    let repoViewModel: RepoViewModel
    var body: some View {
        VStack {
            Text("仓库区")
            List(repoViewModel.repoRowModels) { repoRowModle in
                RepoRow(repoModel: repoRowModle)
            }
        }
    }
}

struct RepoViewModel {
    let repoRowModels: [RepoRowModel] = {
        return [
            RepoRowModel(repoName: "PodA"),
            RepoRowModel(repoName: "PodB", repoStatus: .edited),
        ]
    }()
}

struct RepoView_Previews: PreviewProvider {
    static var previews: some View {
        RepoView(repoViewModel: RepoViewModel())
    }
}
