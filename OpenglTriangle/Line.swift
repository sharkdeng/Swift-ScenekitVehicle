//
//  Line.swift
//  stNightGirl
//
//  Created by sj on 2018/5/19.
//  Copyright © 2018 sj. All rights reserved.
//

import Foundation
import GLKit



class Line: GLDrawProtocol {
    
    var shaderProgram: GLProgram
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    
    //method 1: pure array
    var v1: [GLfloat] = [
        -0.5, 0.5, 0,
        0.5, -0.5, 0
    ]
    
    //method 2: position
    struct Point {
        var x: GLfloat
        var y: GLfloat
        var z: GLfloat
    }
    var v2: [Point] = [
        Point(x: -0.5, y: 0.5, z: 0),
        Point(x: 0.5, y: -0.5, z: 0)
    ]
    
    //method 3:  multi attributes
    struct Vertex {
        var position = [GLfloat](repeating: 0, count: 3)
        //var texCoord = [Int](repeating: 0, count: 2)
    }
    var v3: [Vertex] = [
        Vertex(position: [-0.5, 0.5, 0]),
        Vertex(position: [0.5, -0.5, 0])
    ]
    
 

    
    init() {
        shaderProgram = GLProgram(vertexFileName: "line.vsh", fragmentFileName: "line.fsh")
    }
    
    func loadShader() {
        shaderProgram.loadShaders()
    }
    
    func bindVertexData() {
        // 1 vao
  
        glGenVertexArrays(1, &vertexArray)
        glBindVertexArray(vertexArray)
        
        
        // 2 vbo
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        
        //m1
        //let bs1 = v1.count * MemoryLayout<GLfloat>.size
        //glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(bs1), v1, GLenum(GL_STATIC_DRAW))
        
        //m2
        let bs2 = v2.count * MemoryLayout<Point>.size
        glBufferData(GLenum(GL_ARRAY_BUFFER), bs2, v2, GLenum(GL_STATIC_DRAW))
        
        //m3 - no
        //let bs3 = v3.count * MemoryLayout<Vertex>.size
        //glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(bs3), v3, GLenum(GL_STATIC_DRAW))
        
        // 3
        //m1
        //glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 3), UnsafeRawPointer(bitPattern: 0))
        
        //m2
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Point>.size), UnsafeRawPointer(bitPattern: 0))
        
        //m3 - no
        //glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), UnsafeRawPointer(bitPattern: 0))
        
        glEnableVertexAttribArray(0)
        
        glBindVertexArray(0)
        
    
    }
    
    
    func draw() {

        
        glLineWidth(10)
        shaderProgram.use()
        glBindVertexArray(vertexArray)
        glDrawArrays(GLenum(GL_LINES), 0, 2)
        glBindVertexArray(0)
       

        //GL_POINTS
        
        //GL_LINES
        //GL_LINE_LOOP
        //GL_LINE_STRIP
        
        //顶点为3的倍数，剩下的1或2个点不显示
        //GL_TRIANGLES
        //v1, v2, v3 -> v4, v5, v6
        //GL_TRIANGLE_STRIP,
        //2)偶数， T = [n-1, n-2, n]
        //3)奇数， T = [n-2, n-1, n]
        //GL_TRIANGLE_FAN 共享定顶点
        
    }
    
    
}
