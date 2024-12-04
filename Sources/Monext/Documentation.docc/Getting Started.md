# Getting Started

Quickly add payments to your app.

## Overview

The SDK aims to be as straightforward and easy-to-use as possible. It provides a drop-in SwiftUI view that can be added to your existing UI.

*Minimum Requirements:*
* iOS 16.0

## Installation

Monext iOS is available for installation via [Swift Package Manager](https://www.swift.org/documentation/package-manager/)

### Swift Package Manager

1. Follow Apple's [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) guide on how to add a Swift Package dependency.
1. Use [https://monext.fr](<link needed>) as the repository URL.
1. Specify the version to be at least 1.0.0.

## Usage

### Overview

Use of the Monext iOS SDK requires a Monext account. See the [website](https://monext.fr) for details.
Once you have your merchant account and have installed the SDK (see *"Installation"* above), you are ready to start integrating.

### Design your UI

The Monext iOS SDK is designed for SwiftUI (to integrate with UIKit, have a look at Apple's documentation on [UIHostingController](https://developer.apple.com/documentation/swiftui/uihostingcontroller)).
The main way of adding the SDK to your app is via the ``PaymentButton``, an easy-to-use SwiftUI view that allows you to wrap your custom content in a payment action:

```swift
import Monext

struct ExampleView {

    // ...

    var body: some View {

        VStack {

            // ...

            if let sessionToken {
                
                PaymentButton(
                    sessionToken: sessionToken,
                    configuration: paymentSheetConfiguration
                ) {

                    Text("CHECKOUT")

                } onResult: { result in
                    switch result {
                    case .tokenExpired:
                        print("tokenExpired")
                    case .paymentSuccess:
                        print("paymentSuccess")
                    case .paymentFailure:
                        print("paymentFailure")
                    case .paymentCanceled:
                        print("paymentCanceled")
                    }
                }
            }
        }
    }
}
```

The `sessionToken` and `paymentSheetConfiguration` parameters will be discussed in the following sections.

The ``PaymentButton`` is an all-in-one solution that manages the UI for the entire payment session. 
In the event that you need a more customized UI than the ``PaymentButton`` provides, you can use the ``SwiftUICore/View/presentPaymentSheet(isPresented:sessionToken:paymentSheetConfiguration:applePayConfiguration:onResult:)`` view modifier directly on your UI element(s):

```swift
import Monext

@State var isPresented: Bool = false

public var body: some View {

    Button(action: { isPresented.toggle() }) {
        <Your custom content>
    }
    .presentPaymentSheet(
        isPresented: $isPresented,
        sessionToken: sessionToken,
        paymentSheetConfiguration: configuration,
        applePayConfiguration: applePayConfiguration,
        onResult: onResult
    )
}
```

### Making a payment

**Step 1: Create a Monext payment session token**

Before your customers can make a payment your app must create a session via the Monext Retail API.
Refer to the [documentation](https://api-docs.retail.monext.com/reference/sessioncreate) on how to create a session and obtain the resulting session token.

**Step 2a: Provide the required parameters to the ``PaymentButton``**

Once the session has been created, you can show the ``PaymentButton`` in your UI. The ``PaymentButton`` requires the session token and a ``PaymentSheetConfiguration`` object. 
``PaymentSheetConfiguration`` is used to customize the UI of the payment sheet presented by the ``PaymentButton``, see <doc:Getting-Started#UI-Customization> below for details.

You must also supply the button's `content` parameter and the `onResult` closure. 

**Step 2b: Provide optional parameters**

If your app supports **Apple Pay**, you can provide an ``ApplePayConfiguration`` object to allow your customer the option of using **Apple Pay**. 
See the following <doc:Getting-Started#Apple-Pay> section for more details

**Step 3: Result**

When the payment session has terminated the `onResult` handler will be called with the resulting ``PaymentResult``. The payment sheet is automatically dismissed.

### UI Customization

The payment sheet exposes many UI customizations through the ``PaymentSheetConfiguration`` class. The design is extensively documented [here](<FIGMA link>).

You are not required to customize all possible UI elements (the class defaults to a black-and-white theme), but at a minimum it is recommended to set the ``PaymentSheetConfiguration/headerTitle`` to match your app's branding.

### Supporting Apple Pay

Monext iOS SDK supports Apple Pay via the PassKit framework but requires extra configuration in order to work in your app. 

For complete instructions on setting up Apple Pay, refer to the [official documentation](https://developer.apple.com/documentation/passkit/setting-up-apple-pay).

Briefly, the steps you must follow are:

**1. Create your merchant identifier.** 

This is a unique ID that you register with Apple directly on their developer site.

**2. Create a payment processing certificate.**

Once you have created your merchant ID you will have the option of creating a payment processing certificate via a Certificate Signing Request. See the above Apple documentation for details.

When you have created the payment certificate you must send it to Monext. Details can be found [here](https://docs.monext.fr/pages/viewpage.action?pageId=753079803#ApplePayCréationdesélémentssurMonextOnlineetApplePay-CommentutiliserlecertificatCommerçant(option1)).

**3. Enable Apple Pay capability in Xcode.**

The Apple Pay capability must be added to your Xcode configuration under the Signing & Capabilities tab. Once added, you need to enter your merchant ID.

**4. Provide ``ApplePayConfiguration`` to the SDK**

Now you can enable Apple Pay in the Monext SDK with the ``ApplePayConfiguration`` class. 

When an ``ApplePayConfiguration`` object is provided to the SDK it will attempt to display the `PayWithApplePay` button.

The user must have Apple Pay configured on a supported device and the merchant ID added to the Apple Pay capability must match the merchantID that you provided to Monext.

