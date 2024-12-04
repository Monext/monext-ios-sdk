//
//  ContentView.swift
//  iOS Example
//
//  Created by My Lucky Day on Nov 7, 2024.
//

import SwiftUI
import Monext
import PassKit

enum Theme: String, CaseIterable, Identifiable {
    
    case `default` = "Default"
    case dark = "Dark"
    
    var id: Self { self }
}

struct ContentScreen: View {
    
    enum EnvOption: String, CaseIterable, Identifiable {
        case sandbox
        case production
        case custom

        var id: String { self.rawValue }
    }
    
    @State var selectedTheme: Theme = .default
    @State private var selectedOption: EnvOption
    @State private var customHostname: String

    // Clés pour UserDefaults
    private let selectedEnvKey = "selectedEnvironment"
    private let customHostnameKey = "customHostname"
    
    // Initializer pour charger les valeurs sauvegardées
    init() {
        // Charger l'environnement sauvegardé
        let savedEnv = UserDefaults.standard.string(forKey: selectedEnvKey) ?? EnvOption.sandbox.rawValue
        self._selectedOption = State(initialValue: EnvOption(rawValue: savedEnv) ?? .sandbox)
        
        // Charger le hostname personnalisé
        let savedHostname = UserDefaults.standard.string(forKey: customHostnameKey) ?? ""
        self._customHostname = State(initialValue: savedHostname)
    }

    var selectedEnv: MnxtEnvironment {
        switch selectedOption {
        case .sandbox:
            return .sandbox
        case .production:
            return .production
        case .custom:
            return .custom(hostname: customHostname)
        }
    }
    
    @State var sessionToken: String?
    @State var creatingSession: Bool = false
    @State var presentingPaymentScreen: Bool = false
    
    var appearance: Appearance {
        switch selectedTheme {
        case .default:
            return ExampleApp.sampleDefaultTheme
        case .dark:
            return ExampleApp.sampleDarkTheme
        }
    }
    
    @State private var pmsSelection = Set<String>()
    @State private var isEditMode: EditMode = .active
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Form {
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(Theme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                
                Picker("Environment", selection: $selectedOption) {
                    Text("Sandbox").tag(EnvOption.sandbox)
                    Text("Production").tag(EnvOption.production)
                    Text("Custom").tag(EnvOption.custom)
                }
                .onChange(of: selectedOption) { newValue in
                    // Sauvegarder l'environnement sélectionné
                    UserDefaults.standard.set(newValue.rawValue, forKey: selectedEnvKey)
                    sessionToken = nil
                }
                
                if selectedOption == .custom {
                    HStack {
                        Text("Hostname:")
                        TextField("Enter Hostname", text: $customHostname)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: customHostname) { newValue in
                                // Sauvegarder le hostname personnalisé
                                UserDefaults.standard.set(newValue, forKey: customHostnameKey)
                            }
                    }
                }
                
                if !customHostname.isEmpty || selectedOption != .custom {
                    HStack {
                        Text("Token:")
                        TextField("", text: Binding(
                            get: { self.sessionToken ?? "" },
                            set: {
                                if($0.isEmpty) {
                                    self.sessionToken  = nil
                                } else {
                                    self.sessionToken  = $0
                                }
                            }
                        ))
                    }
                }
                
                if sessionToken != nil {
                    Button {
                        sessionToken = nil
                    } label: {
                        Text("RESET SESSION")
                            .frame(maxWidth: .infinity)
                    }
                    
                    PaymentButton(
                        sessionToken: sessionToken,
                        context: MnxtSDKContext(
                            environment: selectedEnv,
                            config: .init(
                                language: "IT"
                            ),
                            appearance: appearance)
                    ) {
                        Text("CHECKOUT")
                            .frame(maxWidth: .infinity)
                    } onResult: { result in
                        switch result {
                        case .tokenExpired:
                            print("tokenExpired")
                            self.sessionToken = nil
                        case .paymentPending:
                            print("paymentPending")
                        case .paymentSuccess:
                            print("paymentSuccess")
                        case .paymentFailure:
                            print("paymentFailure")
                        case .paymentCanceled:
                            print("paymentCanceled")
                        }
                    }
                    .padding(8)
                    .disabled(presentingPaymentScreen)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
