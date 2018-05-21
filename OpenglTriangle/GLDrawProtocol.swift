//
//  GLDrawProtocol.swift
//  stNightGirl
//
//  Created by sj on 06/05/2018.
//  Copyright © 2018 sj. All rights reserved.
//

import Foundation


protocol GLDrawProtocol {
    var shaderProgram: GLProgram { get set }
    
    func loadShader()
    func bindVertexData()
    func draw()
}
