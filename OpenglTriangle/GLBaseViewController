import UIKit
import GLKit

class GLBaseViewController: GLKViewController {

    var ctx: GLContext!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            ctx = try GLContext()
        } catch GLContext.GLContextError.notSupportES3 {
            print(GLNote.failed.rawValue, "not support OpenglES3")
        } catch {
            print(GLNote.failed.rawValue, "context")
        }
        
        let view = self.view as! GLKView
        view.context = ctx.context!
        ctx.activate()
        
        view.drawableColorFormat = .RGBA8888
        view.drawableDepthFormat = .format24
        view.drawableMultisample = .multisample4X
        
        self.preferredFramesPerSecond = 60
        self.pauseOnWillResignActive = true
        self.resumeOnDidBecomeActive = true
        
        //glEnable should be placed here, in glkView will occur error
        glEnable(GLenum(GL_DEPTH_TEST))
        //GL_DEPTH_TEST: check if there are pixels in front of the current pixel, if exists, then current pixel will not be drew. In other words, opengl always draw the uppermost pixel.
        
        //GL_BLEND: use blend map, you need close GL_DEPTH_TEST, open GL_BLEND, set glColor4f, glBlendFunc
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
