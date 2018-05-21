import Foundation
import OpenGLES
import GLKit

class GLContext {
    
    enum GLContextError: Error {
        case notSupportES3
    }
    
    var context: EAGLContext?
    
    fileprivate(set) var maxVertexAttrib: Int = 9
    fileprivate(set) var maxTextureUnits: Int = 0
    fileprivate(set) var maxTextureSize: Int = 0
    
    
    
    init() throws {
        context = EAGLContext(api: .openGLES3)
        if context ==  nil {
            throw GLContextError.notSupportES3
        }
        
        checkEnviroment()
    }
    
    
    func activate(){
        EAGLContext.setCurrent(context)
    }
    
    
    func deactivate(){
        if EAGLContext.current() == context {
            EAGLContext.setCurrent(nil)
        }
    }
    
    
    func checkEnviroment(){
        //指针是GLint, 编号是GLuint
        //unsafeMutablePointer 是可变指针，类似于inout，所以要&
        //unsafePointer不可变，所以不要&
        var n: GLint = 0
        
        //attribute 修饰的变量数目有限，比如最大0个，glGetIntegerv查询
        glGetIntegerv(GLenum(GL_MAX_VERTEX_ATTRIBS), &n)
        self.maxVertexAttrib = Int(n)
        
        glGetIntegerv(GLenum(GL_MAX_TEXTURE_UNITS), &n)
        self.maxTextureUnits = Int(n)
        
        glGetIntegerv(GLenum(GL_MAX_TEXTURE_SIZE), &n)
        self.maxTextureSize = Int(n)
        
        outputEnviroment()
    }
    
    
    func outputEnviroment(){
        var description = ""
        
        description += "\n"
        description += "\n-Max VertexAttrib: \(self.maxVertexAttrib)"
        description += "\n-Max TextureUnits: \(self.maxTextureUnits)"
        description += "\n-Max TextureSize: \(self.maxTextureSize)"
        
        print(description)
    }
}
