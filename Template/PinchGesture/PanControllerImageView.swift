//
//  PanControllerImageView.swift
//  TextEditor
//
//  Created by M M MEHEDI HASAN on 1/19/21.
//

import UIKit

@inline(__always) func CGAffineTransformGetAngle(_ t:CGAffineTransform) -> CGFloat {
    return atan2(t.b, t.a)
}

@inline(__always) func CGPointGetDistance(point1:CGPoint, point2:CGPoint) -> CGFloat {
    let fx = point2.x - point1.x
    let fy = point2.y - point1.y
    return sqrt(fx * fx + fy * fy)
}

class PanControllerImageView: UIImageView, UIGestureRecognizerDelegate {
    
    var textView: TextStickerView!
    var initialFrame: CGRect!
    var initialFontSize: CGFloat!
    var initialDist: CGFloat!
    var initialCenter: CGPoint!
    var deltaAngle: CGFloat!
    var panControllerSize: CGFloat = 25
    var pController: PanControllerImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        self.image = UIImage(named: "zoom")
        self.addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PanControllerImageView {
    //MARK: Add Gesture
    func addGesture(){
       
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer){
        let location = gesture.location(in: self.superview!.superview)
        let center = self.superview!.center
        switch gesture.state {
        case .began:
            
            for sub in self.superview!.subviews  {
                if sub.tag == 1000{
                    self.textView = (sub as! TextStickerView)
                }else{
                    self.pController = (sub as! PanControllerImageView)
                }
            }
            self.deltaAngle = CGFloat(atan2f(Float(location.y - center.y), Float(location.x - center.x))) - CGAffineTransformGetAngle(self.superview!.transform)
            
            self.initialDist = CGPointGetDistance(point1: center, point2: location)
            self.initialFontSize = self.textView.font!.pointSize
            
            break
        case .changed:
            
            if textView != nil{
                let angle = atan2f(Float(location.y - center.y), Float(location.x - center.x))
                let angleDiff = Float (self.deltaAngle) - angle
                self.superview!.transform = CGAffineTransform(rotationAngle: CGFloat(-angleDiff))
              
               // let scale = (area2 / area1)
                let scale = (CGPointGetDistance(point1: center, point2: location) / self.initialDist)
                
                    //self.distance(center, location) / self.initialDist
              //  print("Scale2  ; ", scale ,"  :  ")
                self.textView.font = UIFont(name: textView.font!.fontName, size: self.initialFontSize * scale)
                let newSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                
                let containerSize = CGSize(width: newSize.width + (self.panControllerSize * 2), height: newSize.height + (self.panControllerSize * 2))
                let textviewSize = CGSize(width: newSize.width, height: newSize.height)
                
                self.textView.bounds.size = textviewSize
                self.textView.frame.origin = CGPoint(x: (gesture.view?.superview!.bounds.origin)!.x + self.panControllerSize, y: (gesture.view?.superview!.bounds.origin)!.y + self.panControllerSize)
                gesture.view?.superview!.bounds.size = containerSize
                //self.frame.origin = CGPoint(x: containerFrame.width - 44, y: 0)
            }
            break
        case .ended:
//            gesture.view?.superview?.frame.size = CGSize(width: self.initialFrame.width + translation.x, height: self.initialFrame.height + translation.y)
            print("End")
            break
        default:
            print("Not Match")
        }
    }
    
}
