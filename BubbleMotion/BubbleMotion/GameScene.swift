import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var bubble = SKSpriteNode()
    var platform = SKSpriteNode()
    var motionManager = CMMotionManager()
    var destX:CGFloat  = 0.0
    var destY:CGFloat  = 0.0
    let bubbleCat : UInt32 = 0x1 << 1
    let platformCat : UInt32 = 0x1 << 2
    
    
    override func didMove(to view: SKView) {
        
        platform = (self.childNode(withName: "platform") as? SKSpriteNode)!
        platform.name = "platform"
//        platform.physicsBody?.categoryBitMask = platformCat
//        platform.physicsBody?.collisionBitMask = 0
//        platform.physicsBody?.contactTestBitMask = bubbleCat
        platform.zPosition = 1
        
        bubble = (self.childNode(withName: "bubble") as? SKSpriteNode)!
        bubble.name = "bubble"
        let phsb = SKPhysicsBody(circleOfRadius: bubble.size.width/2)
        //bubble.physicsBody = phsb

        bubble.physicsBody?.affectedByGravity = false
        platform.physicsBody?.isDynamic = false
        //bubble.physicsBody?.isDynamic = false

//        bubble.physicsBody?.categoryBitMask = bubbleCat
//        bubble.physicsBody?.collisionBitMask = 0
//        bubble.physicsBody?.contactTestBitMask = platformCat
        bubble.zPosition = 2
        
        
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
        self.backgroundColor = UIColor.red
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        self.backgroundColor = UIColor.green

        print("collided! didBegin")
    }
    
    override func update(_ currentTime: CFTimeInterval) {

        if (self.bubble.position.x != destX) {
            let action = SKAction.moveTo(x: destX, duration: 0.04)
            self.bubble.run(action)
        }
        
        if (self.bubble.position.y != destY) {
            let action2 = SKAction.moveTo(y: destY, duration: 0.04)
            self.bubble.run(action2)
        }
    }
}
