import SpriteKit
import CoreMotion
import AudioToolbox

class GameScene: SKScene, SKPhysicsContactDelegate {
    var bubble = SKSpriteNode()
    var platform = SKSpriteNode()
    var background = SKSpriteNode()
    var motionManager = CMMotionManager()
    var destX:CGFloat  = 0.0
    var destY:CGFloat  = 0.0
    
    var lastUpdateTime: CFTimeInterval = 0.0
    var deltaTime: CFTimeInterval = 0.0
    var doSomethingTimer: CFTimeInterval = 0.0
    var isInContact: Bool = false
    var isBlinking: Bool = false
    
    
    override func didMove(to view: SKView) {
        
        platform = (self.childNode(withName: "platform") as? SKSpriteNode)!
        platform.name = "platform"
        
        bubble = (self.childNode(withName: "bubble") as? SKSpriteNode)!
        bubble.name = "bubble"
        
        //background = (self.childNode(withName: "background") as? SKSpriteNode)!
        //addParallaxToView(vw: background)
        
        self.physicsWorld.contactDelegate = self

        if motionManager.isAccelerometerAvailable == true {
            
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:{
                data, error in
                
                let currentX = self.bubble.position.x
                let currentY = self.bubble.position.y
                
                if Double((data?.acceleration.y)!) != 0 {
                    let nextX = currentX - CGFloat((data?.acceleration.y)! * 100)
                    if (nextX-70 > 0 && nextX < self.frame.size.width-70) {
                        self.destX = nextX
                    }
                }
                
                if Double((data?.acceleration.x)!) != 0 {
                    let nextY = currentY + CGFloat((data?.acceleration.x)! * 100)
                    if (nextY-70 > 0 && nextY < self.frame.size.height-70) {
                        self.destY = nextY
                    }
                }
            })
        }
    }
    
    
    func didEnd(_ contact: SKPhysicsContact){
        print("collided! didEnd")
        self.isInContact = false
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        updateBubble()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("collided! didBegin")
        self.isInContact = true
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        updateBubble()
    }
    
    func updateBubble () {
        self.bubble.texture = SKTexture(imageNamed: getBubbleName())
    }
    
    
    func getBubbleName () -> String {
        var name = ""
        
        if self.isInContact {
            name = "bubble_happy"
        } else {
            name = "bubble_sad"
        }
        
        if self.isBlinking {
            name = name + "_blink"
        }
        
        return name
        
    }
    
    func blink (_ currentTime: CFTimeInterval) {
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        doSomethingTimer += deltaTime
        
        //var blink = random
        if doSomethingTimer >= 5.0 {
            if (!isBlinking) {
               isBlinking = true
            }
            doSomethingTimer = 0.0
        } else if doSomethingTimer >= 0.2 && isBlinking {
            isBlinking = false

        }
        
        updateBubble()

        //print("DELTA: \(deltaTime) CURRENT TIME: \(currentTime)")
    }
    
    
    
    /*
     
     func updateBubble () {
        if self.isInContact {
            self.bubble.texture = SKTexture(imageNamed: "bubble_happy")
        } else {
            self.bubble.texture = SKTexture(imageNamed: "bubble_sad")
        }
     }
     
     
    func blink (_ currentTime: CFTimeInterval) {
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        doSomethingTimer += deltaTime
        
        //var blink = random
        if doSomethingTimer >= 5.0 {
            if (!(self.bubble.texture?.description.contains("bubble_blink"))!) {
                self.bubble.texture = SKTexture(imageNamed: "bubble_blink")
            }
            doSomethingTimer = 0.0
        } else if doSomethingTimer >= 0.2 && (self.bubble.texture?.description.contains("bubble_blink"))! {
            updateBubble()
        }
        

        //print("DELTA: \(deltaTime) CURRENT TIME: \(currentTime)")
    } */
    
    override func update(_ currentTime: CFTimeInterval) {

        blink (currentTime)
        
        if (self.bubble.position.x != destX) {
            let action = SKAction.moveTo(x: destX, duration: 0.04)
            self.bubble.run(action)
        }
        
        if (self.bubble.position.y != destY) {
            let action2 = SKAction.moveTo(y: destY, duration: 0.04)
            self.bubble.run(action2)
        }
    }
    
    func addParallaxToView(vw: UIView) {
        let amount = 100
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
}
