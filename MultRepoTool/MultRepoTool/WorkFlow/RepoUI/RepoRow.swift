//
//  RepoRow.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/25.
//

import SwiftUI

struct RepoRow: View {
    let repoModel: RepoRowModel
    let circleWidth: CGFloat = 10
    var body: some View {
        HStack {
            Text(repoModel.repoName)
                .font(.largeTitle)
                .foregroundColor(.white)
            Circle()
                .frame(width: circleWidth, height: circleWidth, alignment: .center)
                .foregroundColor(repoModel.repoStatus.statusColor())
            Text(repoModel.repoStatus.statusTitle())
        }
    }
}

enum RepoStatus {
    case edited
    case notEdit
    
    func statusColor() -> Color {
        switch self {
        case .edited:
            return .green
        case .notEdit:
            return .white
        }
    }
    
    func statusTitle() -> String {
        switch self {
        case .edited:
            return "有修改需要提交"
        case .notEdit:
            return "无修改不需要提交"
        }
    }
}

struct RepoRowModel: Identifiable {
    var id: String = UUID().uuidString
    let repoName: String
    var repoStatus: RepoStatus = .notEdit
}

struct RepoRow_Previews: PreviewProvider {
    static var previews: some View {
        RepoRow(repoModel: RepoRowModel(repoName: "PodA"))
    }
}
