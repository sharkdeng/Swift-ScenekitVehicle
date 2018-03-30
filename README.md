# SceneKitVehicle-Oc-to-Swift

# Important
This is an Apple official example.
translated from objective-oc to swift by Shark by 3 days.
I added a button to introduce how to interacte


# You will learn
## car
### assemble a car 
b) forward
c) backward
d) brake
3) control direction: CoreMotion

## ballSocket joint
to keep every wagon of a train connected all the time 

## static & dynamic
here are some details:
let floor = SCNNode(geometry: SCNFloor())
scene.rootNode.addChildNode(floor)

floor.physicsBody = SCNPhysicsBody.static()

//floor.physicsBody.type = .static() //only this has no effect

//floor.physicsBody? = SCNPhysicsBody.static() //sometimes weird things happen, you may check whether you add "?" It cost me serveral hours.



# Undone works
I left 2 parts untangled:
1) how to control car direction: CoreMotion to 
2) keep car not upside

3) I want to add a control pad like in "Terminator", cos 2 fingers are not always recognized


