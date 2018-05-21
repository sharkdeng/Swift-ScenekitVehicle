//
//  Rectangle.swift
//  stNightGirl
//
//  Created by sj on 06/05/2018.
//  Copyright © 2018 sj. All rights reserved.
//

import Foundation
import GLKit

class Triangle: GLDrawProtocol {
    var shaderProgram: GLProgram

    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    var vertices: [GLfloat] = [ //accept GLFloat & Float
        0.5, -0.5, 0,
        0.5, 0.5, 0,
        -0.5, 0.5, 0,
        -0.5, -0.5, 0 ]
    var indices: [GLuint] = [ //must be GLuint, Int no
        0, 1, 2,
        0, 2, 3 ]
    
    
    
    
    init() {
        shaderProgram = GLProgram(vertexFileName: "tri.vsh", fragmentFileName: "tri.fsh")
    }
    
    
    func loadShader() {
        shaderProgram.loadShaders()
    }
    
    
    func bindVertexData() {
        //产生vao,顶点数组对象，每个顶点有坐标/法线/颜色/纹理坐标信息
        //@param: 1st 数量，2nd 编号数组
        /*
        //多个vao
        var uu: [GLuint] = [GLuint](repeating: 0, count:19)
        glGenVertexArrays(19, &uu)
         
        //单个vao
        var pp: GLuint = 0
        glGenVertexArrays(1, &pp)
        */
        
        // 1 vao
        glGenVertexArrays(1, &vertexArray)
        glBindVertexArray(vertexArray)
        
        // 2 vbo
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        let verticesBufferSize = vertices.count * MemoryLayout<GLfloat>.size
        glBufferData(GLenum(GL_ARRAY_BUFFER), verticesBufferSize, vertices, GLenum(GL_STATIC_DRAW)) //static，数据不变；dynamic，变；stream，每帧变
        
        // 3 veo
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer) //designate buffer type
        let indexBufferSize = indices.count * MemoryLayout<GLuint>.size
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBufferSize, indices, GLenum(GL_STATIC_DRAW))
        
        // 4 enable position in shader
        let stride = 3 * MemoryLayout<GLfloat>.size
        
        //@param indx: number in shader, see tri.vsh -> layout (location = 0) in position
        //@param size: must be 1, 2, 3, or 4. The initial value is 4.
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(stride), UnsafeRawPointer(bitPattern: 0)) 
        glEnableVertexAttribArray(0)
        
        // 5
        glBindVertexArray(0) //release vao
    
    }
    
    
    func draw() {
        // 1 clear, in parent glkView
        
        // 2 have turn program or uniform will occur error
        shaderProgram.use()
        
        // 3 animate
        let offset: Int32 = shaderProgram.getUniformLocation(name: "positionOffset")
        let pos = generatePosition()
        glUniform3f(offset, pos.x, pos.y, 0)
        
        let customColor = shaderProgram.getUniformLocation(name: "customColor")
        let color = generateColors()
        glUniform4f(customColor, color.red, color.green, color.blue, 1.0)

        // 4
        glBindVertexArray(vertexArray)
        glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: 0)) //according to your index order
        glBindVertexArray(0)

    }
    
}


extension Triangle {
    fileprivate func generateColors() -> (red: GLfloat, green: GLfloat, blue: GLfloat) {
        let t = CFAbsoluteTimeGetCurrent()
        let red = cos(t)/2 + 0.5
        let green = sin(t)/2 + 0.5
        let blue = cos(t)*sin(t)
    
        return (GLfloat(red), GLfloat(green), GLfloat(blue))
    }
    
    fileprivate func generatePosition() -> (x: GLfloat, y: GLfloat) {
        let t = CFAbsoluteTimeGetCurrent()
        let x = cos(t)/2 //圆的参数方程，半径为屏幕一半
        let y = sin(t)/2
        return (GLfloat(x), GLfloat(y))
    }
}






