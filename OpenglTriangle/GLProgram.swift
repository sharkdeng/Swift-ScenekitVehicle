//
//  GLProgram.swift
//  stNightGirl
//
//  Created by sj on 05/05/2018.
//  Copyright © 2018 sj. All rights reserved.
//

import Foundation
import OpenGLES

enum GLNote: String {
    case failed = "[OpenGL Failure]"
}

class GLProgram {
    
    //着色器文件
    var vertexFile: String
    var fragmentFile: String
    
    var program: GLuint = 0 //起始编号为0
    var vertexShader: GLuint = 0
    var fragmentShader: GLuint = 0
    
    
    
    init(vertexFileName: String, fragmentFileName: String){
        self.vertexFile = vertexFileName
        self.fragmentFile = fragmentFileName
    }
    
    
    deinit {
        glDeleteProgram(program)
    }
    
    
    //MARK: program 4
    func use(){
        if program != 0 {
            glUseProgram(program)
        }
    }
    
    
    func validate() -> Bool {
        glValidateProgram(program)
        
        var status: GLint = 0
        glGetProgramiv(program, GLenum(GL_VALIDATE_STATUS), &status)
        if status == 0 {
            outputProgramError()
            return false
        }
        
        return true
    }
    
    
    fileprivate func linkProgram() -> Bool {
        
        program = glCreateProgram()
        
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        glLinkProgram(program)
        
        var status: GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        if status == 0 {
            outputProgramError()
            glDeleteProgram(program)
            return false
        }
        
        glDetachShader(program, vertexShader)
        glDetachShader(program, fragmentShader)
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        return true
    }
    
    
    fileprivate func outputProgramError(){
        var logLength: GLint = 0
        
        glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0{
            var logChar: [GLchar] = [GLchar](repeating: 0, count: Int(logLength))
            glGetProgramInfoLog(program, GLsizei(logLength), &logLength, &logChar)
            
            let logString = String(cString: logChar, encoding: String.Encoding.utf8)
            print("Error in Program: \(logString)")
        }
    }
    
    func getUniformLocation(name: String) -> Int32 {
        return glGetUniformLocation(program, name.cString(using: .utf8))
    }
    
    //MARK: shader 3
    
    fileprivate func compileShader() -> Bool {
    
        if !compileShader(shader: &vertexShader, type: GLenum(GL_VERTEX_SHADER), fileName: self.vertexFile) {
            
            print(GLNote.failed.rawValue, "compile vertex shader")
            
            return false
        }
        
        if !compileShader(shader: &fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), fileName: fragmentFile){
            
            print(GLNote.failed.rawValue, "compile fragment shader")
            
            return false
        }
        
        return true
        
    }
    
    fileprivate func compileShader(shader: inout GLuint, type: GLenum, fileName: String) -> Bool {
        // 1
        shader = glCreateShader(type)
        if shader == 0 {
            print(GLNote.failed.rawValue, "create shader fail, check context")
        }
        
        // 2
        var source: UnsafePointer<Int8>
        do {
            let url = Bundle.main.url(forResource: fileName, withExtension: nil)
            source = try NSString(contentsOf: url!, encoding: String.Encoding.utf8.rawValue).utf8String!
            var sourceChar: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(source)
            glShaderSource(shader, 1, &sourceChar, nil)
        } catch {
            print(GLNote.failed.rawValue, "read shader src \(fileName)", error)
        }

        // 3
        glCompileShader(shader)
        
        // 4
        var status: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status) //1 success, 0 fail
        if status == 0 {
            outputShaderError(shader: shader, fileName: fileName)
            glDeleteShader(shader)
            return false
        }
    
        return true
    }
    
 
    
    fileprivate func outputShaderError(shader: GLuint, fileName: String){
        
        var logLength: GLint = 0
        glGetShaderiv(shader , GLenum(GL_INFO_LOG_LENGTH), &logLength)

        if logLength > 0 {
            let logChar: UnsafeMutablePointer<GLchar> = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
            logChar.initialize(to: 0)
            
            glGetShaderInfoLog(shader, GLsizei(logLength), &logLength, logChar)
            
            let logString = String(cString: logChar, encoding: String.Encoding.utf8)
            print(GLNote.failed.rawValue, "shader\(fileName), \(String(describing: logString))")
            
            logChar.deinitialize()
            logChar.deallocate(capacity: Int(logLength))
        }
    }
    
    
    @discardableResult
    func loadShaders() -> Bool {
        if !compileShader() {
            return false
        }
        
        if !linkProgram() {
            return false
        }
        
        return true
    }
    
  
    
}
