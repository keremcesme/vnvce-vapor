
import Foundation


// MARK: Uygulama içi satın alma olayları.
extension AppStoreNotificationPayload {
    public enum NotificationType: String, Codable {
        
        /// `CONSUMPTION_REQUEST`
        /// Müşterinin bir sarf malzemesi uygulama içi satın alma işlemi için
        /// geri ödeme isteği başlattığını ve App Store'un tüketim verilerini
        /// sağlamanızı istediğini belirten bir bildirim türü.
        ///
        /// Daha fazla bilgi için:
        /// https://developer.apple.com/documentation/appstoreserverapi/send_consumption_information
        ///
        case consumptionRequest = "CONSUMPTION_REQUEST"
        
        /// `DID_CHANGE_RENEWAL_PREF`
        ///
        /// Subtype ile birlikte kullanıcının abonelik planında bir değişiklik yaptığını gösteren
        /// bir bildirim türü. Subtype `UPGRADE` ise, kullanıcı aboneliğini yükseltmiştir.
        /// Yükseltme, yeni bir fatura dönemi başlatarak hemen yürürlüğe girer ve kullanıcı,
        /// önceki dönemin kullanılmayan kısmı için orantılı bir geri ödeme alır.
        /// Alt tür `DOWNGRADE` ise, kullanıcı aboneliğini eski sürüme geçirmiş veya çapraz
        /// derecelendirmiştir. Düşürmeler bir sonraki yenilemede geçerli olur ve şu anda
        /// etkin olan planı etkilemez.
        ///
        /// Subtype boşsa, kullanıcı yenileme tercihini mevcut aboneliğe geri döndürerek
        /// etkin bir şekilde bir alt sürüme geçmeyi iptal eder.
        ///
        /// Olasi Subtype'lar:
        /// `UPGRADE`, `DOWNGRADE`
        ///
        case didChangeRenewalPref = "DID_CHANGE_RENEWAL_PREF"
        
        /// `DID_CHANGE_RENEWAL_STATUS`
        ///
        /// Subtype ile birlikte, kullanıcının abonelik yenileme durumunda değişiklik yaptığını
        /// gösteren bir bildirim türü. Subtype `AUTO_RENEW_ENABLED` ise, kullanıcı otomatik
        /// abonelik yenilemeyi yeniden etkinleştirdi. Subtype `AUTO_RENEW_DISABLED` ise,
        /// kullanıcı otomatik abonelik yenilemeyi devre dışı bıraktı veya kullanıcı geri
        /// ödeme talebinde bulunduktan sonra App Store otomatik abonelik yenilemeyi
        /// devre dışı bıraktı.
        ///
        /// Subtype'lar:
        /// `AUTO_RENEW_ENABLED`, `AUTO_RENEW_DISABLED`
        ///
        case didChangeRenewalStatus = "DID_CHANGE_RENEWAL_STATUS"
        
        /// `DID_FAIL_TO_RENEW`
        ///
        /// Subtype ile birlikte aboneliğin bir faturalandırma sorunu nedeniyle yenilenemediğini
        /// gösteren bir bildirim türü. Abonelik, faturalandırma yeniden deneme dönemine girer.
        /// Subtype `GRACE_PERIOD` ise, yetkisiz kullanım süresi boyunca hizmet vermeye devam edin.
        /// Subtype boşsa, abonelik yetkisiz kullanım süresinde değildir ve abonelik hizmetini
        /// sağlamayı durdurabilirsiniz.
        ///
        /// Kullanıcıya fatura bilgileriyle ilgili bir sorun olabileceğini bildirin. App Store,
        /// hangisi önce gerçekleşirse, 60 gün boyunca veya kullanıcı faturalandırma sorununu
        /// çözene veya aboneliğini iptal edene kadar faturalandırmayı yeniden denemeye devam eder.
        ///
        /// Olası subtype:
        /// `GRACE_PERIOD`
        ///
        /// Daha fazla bilgi için:
        /// https://developer.apple.com/documentation/storekit/in-app_purchase/original_api_for_in-app_purchase/subscriptions_and_offers/reducing_involuntary_subscriber_churn
        ///
        case didfailToRenew = "DID_FAIL_TO_RENEW"
        
        /// `DID_RENEW`
        ///
        /// Subtype ile birlikte aboneliğin başarıyla yenilendiğini gösteren bir bildirim türü.
        /// Subtype `BILLING_RECOVERY` ise, daha önce yenilenemeyen süresi dolmuş abonelik
        /// başarıyla yenilenmiştir. Subtype boşsa, etkin abonelik yeni bir işlem
        /// dönemi için başarıyla otomatik olarak yenilenmiştir.
        /// Müşteriye abonelik içeriğine veya hizmetine erişim sağlayın.
        ///
        /// Olası subtype:
        /// `BILLING_RECOVERY`
        ///
        case didRenew = "DID_RENEW"
        
        /// `EXPIRED`
        ///
        /// Subtype ile birlikte bir aboneliğin süresinin dolduğunu gösteren bir bildirim türü.
        /// Subtype `VOLUNTARY` ise, kullanıcı abonelik yenilemeyi devre dışı bıraktıktan sonra
        /// abonelik sona erdi. Subtype `BILLING_RETRY` ise, faturalandırma yeniden deneme
        /// dönemi başarılı bir faturalandırma işlemi olmadan sona erdiği için aboneliğin
        /// süresi doldu. Subtype `PRICE_INCREASE` ise kullanıcı, kullanıcı onayı gerektiren
        /// bir fiyat artışına izin vermediği için aboneliğin süresi dolmuştur.
        /// Subtype `PRODUCT_NOT_FOR_SALE` ise, abonelik yenilenmeye çalışıldığında
        /// ürün satın alınamadığı için abonelik sona ermiştir.
        ///
        /// Subtype olmayan bir bildirim, aboneliğin başka bir nedenle sona erdiğini gösterir.
        ///
        /// Subtype'lar:
        /// `VOLUNTARY`, `BILLING_RETRY`, `PRICE_INCREASE`
        ///
        case expired = "EXPIRED"
        
        /// `GRACE_PERIOD_EXPIRED`
        ///
        /// Hizmete veya içeriğe erişimi kapatabilmeniz için aboneliği yenilemeden faturalandırma
        /// yetkisiz kullanım süresinin sona erdiğini belirten bir bildirim türü.
        ///
        /// Kullanıcıya fatura bilgileriyle ilgili bir sorun olabileceğini bildirin. App Store,
        /// hangisi önce gerçekleşirse, 60 gün boyunca veya kullanıcı faturalandırma sorununu
        /// çözene veya aboneliğini iptal edene kadar faturalandırmayı yeniden denemeye devam eder.
        ///
        ///
        /// Daha fazla bilgi için:
        /// https://developer.apple.com/documentation/storekit/in-app_purchase/original_api_for_in-app_purchase/subscriptions_and_offers/reducing_involuntary_subscriber_churn
        ///
        case gradePeriodExpired = "GRACE_PERIOD_EXPIRED"
        
        /// `OFFER_REDEEMED`
        ///
        /// Subtype ile birlikte kullanıcının bir promosyon teklifini veya teklif kodunu kullandığını
        /// gösteren bir bildirim türü.
        ///
        /// Subtype `INITIAL_BUY` ise, kullanıcı teklifi ilk kez satın alma işlemi için kullandı.
        /// Subtype `RESUBSCRIBE` ise, kullanıcı etkin olmayan bir aboneliğe yeniden abone olmak
        /// için bir tekliften yararlanmıştır. Subtype `UPGRADE` ise, kullanıcı aktif aboneliğini
        /// yükseltmek için bir tekliften yararlandı ve bu teklif hemen yürürlüğe girdi. Subtype
        /// `DOWNGRADE` ise, kullanıcı bir sonraki yenileme tarihinde yürürlüğe girecek olan aktif
        /// aboneliğini eski sürüme geçirmek için bir tekliften yararlandı. Kullanıcı, aktif
        /// aboneliği için bir tekliften yararlandıysa, subtype olmayan bir `OFFER_REDEEMED`
        /// bildirim türü alırsınız.
        ///
        /// Olasi Subtype'lar:
        /// `INITIAL_BUY`, `RESUBSCRIBE`, `UPGRADE`, `DOWNGRADE`
        ///
        case offeredRedeemed = "OFFER_REDEEMED"
        
        /// `PRICE_INCREASE`
        ///
        /// Subtype ile birlikte, sistemin kullanıcıyı otomatik yenilenebilir bir abonelik fiyatı
        /// artışı hakkında bilgilendirdiğini gösteren bir bildirim türü.
        ///
        /// Fiyat artışı kullanıcı onayı gerektiriyorsa subtype, kullanıcı fiyat artışına yanıt
        /// vermemişse `PENDING`, kullanıcı fiyat artışına onay vermişse `ACCEPTED` şeklindedir.
        ///
        /// Fiyat artışı kullanıcı onayı gerektirmiyorsa subtype `ACCEPTED`.
        ///
        /// Subtype'lar:
        /// `ACCEPTED`, `PENDING`
        ///
        /// Abonelik fiyatlarını yönetme hakkında bilgi için
        ///     1 - Otomatik Yenilenebilir Abonelikler için Fiyat Artışlarını Yönetme:
        ///         https://developer.apple.com/documentation/storekit/product/subscriptioninfo/renewalinfo/managing_price_increases_for_auto-renewable_subscriptions
        ///     2 - Fiyatları Yönetme:
        ///         https://developer.apple.com/app-store/subscriptions/#managing-prices-for-existing-subscribers
        ///
        case priceIncrease = "PRICE_INCREASE"
        
        /// `REFUND`
        ///
        /// App Store'un tüketilebilir bir uygulama içi satın alma, tüketilemez bir uygulama içi satın alma,
        /// otomatik olarak yenilenebilen bir abonelik veya yenilenmeyen bir abonelik için bir işlemi
        /// başarıyla geri ödediğini gösteren bir bildirim türü.
        ///
        /// `revocationDate`, iade edilen işlemin zaman damgasını içerir. `originalTransactionId` ve `productId`,
        ///  orijinal işlemi ve ürünü tanımlar. `revocationReason`, nedeni içerir.
        ///
        /// Bir kullanıcı için geri ödemesi yapılan tüm işlemlerin bir listesini istemek için
        /// App Store Sunucu API'sinde Geri Ödeme Geçmişini Al bölümüne bakın:
        /// https://developer.apple.com/documentation/appstoreserverapi/get_refund_history
        ///
        case refund = "REFUND"
        
        /// `REFUND_DECLINED`
        ///
        /// App Store'un, uygulama geliştiricisi tarafından başlatılan bir geri ödeme talebini reddettiğini
        /// gösteren bir bildirim türü.
        ///
        case refundDeclined = "REFUND_DECLINED"
        
        /// `RENEWAL_EXTENDED`
        /// `RENEWAL_EXTENSION`
        ///
        /// App Store'un belirli bir abonelik için abonelik yenileme tarihini uzattığını belirten bir bildirim türü.
        ///     1 - Abonelik Yenileme Tarihini Uzat:
        ///         https://developer.apple.com/documentation/appstoreserverapi/extend_a_subscription_renewal_date
        ///     2 - Tüm Aktif Aboneler için Abonelik Yenileme Tarihlerini Uzat:
        ///         https://developer.apple.com/documentation/appstoreserverapi/extend_subscription_renewal_dates_for_all_active_subscribers
        ///
        case renewalExtended = "RENEWAL_EXTENDED"
        case renewalExtension = "RENEWAL_EXTENSION"
        
        /// `REVOKE`
        ///
        /// Kullanıcının Aile Paylaşımı yoluyla hak kazandığı bir uygulama içi satın alma işleminin artık paylaşım
        /// yoluyla kullanılamayacağını gösteren bir bildirim türü. App Store bu bildirimi, satın alan kişi
        /// bir ürün için Aile Paylaşımını devre dışı bıraktığında, satın alan kişi (veya aile üyesi) aile
        /// grubundan ayrıldığında veya satın alan kişi para iadesi isteyip aldığında gönderir.
        ///
        case revoke = "REVOKE"
        
        /// `SUBSCRIBED`
        ///
        /// Subtype ile birlikte kullanıcının bir ürüne abone olduğunu gösteren bir bildirim türü.
        /// Subtype `INITIAL_BUY` ise, kullanıcı ilk kez Aile Paylaşımı aracılığıyla abonelik satın
        /// aldı veya erişim elde etti. Subtype `RESUBSCRIBE` ise, kullanıcı yeniden abone oldu
        /// veya Aile Paylaşımı yoluyla aynı aboneliğe veya aynı abonelik grubu içindeki
        /// başka bir aboneliğe erişim aldı.
        ///
        /// Subtype'lar:
        /// `INITIAL_BUY`, `RESUBSCRIBE`
        ///
        case subscribed = "SUBSCRIBED"
        
        /// `TEST`
        ///
        /// "Request a Test Notification" uç noktasını çağırarak talep ettiğinizde App Store sunucusunun gönderdiği
        /// bir bildirim türü. Sunucunuzun bildirim alıp almadığını test etmek için bu uç noktayı arayın.
        /// Bu bildirimi yalnızca talebiniz üzerine alırsınız.
        /// Sorun giderme bilgileri için "Get Test Notification Status" bitiş noktasına bakın.
        ///
        /// 1 - Request a Test Notification:
        ///     https://developer.apple.com/documentation/appstoreserverapi/request_a_test_notification
        /// 2 - Get Test Notification Status
        ///     https://developer.apple.com/documentation/appstoreserverapi/get_test_notification_status
        ///
        case test = "TEST"
    }
}


