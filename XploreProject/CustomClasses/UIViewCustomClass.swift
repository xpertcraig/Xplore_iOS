
import UIKit
@IBDesignable class UIViewCustomClass: UIView {

    @IBInspectable var borderWidth:CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor:UIColor {
        get { return UIColor(cgColor: layer.borderColor!) }
        set { layer.borderColor = newValue.cgColor }
    }
    
    @IBInspectable var cornerRadius:CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable var shadowColor:UIColor {
        get { return UIColor(cgColor: layer.shadowColor!)}
        set { layer.shadowColor = hexStringToUIColor(hex: "#000000").cgColor
              layer.masksToBounds = false
              layer.shadowOpacity = 0.3
              layer.shadowOffset = CGSize.zero
              layer.shadowRadius = 2
             // layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
              //layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
              layer.shouldRasterize = true
              layer.rasterizationScale = true ? UIScreen.main.scale : 1
        }
    }
    
    fileprivate var _round = false
    @IBInspectable var round: Bool {
        set {
            _round = newValue
            makeRound()
        }
        get {
            return self._round
        }
    }
    
    override internal var frame: CGRect {
        set {
            super.frame = newValue
            makeRound()
        }
        get {
            return super.frame
        }
        
    }
    
    fileprivate func makeRound() {
        if self.round == true {
            self.clipsToBounds = true
            self.layer.cornerRadius = self.frame.width*0.5
        }
        else {
            self.layer.cornerRadius = 0
        }
    }
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
   }
