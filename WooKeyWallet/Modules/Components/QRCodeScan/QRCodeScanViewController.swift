//
//  QRCodeScanViewController.swift


import UIKit
import AVFoundation

class QRCodeScanViewController: BaseViewController {

    typealias ScanResultHandler = ([LBXScanResult], QRCodeScanViewController) -> Void
    
    // MARK: - Properties (Closure)
    
    public var resultHandler: ScanResultHandler?
    
    
    //返回扫码结果，也可以通过继承本控制器，改写该handleCodeResult方法即可
    open weak var scanResultDelegate: LBXScanViewControllerDelegate?
    
    open var delegate: QRRectDelegate?
    
    open var scanObj: LBXScanWrapper?
    
    open lazy var scanStyle: LBXScanViewStyle = {
        //设置扫码区域参数
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.Inner
        style.photoframeLineW = 3
        style.photoframeAngleW = 18
        style.photoframeAngleH = 18
        style.isNeedShowRetangle = false
        
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        
        //qq里面的线条图片
        style.animationImage = UIImage(named: "qrcode_scan_light_green")
        return style
    }()
    
    open var qRScanView: LBXScanView?
    
    
    //启动区域识别功能
    open var isOpenInterestRect = true
    
    //识别码的类型
    public var arrayCodeType:[AVMetadataObject.ObjectType]?
    
    //是否需要识别后的当前图像
    public  var isNeedCodeImage = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // [self.view addSubview:_qRScanView];
        self.view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.navigationItem.title = LocalizedString(key: "scan", comment: "扫一扫")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(key: "photos", comment: "相册"), style: .plain, target: self, action: #selector(QRCodeScanViewController.openPhotoAlbum))
    }
    
    open func setNeedCodeImage(needCodeImg:Bool)
    {
        isNeedCodeImage = needCodeImg;
    }
    //设置框内识别
    open func setOpenInterestRect(isOpen:Bool){
        isOpenInterestRect = isOpen
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        drawScanView()
        
        perform(#selector(LBXScanViewController.startScan), with: nil, afterDelay: 0.3)
    }
    
    @objc open func startScan()
    {
        
        if (scanObj == nil)
        {
            var cropRect = CGRect.zero
            if isOpenInterestRect
            {
                cropRect = LBXScanView.getScanRectWithPreView(preView: self.view, style:scanStyle)
            }
            
            //指定识别几种码
            if arrayCodeType == nil
            {
                arrayCodeType = [AVMetadataObject.ObjectType.qr as NSString ,AVMetadataObject.ObjectType.ean13 as NSString ,AVMetadataObject.ObjectType.code128 as NSString] as [AVMetadataObject.ObjectType]
            }
            
            scanObj = LBXScanWrapper(videoPreView: self.view,objType:arrayCodeType!, isCaptureImg: isNeedCodeImage,cropRect:cropRect, success: { [weak self] (arrayResult) -> Void in
                
                if let strongSelf = self
                {
                    //停止扫描动画
                    strongSelf.qRScanView?.stopScanAnimation()
                    
                    strongSelf.handleCodeResult(arrayResult: arrayResult)
                }
            })
        }
        
        //结束相机等待提示
        qRScanView?.deviceStopReadying()
        
        //开始扫描动画
        qRScanView?.startScanAnimation()
        
        //相机运行
        scanObj?.start()
    }
    
    open func drawScanView()
    {
        if qRScanView == nil
        {
            qRScanView = LBXScanView(frame: self.view.frame,vstyle:scanStyle)
            self.view.addSubview(qRScanView!)
            delegate?.drawwed()
        }
        qRScanView?.deviceStartReadying(readyStr: "")
        
    }
    
    
    /**
     处理扫码结果，如果是继承本控制器的，可以重写该方法,作出相应地处理，或者设置delegate作出相应处理
     */
    open func handleCodeResult(arrayResult: [LBXScanResult])
    {
        resultHandler?(arrayResult, self)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        qRScanView?.stopScanAnimation()
        
        scanObj?.stop()
    }
    
    @objc
    open func openPhotoAlbum()
    {
        LBXPermissions.authorizePhotoWith { [weak self] (granted) in
            
            let picker = UIImagePickerController()
            
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            picker.delegate = self;
            
            picker.allowsEditing = true
            
            self?.present(picker, animated: true, completion: nil)
        }
    }
    
    func showMsg(title:String?,message:String?)
    {
        
        let alertController = UIAlertController(title: nil, message:message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: LocalizedString(key: "confirm", comment: "确定"), style: UIAlertAction.Style.default) { (alertAction) in
            
            //                if let strongSelf = self
            //                {
            //                    strongSelf.startScan()
            //                }
        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
}


extension QRCodeScanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: -----相册选择图片识别二维码 （条形码没有找到系统方法）
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var image:UIImage? = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if (image == nil )
        {
            image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        if(image != nil)
        {
            let arrayResult = LBXScanWrapper.recognizeQRImage(image: image!)
            handleCodeResult(arrayResult: arrayResult)
        } else {
            handleCodeResult(arrayResult: [])
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if #available(iOS 11, *) {
            if let cls = NSClassFromString("PUPhotoPickerHostViewController"),
                viewController.isKind(of: cls) {
                for subview in viewController.view.subviews {
                    if subview.bounds.size.width < 42 {
                        viewController.view.sendSubviewToBack(subview)
                    }
                }
            }
        }
    }
}
