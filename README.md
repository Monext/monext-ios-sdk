[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=Monext_monext-ios-sdk&metric=alert_status&token=cf99b461985afddc96c299860f946c2570b93031)](https://sonarcloud.io/summary/new_code?id=Monext_monext-ios-sdk)

# Monext iOS SDK – Getting Started

Quickly integrate payments into your app with our easy-to-use SDK.


## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
- [Security Best Practices](#security-best-practices)
- [Usage](#usage)
    - [Integrating `PaymentButton`](#integrating-paymentbutton)
    - [Using `presentPaymentSheet` for Custom UI](#using-presentpaymentsheet-for-custom-ui)
- [Payment Process](#payment-process)
- [UI Customization](#ui-customization)
- [Apple Pay Integration](#apple-pay-integration)
## Overview

The Monext iOS SDK is designed for seamless integration of payment features. It provides a drop-in SwiftUI view that can be easily embedded into your existing UI.

![EN](https://github.com/user-attachments/assets/abb278fd-c8c4-4ec1-a29a-c4fc9cae980d)


**Minimum Requirement:**
- iOS 16.0

Before using the SDK, ensure you have an active Monext merchant account. Visit our [website](https://monext.fr) for details.
## Installation

Monext iOS SDK is available via [Swift Package Manager](https://www.swift.org/documentation/package-manager/).

### Swift Package Manager

1. **Add the Package Dependency:**  
   Follow Apple’s guide on [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

2. **Enter the Repository URL:**
   ```
   TODO
   ```  
   *(Ensure you replace this with the correct repository URL if needed.)*

3. **Specify the Version:**  
   Use version `1.0.0` or later.

## Security Best Practices

⚠️ **Important:** API calls to Monext **must** be made from your backend server—not directly from your mobile application. This protects sensitive credentials such as:

- **BasicToken**
- **MerchantID**

Never expose these credentials in your app’s code.


## Usage

Once the SDK is installed and your Monext account is set up, you can integrate payment functionality into your app.

### Integrating `PaymentButton`

The main component is `PaymentButton`, a ready-to-use SwiftUI view that manages the entire payment process. It integrates the presentPaymentSheet call:

```swift
import Monext

struct ExampleView: View {
    var sessionToken: String?
    var paymentSheetConfiguration: PaymentSheetConfiguration

    var body: some View {
        VStack {
            if let sessionToken = sessionToken {
                PaymentButton(
                    sessionToken: sessionToken,
                    configuration: paymentSheetConfiguration
                ) {
                    Text("CHECKOUT")
                } onResult: { result in
                    switch result {
                    case .tokenExpired:
                        print("Token expired")
                    case .paymentPending:
                        print("Payment is pending...")
                    case .paymentSuccess:
                        print("Payment successful")
                    case .paymentFailure:
                        print("Payment failed")
                    case .paymentCanceled:
                        print("Payment canceled")
                    }
                }
            }
        }
    }
}
```

### Using `presentPaymentSheet` for Custom UI

For greater control over the user interface, use the `presentPaymentSheet`  view modifier directly:

```swift
import Monext

struct CustomPaymentView: View {
    @State var isPresented: Bool = false
    var sessionToken: String
    var configuration: PaymentSheetConfiguration
    var applePayConfiguration: ApplePayConfiguration
    var onResult: (PaymentResult) -> Void

    var body: some View {
        Button(action: { isPresented.toggle() }) {
            Text("Pay")
        }
        .presentPaymentSheet(
            isPresented: $isPresented,
            sessionToken: sessionToken,
            paymentSheetConfiguration: configuration,
            applePayConfiguration: applePayConfiguration,
            onResult: onResult
        )
    }
}
```


## Payment Process

1. **Create a Monext Payment Session Token:**  
   Your backend must create a payment session via the Monext Retail API. Refer to the [session creation documentation](https://api-docs.retail.monext.com/reference/sessioncreate).

2. **Pass the Required Parameters to `PaymentButton`:**
    - `sessionToken`
    - `PaymentSheetConfiguration` for UI customization  
      *(See [UI Customization](#ui-customization))*
    - Button content and `onResult` closure to handle payment outcomes

3. **Handle Payment Results:**  
   The `onResult` closure receives a `PaymentResult` when the payment session ends. The payment sheet dismisses automatically.

4. **Get a session detail**
   You can then retrieve the payment data via an API call with a GET Session, for more information: [Documentation](https://api-docs.retail.monext.com/reference/sessionget).

## UI Customization

Customize the payment sheet using `PaymentSheetConfiguration`. Modify colors, texts, and themes to match your branding.

All available UI customizations are contained in this class. You are not required to modify any element, the default is a light theme.
It is recommended to provide the `headerTitle` or `headerImage` at a minimum to identify your brand.


## Apple Pay Integration

Monext iOS SDK supports Apple Pay via the PassKit framework. Setup requires:

1. **Register a Merchant ID:**  
   Create one on the [Apple Developer portal](https://developer.apple.com).

2. **Generate a Payment Processing Certificate:**  
   Follow Apple’s [instructions](https://developer.apple.com/documentation/passkit/setting-up-apple-pay) to generate a CSR.

3. **Submit the Certificate to Monext:**  
   Follow [these steps](https://docs.monext.fr/pages/viewpage.action?pageId=753079803#ApplePayCréationdesélémentssurMonextOnlineetApplePay-CommentutiliserlecertificatCommerçant(option1)).

4. **Enable Apple Pay in Xcode:**  
   Add the Apple Pay capability in **Signing & Capabilities** and enter your merchant ID.

5. **Customize Apple Pay Button:**  
   Use `ApplePayConfiguration` to customize the appearance of the Apple Pay button. You can modify its label and style:

   ```swift
   public struct ApplePayConfiguration {
       let buttonLabel: PayWithApplePayButtonLabel
       let buttonStyle: PayWithApplePayButtonStyle

       public init(buttonLabel: PayWithApplePayButtonLabel = .plain, buttonStyle: PayWithApplePayButtonStyle = .black) {
           self.buttonLabel = buttonLabel
           self.buttonStyle = buttonStyle
       }
   }
   ```
   See [Apple's official documentation](https://developer.apple.com/documentation/passkit/paywithapplepaybuttonlabel) for available options.

