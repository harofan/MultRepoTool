//
//  ClassB.swift
//  A
//
//  Created by harofan on 2021/9/23.
//

import PodA

public class ClassB {
    public init() {
        
    }
    public func haha() {
        let a = ClassA()
        a.haha()
        print("ClassB")
    }
}
