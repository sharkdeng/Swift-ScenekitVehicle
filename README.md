# SceneKitVehicle-Oc-to-Swift

# Important
This is an Apple official example.<br>
translated from objective-oc to swift by Shark by 3 days.<br>
I added a button to introduce how to interacte<br>
1) 2 taps with 2 fingers to reset <br>
2) 1 fingers to foward<br>
3) 2 fingers to backward<br>
4) 3 fingers to brake<br>

# You will learn
## car
a) assemble a car <br>
b) forward <br>
c) backward<br>
d) brake<br>
e) control direction: CMMotionManager<br>
f) keep not upside down<br>

## ballSocket joint
to keep every wagon of a train connected all the time 

## static & dynamic
here are some details:<br>
let floor = SCNNode(geometry: SCNFloor())<br>
scene.rootNode.addChildNode(floor)<br>

floor.physicsBody = SCNPhysicsBody.static()<br>

//floor.physicsBody.type = .static() //only this has no effect<br>

//floor.physicsBody? = SCNPhysicsBody.static() //sometimes weird things happen, you may check whether you add "?" It cost me serveral hours.<br>

## SCNMaterial 
## follow camera


# Undone works
I left 2 parts untangled:<br>
1) how to control car direction: CoreMotion to <br>
2) keep car not upside<br>

3) I want to add a control pad like in "Terminator", cos 2 fingers are not always recognized<br>


If you have any problems, welcome to post issue.

# Runtime
xcode 9.0 
ios 11.0
swift 4.0
Copyright (C) 2014 Apple Inc. All rights reserved.

