//
//  ViewController.swift
//  XZApplePay
//
//  Created by admin on 2019/4/17.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import PassKit
import AddressBook

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        
    }

    @IBAction func payAction(_ sender: UIButton) {
        
//        // 检查用户是否支持 Apple Pay
//        if !PKPaymentAuthorizationViewController.canMakePayments() {
//
//            print("设备不支持 Apple Pay")
//            return
//        }
//
//        // 检查是否支付用户卡片
//        var paymentNetworks = [PKPaymentNetwork]()
//
//        if #available(iOS 9.2, *) { // 银联卡要求 iOS 9.2+
//            paymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.chinaUnionPay]
//        }else {
//            paymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard]
//        }
//
//        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
//
//            print("不支持的卡片类型。目前仅支持 Visa、MasterCard、中国银联卡。")
//            return
//        }
//
        // 创建付款请求
        beginPayAction()
    }
    
}


// MARK: - applepay原生支付
extension ViewController: PKPaymentAuthorizationViewControllerDelegate  {
    
    /// 创建支付请求
    func beginPayAction() {
        let request = PKPaymentRequest()
        // 设置可进行支付的银行卡
        if #available(iOS 9.2, *) {
            request.supportedNetworks = [PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa, PKPaymentNetwork.chinaUnionPay]
        } else {
            request.supportedNetworks = [PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa]
        }
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: request.supportedNetworks) {
            
            print("可以支付，开始建立支付请求")
            
            // 国家代码
            request.countryCode = "CN"
            // 人民币
            request.currencyCode = "CNY"
            // 申请的 merchantID
            request.merchantIdentifier = "merchant.com.xz.ApplePay"
            // 设置处理协议，3DS必须支持，EMV为可选，国内的最好两者
            request.merchantCapabilities = PKMerchantCapability.capability3DS
            
            // 设置发票配送信息和货物配送地址信息
            let fields:Set<PKContactField> = [.postalAddress, .phoneNumber, .name]
            request.requiredShippingContactFields = fields
            
            // 设置订单详情
            let wax = PKPaymentSummaryItem(label: "订单金额", amount: NSDecimalNumber(string: "100"))
            let total = PKPaymentSummaryItem(label: "支付给谁", amount: wax.amount)
//            let discount = PKPaymentSummaryItem(label: "优惠折扣", amount: NSDecimalNumber(string: "14.32"))
            // discount
            request.paymentSummaryItems = [wax, total]
            
            // 设置2种配送方式
            let freeShipping = PKShippingMethod(label: "包邮", amount: NSDecimalNumber.zero)
            freeShipping.identifier = "freeShipping"
            freeShipping.detail = "3-8天 送达"
            
            let moneyShipping = PKShippingMethod(label: "快递", amount: NSDecimalNumber(string: "10.00"))
            moneyShipping.identifier = "moneyShipping"
            moneyShipping.detail = "1-3天 送达"
            
            request.shippingMethods = [freeShipping, moneyShipping]
            
            // 弹出付款页
            let vc = PKPaymentAuthorizationViewController(paymentRequest: request)
            vc?.delegate = self
            present(vc!, animated: true, completion: nil)
        }else {
            print("您没有绑定任何银行卡或者当前设备不支持ApplePay")
        }
    }
    
    // 支付完成回调
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        
        print("支付结束")
        dismiss(animated: true, completion: nil)
    }
    
    // 支付卡选择回调
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void) {
        
        // 如果需要根据不同的银行调整支付金额，可以实现该代理
    }
    
    // 送货方式回调
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        
        // 如果需要根据不同的送货方式进行支付金额的调整，比如包邮和付费加速配送，可以实现该代理
//        let oldShippingMethod = PKPaymentRequestShippingMethodUpdate.accessibilityElement(at: 2)
       
//        print("PKPaymentRequestShippingMethodUpdate：", PKPaymentRequestShippingMethodUpdate())
    }
    
    // 支付成功，苹果服务器返回信息回调，做服务器验证
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        let paymentToken = payment.token
        let billingContact = payment.billingContact // 账单信息
        let shippingContact = payment.shippingContact // 送货信息
        let shippMethod = payment.shippingMethod // 送货方式
        
        print("账单信息:", billingContact as Any, "送货信息:", shippingContact as Any, "送货方式:", shippMethod as Any)
 
        print("=======paymentToken:", paymentToken)
        
        // 调后端接口返回success或者fail
        completion(PKPaymentAuthorizationStatus.success)
        
//        // 订单ID 暂时
//        let vc = KeMyTicketVc.init(orderId: "")
//        navigationController?.pushViewController(vc, animated: true)
    }
}
