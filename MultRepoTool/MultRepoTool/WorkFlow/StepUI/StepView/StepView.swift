//
//  StepView.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/25.
//

import SwiftUI

struct StepView: View {
    let stepViewModel: StepViewModel
    var body: some View {
        VStack {
            Text("工作区")
            List(stepViewModel.stepRowModels) { stepRowModel in
                StepRow(stepRowModel: stepRowModel)
            }
        }
    }
        
}

struct StepViewModel {
    let stepRowModels: [StepRowModel] = {
        return [
            StepRowModel(textFiledPlaceholder: "分支名",
                         stepNumberViewModel: StepNumberViewModel(index: 0),
                         title: "创建分支名",
                         stepInputType: [.textfield, .button],
                         buttonTitle: "下一步"),
            StepRowModel(stepNumberViewModel: StepNumberViewModel(index: 1),
                         title: "编写代码",
                         stepInputType: [.button],
                         buttonTitle: "下一步"),
            StepRowModel(stepNumberViewModel: StepNumberViewModel(index: 2),
                         title: "提交代码",
                         stepInputType: [.button],
                         buttonTitle: "下一步"),
            StepRowModel(stepNumberViewModel: StepNumberViewModel(index: 3),
                         title: "打二进制",
                         stepInputType: [.button],
                         buttonTitle: "下一步"),
            StepRowModel(stepNumberViewModel: StepNumberViewModel(index: 4),
                         title: "发布",
                         stepInputType: [.button],
                         buttonTitle: "下一步")
        ]
    }()
}

struct StepView_Previews: PreviewProvider {
    static var previews: some View {
        StepView(stepViewModel: StepViewModel())
    }
}
