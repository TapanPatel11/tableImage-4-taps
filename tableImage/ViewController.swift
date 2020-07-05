//
//  ViewController.swift
//  tableImage
//
//  Created by Tapan Patel on 22/06/20.
//  Copyright © 2020 Tapan Patel. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


extension UIPinchGestureRecognizer {
    func scale(view: UIView) -> (x: CGFloat, y: CGFloat)? {
        if numberOfTouches > 1 {
            let touch1 = self.location(ofTouch: 0, in: view)
            let touch2 = self.location(ofTouch: 1, in: view)
            let deltaX = abs(touch1.x - touch2.x)
            let deltaY = abs(touch1.y - touch2.y)
            let sum = deltaX + deltaY
            if sum > 0 {
                let scale = self.scale
                return (1.0 + (scale - 1.0) * (deltaX / sum), 1.0 + (scale - 1.0) * (deltaY / sum))
            }
        }
        return nil
    }
}
extension SCNGeometry {
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
    class func PlaneFrom(startVector vector1: SCNVector3, secondVector vector2: SCNVector3, thirdVector vector3:SCNVector3, endVector vector4:SCNVector3) -> SCNGeometry {
        
        let indices: [Int32] = [4,0,1,2,3]
        
                let textureCoordinates = [
                    CGPoint(x: 0, y: 0),
                    CGPoint(x: 0, y: 1),
                    CGPoint(x: 1, y: 1),
                    CGPoint(x: 1, y: 0)
                ]

        let uvSource = SCNGeometrySource(textureCoordinates: textureCoordinates)

        let vertices: [SCNVector3] = [vector1,vector2,vector3,vector4]
        let vertexSource = SCNGeometrySource(vertices: vertices)
        let indexData = Data(bytes: indices,
                             count: indices.count * MemoryLayout<Int32>.size)
        let element = SCNGeometryElement(data: indexData,
                                         primitiveType: .polygon,
                                         primitiveCount: 1,
                                         bytesPerIndex: MemoryLayout<Int32>.size)
        let geometry = SCNGeometry(sources: [vertexSource, uvSource], elements: [element])
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"overlay_grid1")
        material.isDoubleSided = true
        geometry.materials = [material]
        
        
        return geometry
    }
}

extension SCNVector3 {
    static func distanceFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> Float {
        let x0 = vector1.x
        let x1 = vector2.x
        let y0 = vector1.y
        let y1 = vector2.y
        let z0 = vector1.z
        let z1 = vector2.z
        
        return sqrtf(powf(x1-x0, 2) + powf(y1-y0, 2) + powf(z1-z0, 2))
    }
}

extension Float {
    func metersToInches() -> Float {
        return self * 39.3701
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    
    
   
    
    @IBOutlet var sceneView: ARSCNView!
    var grids = [Grid]()
    
    var numberOfTaps = 0
    
    var startPoint: SCNVector3!
    var secondPoint : SCNVector3!
    var thirdPoint : SCNVector3!
    var endPoint: SCNVector3!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
        sceneView.addGestureRecognizer(pinchGestureRecognizer)

    }
    
    @objc func handlePinch(_ pinchRecognizer : UIPinchGestureRecognizer)
    {
        var theSlope : CGFloat
        if pinchRecognizer.state == .began || pinchRecognizer.state == .changed
        {
            if pinchRecognizer.numberOfTouches > 1
            {
                let locationOne = pinchRecognizer.location(ofTouch: 0, in: sceneView)
                let locationTwo = pinchRecognizer.location(ofTouch: 1, in: sceneView)
//                print("LocationOne : x=\(locationOne.x),y=\(locationOne.y)")
//                print("LocationTwo : x=\(locationTwo.x),y=\(locationTwo.y)")

                if (locationOne.x == locationTwo.x) {
                        // perfect vertical line
                        // not likely, but to avoid dividing by 0 in the slope equation
                    theSlope = 1000.0;
                }else if (locationOne.y == locationTwo.y) {
                        // perfect horz line
                        // not likely, but to avoid any problems in the slope equation
                    theSlope = 0.0;
                }else {
                    theSlope = (locationTwo.y - locationOne.y)/(locationTwo.x - locationOne.x);
                }
                let abSlope = abs(theSlope)
                
//                print("abSlope : \(abSlope)")
                if (abSlope < 0.5) {
                            //  Horizontal pinch - scale in the X
                    
                    print("Horizontal pinch")
                }else if (abSlope > 1.7) {
                            // Vertical pinch - scale in the Y
                    print("Verticle pinch")
                }



            }
            //let scale = pinchRecognizer.scale(view: sceneView)
            //print("x:\(scale?.x) , y:\(scale?.y	)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
            if let _ = anchor as? ARPlaneAnchor
            {
                let grid = Grid(anchor: anchor as! ARPlaneAnchor)
                self.grids.append(grid)
                node.addChildNode(grid)
                //        print("NODE : \(node.position)")
            }
    }
   
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
            let grid = self.grids.filter { grid in
                return grid.anchor.identifier == anchor.identifier
            }.first
            
            guard let foundGrid = grid else {
                return
            }
            
           
                foundGrid.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    @objc func tapped(gesture: UITapGestureRecognizer) {
        numberOfTaps += 1
        
        
        
        
        // Get 2D position of touch event on screen
        let touchPosition = gesture.location(in: sceneView)
        
        // Translate those 2D points to 3D points using hitTest (existing plane)
        let hitTestResults = sceneView.hitTest(touchPosition, types: .existingPlane)
        
        guard let hitTest = hitTestResults.first else {
            
            return
        }
        
        // If first tap, add red marker. If second tap, add green marker and reset to 0
        if numberOfTaps == 1 {
            startPoint = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
            //print(p1)
            addRedMarker(hitTestResult: hitTest)
        }
        else if numberOfTaps == 2
        {
            secondPoint = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
            addBlueMarker(hitTestResult: hitTest)
            
            addLineBetween(start: startPoint, end: secondPoint)
            addDistanceText(distance: SCNVector3.distanceFrom(vector: startPoint, toVector: secondPoint), at: secondPoint)
        }
        else if numberOfTaps == 3
        {
            thirdPoint = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
            addYellowMarker(hitTestResult: hitTest)
            //
            addLineBetween(start: secondPoint, end: thirdPoint)
            addDistanceText(distance: SCNVector3.distanceFrom(vector: secondPoint, toVector: thirdPoint), at: thirdPoint)
        }
        else {
            // After 4rd tap, reset taps to 0
            numberOfTaps = 0
            endPoint = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
            addGreenMarker(hitTestResult: hitTest)
            addLineBetween(start: thirdPoint, end: endPoint)
            addDistanceText(distance: SCNVector3.distanceFrom(vector: thirdPoint, toVector: endPoint), at: endPoint)
            
             addPlaneBetween(start: startPoint, second: secondPoint, third: thirdPoint, end: endPoint)
//            print(startPoint)
//            print(secondPoint)
//            print(thirdPoint)
//            print(endPoint)
            
            print(secondPoint.x-startPoint.x)
            print(thirdPoint.y-secondPoint.y )
            
            
            
            
            
        }
    }
    
    
    
    func addPlaneBetween(start: SCNVector3, second:SCNVector3, third:SCNVector3, end: SCNVector3) {
        let PlaneGeometry = SCNGeometry.PlaneFrom(startVector: start, secondVector: second, thirdVector: third, endVector: end)
//        let plane = SCNPlane(sources: PlaneGeometry.sources, elements: PlaneGeometry.elements)
//
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named:"overlay_grid1")
//        material.isDoubleSided = true
//        plane.materials = [material]
//
//
//        let tempPlane = SCNPlane(width: 0.1, height: 0.1)
//        tempPlane.materials = [material]
        let planeNode = SCNNode(geometry: PlaneGeometry)
        
        sceneView.scene.rootNode.addChildNode(planeNode)
    }
    
    func addRedMarker(hitTestResult: ARHitTestResult) {
        addMarker(hitTestResult: hitTestResult, color: .red)
    }
    
    func addGreenMarker(hitTestResult: ARHitTestResult) {
        addMarker(hitTestResult: hitTestResult, color: .green)
    }
    func addBlueMarker(hitTestResult: ARHitTestResult) {
        addMarker(hitTestResult: hitTestResult, color: .blue)
    }
    func addYellowMarker(hitTestResult: ARHitTestResult) {
        addMarker(hitTestResult: hitTestResult, color: .yellow)
    }
    
    func addMarker(hitTestResult: ARHitTestResult, color: UIColor) {
        let geometry = SCNSphere(radius: 0.01)
        geometry.firstMaterial?.diffuse.contents = color
        
        let markerNode = SCNNode(geometry: geometry)
        markerNode.position = SCNVector3(hitTestResult.worldTransform.columns.3.x, hitTestResult.worldTransform.columns.3.y, hitTestResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(markerNode)
    }
    
    func addLineBetween(start: SCNVector3, end: SCNVector3) {
        let lineGeometry = SCNGeometry.lineFrom(vector: start, toVector: end)
        let lineNode = SCNNode(geometry: lineGeometry)
        
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    func addDistanceText(distance: Float, at point: SCNVector3) {
        let textGeometry = SCNText(string: String(format: "%.1f\"", distance.metersToInches()), extrusionDepth: 1)
        textGeometry.font = UIFont.systemFont(ofSize: 10)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.black
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3Make(point.x, point.y, point.z);
        textNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}

