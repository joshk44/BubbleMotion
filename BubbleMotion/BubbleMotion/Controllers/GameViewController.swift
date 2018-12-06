import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = Bundle.main.path(forResource: file, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .mappedIfSafe)
            //let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            //var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            //let archiver = try! NSKeyedUnarchiver(forReadingWith: sceneData as Data)
            let archiver = try! NSKeyedUnarchiver(forReadingFrom: sceneData as Data)
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            archiver.requiresSecureCoding = false
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}


class GameViewController: UIViewController {
    
    private var comunicationService: CommunicationService!
    private var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        comunicationService = appDelegate.comunicationService
       // let notificationCenter = NotificationCenter.default
       // notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    
    @objc func appMovedToBackground() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = appDelegate.window!.rootViewController as! UINavigationController
        
        if ( navigationController.visibleViewController is GameViewController ) {
            self.sendFinishMatch(points: 0)
            finishMatch(points: 0)
        }
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scene = GameScene.unarchiveFromFile(file: "GameScene") as? GameScene
        if  scene != nil {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsPhysics = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .resizeFill
            
            print("scene size ",skView.bounds.size.height, skView.bounds.size.width)
            skView.presentScene(scene)
            
            comunicationService.delegate = self
            scene.delegateVC = self
        }
    }

    func shouldAutorotate() -> Bool {
        return true
    }

    func supportedInterfaceOrientations() -> Int {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return Int(UIInterfaceOrientationMask.allButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.all.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    func prefersStatusBarHidden() -> Bool {
        return true
    }

}

extension GameViewController : CommunicationServiceDelegate {
    
    
    func connectedDevicesChanged(manager: CommunicationService, connectedDevices: [String]) {
    }
    
    func startMatch () {
    }
    
    func bombReceived(bomb: GameState) {
        scene.setBomb (bomb: bomb);
        print ("Bomb received", bomb.rawValue)
    }
    
    func finishMatch (points: Int) {
        print ("Finish match", points)
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let navigationController = appDelegate.window!.rootViewController as! UINavigationController
            let resultViewController: ResultsViewController = self.storyboard?.instantiateViewController(withIdentifier: "Results") as! ResultsViewController
            resultViewController.myPoints = self.scene.myPoints
            resultViewController.contrincantPoints = points
            navigationController.pushViewController(resultViewController, animated: false)
            self.scene.endTimer()
        }
    }
}

extension GameViewController : GameSceneDelegate {
    
    func sendBomb (bomb: GameState) {
        comunicationService.sendBomb (bomb : bomb)
    }
    
    func sendFinishMatch (points: Int){
        comunicationService.sendResults (points: points)
    }
}
