//
//  RectangleViewController.swift
//  stNightGirl
//
//  Created by sj on 05/05/2018.
//  Copyright © 2018 sj. All rights reserved.
//

import UIKit
import GLKit

class TriangleViewController: GLBaseViewController {

    var triangle: Triangle!
    var line: Line!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        triangle = Triangle()
        triangle.loadShader()
        triangle.bindVertexData()
    
        line = Line()
        line.loadShader()
        line.bindVertexData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.5, 0.8, 0.9, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        
        //opengl draw order is like stack
        //first triangle, then line
        //so line is infront of triangle
        
        line.draw()
        triangle.draw()
        
    }

}
