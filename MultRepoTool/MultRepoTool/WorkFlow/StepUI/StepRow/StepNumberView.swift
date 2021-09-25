//
//  StepNumberView.swift
//  MultRepoTool
//
//  Created by harofan on 2021/9/25.
//

import SwiftUI

struct StepNumberView: View {
    let stepModel: StepNumberViewModel
    let width: CGFloat = 80
    var body: some View {
        ZStack {
            Text("\(stepModel.index)")
                .foregroundColor(.black)
                .font(.largeTitle)
                .frame(width: width, height: width, alignment: .center)
                .background(stepModel.stepStatus.setpColor())
                .cornerRadius(width / 2)
                .overlay(Circle().stroke(Color.white))
                .padding()
        }
    }
}

enum StepStatus {
    case finished
    case ongoing
    case notStart
    func setpColor() -> Color {
        switch self {
        case .finished:
            return.green
        case .ongoing:
            return .blue
        case .notStart:
            return .white
        }
    }
}

struct StepNumberViewModel {
    let index: Int
    var stepStatus: StepStatus = .notStart
}

struct StepNumberView_Previews: PreviewProvider {
    static var previews: some View {
        StepNumberView(stepModel: StepNumberViewModel(index: 0))
    }
}
