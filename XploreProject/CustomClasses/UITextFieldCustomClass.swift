
import UIKit
enum placeholderDirection: String {
    case placeholderUp = "up"
    case placeholderDown = "down"
    
}
 class UITextFieldCustomClass: UITextFieldFontSize {

    var enableMaterialPlaceHolder : Bool = true
    var placeholderAttributes = NSDictionary()
    var lblPlaceHolder = UILabel()
    var defaultFont = UIFont()
    var difference: CGFloat = 20.0
    var directionMaterial = placeholderDirection.placeholderUp
    //    var isUnderLineAvailabe : Bool = true
    var isUnderLineAvailabe : Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        Initialize ()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Initialize ()
    }
    func Initialize(){
        self.clipsToBounds = false
        self.addTarget(self, action: #selector(UITextFieldCustomClass.textFieldDidChange), for: .editingChanged)
        self.EnableMaterialPlaceHolder(enableMaterialPlaceHolder: true)
        if isUnderLineAvailabe {
            let underLine = UIImageView()
            underLine.backgroundColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 0.8)
            self.lblPlaceHolder.font = UIFont.systemFont(ofSize: 18)
            //            underLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)
            underLine.frame = CGRect(x: -30, y: self.frame.size.height-1, width : self.frame.size.width-20, height : 1)
            
            underLine.clipsToBounds = true
            self.addSubview(underLine)
        }
        defaultFont = self.font!
        
    }
    @IBInspectable var placeHolderColor: UIColor? = UIColor.lightGray {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder! as String ,
                                                            attributes:[NSAttributedStringKey.foregroundColor: placeHolderColor!])
        }
    }
    override internal var placeholder:String?  {
        didSet {
            //  NSLog("placeholder = \(placeholder)")
        }
        willSet {
            let atts  = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.lightGray, NSAttributedStringKey.font: UIFont.labelFontSize] as! [NSAttributedStringKey : Any]
            self.attributedPlaceholder = NSAttributedString(string: newValue!, attributes:atts)
            self.EnableMaterialPlaceHolder(enableMaterialPlaceHolder: self.enableMaterialPlaceHolder)
        }
        
    }
    override internal var attributedText:NSAttributedString?  {
        didSet {
            //  NSLog("text = \(text)")
        }
        willSet {
            if (self.placeholder != nil) && (self.text != "")
            {
                let string = NSString(string : self.placeholder!)
                self.placeholderText(string)
            }            
        }
    }
    @objc func textFieldDidChange(){
        if self.enableMaterialPlaceHolder {
            if (self.text == nil) || (self.text?.count)! > 0 {
                self.lblPlaceHolder.alpha = 1
                self.attributedPlaceholder = nil
                self.lblPlaceHolder.textColor =  self.placeHolderColor
                
                let fontSize = self.font!.pointSize;
                self.lblPlaceHolder.font = UIFont.init(name: (self.font?.fontName)!, size: fontSize)
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {() -> Void in
                if (self.text == nil) || (self.text?.count)! <= 0 {
                    
                    self.lblPlaceHolder.textColor =  self.placeHolderColor
                    
                    self.lblPlaceHolder.font = self.defaultFont
                    self.lblPlaceHolder.frame = CGRect(x: self.lblPlaceHolder.frame.origin.x, y : -2, width :self.frame.size.width, height : self.frame.size.height)
                }
                else {
                    if self.directionMaterial == placeholderDirection.placeholderUp {
                        let color =  UIColor.darkGray //UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
                        self.lblPlaceHolder.textColor = color
                        self.lblPlaceHolder.font = UIFont.systemFont(ofSize: 18)

                        self.lblPlaceHolder.frame = CGRect(x : self.lblPlaceHolder.frame.origin.x, y : -self.difference, width : self.frame.size.width, height : self.frame.size.height)
                    }else{
                        self.lblPlaceHolder.textColor =  self.placeHolderColor
                        
                        self.lblPlaceHolder.frame = CGRect(x : self.lblPlaceHolder.frame.origin.x, y : self.difference, width : self.frame.size.width, height : self.frame.size.height)
                    }
                    
                }
            }, completion: {(finished: Bool) -> Void in
            })
        }
    }
    
    func EnableMaterialPlaceHolder(enableMaterialPlaceHolder: Bool){
        self.enableMaterialPlaceHolder = enableMaterialPlaceHolder
        self.lblPlaceHolder = UILabel()
        self.lblPlaceHolder.frame = CGRect(x: 0, y : 0, width : 0, height :self.frame.size.height)
        self.lblPlaceHolder.font = UIFont.systemFont(ofSize: 18)
        self.lblPlaceHolder.alpha = 0
        self.lblPlaceHolder.clipsToBounds = true
        self.addSubview(self.lblPlaceHolder)
        self.lblPlaceHolder.attributedText = self.attributedPlaceholder
        //self.lblPlaceHolder.sizeToFit()
    }
    
    func placeholderText(_ placeholder: NSString){
        let atts  = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.lightGray, NSAttributedStringKey.font: UIFont.labelFontSize] as! [NSAttributedStringKey : Any]
        self.attributedPlaceholder = NSAttributedString(string: placeholder as String , attributes:atts)
        self.EnableMaterialPlaceHolder(enableMaterialPlaceHolder: self.enableMaterialPlaceHolder)
        
    }
    override func becomeFirstResponder()->(Bool){
        let returnValue = super.becomeFirstResponder()
        return returnValue
        
    }
    override func resignFirstResponder()->(Bool){
        let returnValue = super.resignFirstResponder()
        return returnValue
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
