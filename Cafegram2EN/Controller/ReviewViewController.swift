//
//  ReviewViewController.swift
//  Cafegram2EN
//
//  Created by Ibrahim Mo Gedami on 16/05/2020.
//  Copyright © 2020 Ibrahim Mo Gedami. All rights reserved
//

import UIKit

class ReviewViewController: UIViewController {
    
    @IBOutlet var rateButtons: [UIButton]!
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    var cafe: CafeMO!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cafeimage = cafe.image {
            backgroundImageView.image = UIImage(data: cafeimage as Data)
        }
        
        // Applying the blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        let moveRightTransform = CGAffineTransform.init(translationX: 600, y: 0)
        let scaleUpTransform = CGAffineTransform.init(scaleX: 5.0, y: 5.0)
        let moveScaleTransform = scaleUpTransform.concatenating(moveRightTransform)
        
        // Make the buttons invisible
        for rateButton in rateButtons {
            rateButton.transform = moveScaleTransform
            rateButton.alpha = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [], animations: {
            self.rateButtons[0].alpha = 1.0
            self.rateButtons[0].transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.8, delay: 0.15, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [], animations: {
            self.rateButtons[1].alpha = 1.0
            self.rateButtons[1].transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.8, delay: 0.20, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [], animations: {
            self.rateButtons[2].alpha = 1.0
            self.rateButtons[2].transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.8, delay: 0.25, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [], animations: {
            self.rateButtons[3].alpha = 1.0
            self.rateButtons[3].transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.8, delay: 0.30, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [], animations: {
            self.rateButtons[4].alpha = 1.0
            self.rateButtons[4].transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.8, delay: 0.35, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.3, options: [], animations: {
            self.rateButtons[5].alpha = 1.0
            self.rateButtons[5].transform = .identity
        }, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
