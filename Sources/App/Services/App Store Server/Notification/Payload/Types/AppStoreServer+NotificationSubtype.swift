
import Foundation


// MARK: Uygulama içi satın alma olayının ayrıntıları. (varsa)
extension AppStoreNotificationPayload {
    public enum NotificationSubtype: String, Codable {
        
        /// `INITIAL_BUY`
        ///
        /// `SUBSCRIBED` Bildirim Türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  kullanıcının aboneliği ilk kez satın aldığını veya kullanıcının Aile Paylaşımı
        ///  yoluyla ilk kez aboneliğe erişim elde ettiğini gösterir.
        ///
        case initialBuy = "INITIAL_BUY"
        
        /// `RESUBSCRIBE`
        ///
        /// `SUBSCRIBED` Bildirim Türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  kullanıcının yeniden abone olduğunu veya Aile Paylaşımı aracılığıyla aynı
        ///  aboneliğe veya aynı abonelik grubu içindeki başka bir aboneliğe
        ///  erişim aldığını gösterir.
        ///
        case resubscribe = "RESUBSCRIBE"
        
        /// `UPGRADE`
        ///
        /// `DID_CHANGE_RENEWAL_PREF` Bildirim Türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  kullanıcının aboneliğini yükselttiğini gösterir. Yükseltmeler hemen etkinleşir.
        ///
        case upgrade = "UPGRADE"
        
        /// `DOWNGRADE`
        ///
        /// `DID_CHANGE_RENEWAL_PREF` Bildirim Türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        /// kullanıcının aboneliğini düşürdüğünü gösterir. Düşürmeler bir sonraki yenilemede geçerli olur.
        ///
        case downgrade = "DOWNGRADE"
        
        /// `AUTO_RENEW_ENABLED`
        ///
        /// `DID_CHANGE_RENEWAL_STATUS` Bildirim Türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  kullanıcının otomatik abonelik yenilemeyi etkinleştirdiğini gösterir.
        ///
        case autoRenewEnabled = "AUTO_RENEW_ENABLED"
        
        /// `AUTO_RENEW_DISABLED`
        ///
        /// `DID_CHANGE_RENEWAL_STATUS` Bildirim Türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  kullanıcının otomatik abonelik yenilemeyi devre dışı bıraktığını veya kullanıcı geri
        ///  ödeme talebinde bulunduktan sonra App Store'un otomatik abonelik yenilemeyi
        ///  devre dışı bıraktığını gösterir.
        ///
        case autoRenewDisabled = "AUTO_RENEW_DISABLED"
        
        /// `BILLING_RECOVERY`
        ///
        /// `DID_RENEW` Bildirim Türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  daha önce yenilenemeyen süresi dolmuş aboneliğin başarıyla yenilendiğini gösterir.
        ///
        case billingRecovery = "BILLING_RECOVERY"
        
        /// `GRACE_PERIOD`
        ///
        /// `DID_FAIL_TO_RENEW` Bildirim Türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  aboneliğin bir faturalandırma sorunu nedeniyle yenilenemeyeceğini gösterir.
        ///  Ek süre boyunca aboneliğe erişim sağlamaya devam edin.
        ///
        case gracePeriod = "GRACE_PERIOD"
        
        /// `VOLUNTARY`
        ///
        /// `EXPIRED` Bildirim türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  kullanıcı otomatik abonelik yenilemeyi devre dışı bıraktıktan sonra
        ///  aboneliğin süresinin dolduğunu belirtir.
        ///
        case voluntary = "VOLUNTARY"
        
        /// `BILLING_RETRY`
        ///
        /// `EXPIRED` bildirim türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  aboneliğin faturalandırma yeniden deneme süresi sona ermeden önce
        ///  yenilenemediği için aboneliğin süresinin dolduğunu belirtir.
        ///
        case billingRetry = "BILLING_RETRY"
        
        /// `PRICE_INCREASE`
        ///
        /// `EXPIRED` Bildirim türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  kullanıcı bir fiyat artışına izin vermediği için aboneliğin süresinin dolduğunu belirtir.
        ///
        case priceIncrease = "PRICE_INCREASE"
        
        /// `ACCEPTED`
        ///
        /// `PRICE_INCREASE` bildirim türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  kullanıcının abonelik fiyatı artışını kabul ettiğini gösterir.
        ///
        case accepted = "ACCEPTED"
        
        /// `PENDING`
        ///
        /// `PRICE_INCREASE` Bildirim Türü için geçerlidir. Bu subtype'a sahip bir bildirim,
        ///  sistemin kullanıcıyı abonelik fiyatı artışı konusunda bilgilendirdiğini ancak
        ///  kullanıcının bunu kabul etmediğini gösterir.
        ///
        case pending = "PENDING"
        
        /// `SUMMARY`
        ///
        /// `RENEWAL_EXTENDED` veya `RENEWAL_EXTENSION` Bildirim Türü için geçerlidir. Bu subtype'a sahip bir bildirim, yükte summary nesnesinin olduğunu söyler.
        case summary = "SUMMARY"
    }
}


