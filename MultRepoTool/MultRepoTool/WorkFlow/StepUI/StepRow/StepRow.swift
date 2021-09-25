//
//  StepRow.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/25.
//

import SwiftUI
import Combine

struct StepRow: View {
    let stepRowModel: StepRowModel
    var body: some View {
        HStack {
            StepNumberView(stepModel: stepRowModel.stepNumberViewModel)
            Text("\(stepRowModel.title)")
                .font(.largeTitle)
            if stepRowModel.stepInputType.contains(.textfield) {
                TextField(stepRowModel.textFiledPlaceholder, text: stepRowModel.$textfieldOutput)
                    .foregroundColor(.white)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 100, alignment: .center)
            }
            Button(stepRowModel.buttonTitle) {
                print("输入框内容: \(stepRowModel.textfieldOutput)")
            }
            Spacer()
        }
    }
}

enum StepInputType {
    case textfield
    case button
}

struct StepRowModel: Identifiable {
    var id: Int {
        return stepNumberViewModel.index
    }
    
    @State var textfieldOutput = ""
    var textFiledPlaceholder = ""
    let stepNumberViewModel: StepNumberViewModel
    let title: String
    let stepInputType: [StepInputType]
    let buttonTitle: String
}

struct StepRow_Previews: PreviewProvider {
    static var previews: some View {
        StepRow(stepRowModel:
                    StepRowModel(textFiledPlaceholder: "分支名",
                                 stepNumberViewModel: StepNumberViewModel(index: 0),
                                 title: "创建分支名",
                                 stepInputType: [.textfield, .button],
                                 buttonTitle: "下一步"))
    }
}
