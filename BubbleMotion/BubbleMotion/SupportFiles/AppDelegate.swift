import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let comunicationService = CommunicationService()
    
    
    class func startMultiplayerGameplay (){
        // let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Gameplay")
        // self.present (loginViewController!, animated: true)
    }
    
    func showAlertAppDelegate(title : String,message : String,buttonTitle : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: nil))
        window!.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showMultiplayerInvite (){
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Invite", message: "You are invited to play ", preferredStyle: UIAlertController.Style.alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                self.comunicationService.respondInvitationToPlay(response: true)
            }
            alert.addAction(OKAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                self.comunicationService.respondInvitationToPlay(response: false)
            }
            alert.addAction(cancelAction)
            
            //self.window!.rootViewController?.present(alert, animated: true, completion: nil)
            let navigationController = self.window!.rootViewController as! UINavigationController
            let activeViewCont = navigationController.visibleViewController
            activeViewCont?.present(alert, animated: true, completion: nil)
            
        }
    }
    
    @objc func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    @objc func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }
    
    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    @objc func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

