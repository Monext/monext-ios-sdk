//
//  AlternativePaymentMethodForm.swift
//  Monext
//
//  Created by SDK Mobile on 16/04/2025.
//
import SwiftUI

struct AlternativePaymentMethodForm: View {
    
    @Binding var saveCard: Bool
    @Binding var formValid: Bool
    @Binding var formData: [String: String]
    
    var method: PaymentMethodData!
    
    @EnvironmentObject
    var sessionStore: SessionStateStore
    
    private var appearance: Appearance {
        sessionStore.appearance
    }

    @State private var fieldValues: [String: String] = [:]
    @State private var touchedFields: Set<String> = []
    @FocusState private var focusedField: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if method.hasForm == true, let form = method.form {
                
                switch form.formType {
                case "CUSTOM":
                    if let fields = form.formFields {
                        ForEach(fields, id: \.id) { field in
                            makeFieldView(for: field)
                        }
                    }
                default:
                    EmptyView()
                }
            }
            
            if let options = method.options, options.contains("SAVE_PAYMENT_DATA") {
                ToggleButton(
                    "I want to save my payment information for later.",
                    isOn: $saveCard
                )
            }
        }
        .padding()
        .onChange(of: fieldValues) { _ in
            validateForm()
            formData = getFormDataWithKeys()
        }
        .onAppear {
            let prefilled = getPreFilledFieldValues()
            fieldValues = prefilled
            validateForm()
            formData = getFormDataWithKeys()
        }
    }
    
    @ViewBuilder
    private func makeFieldView(for field: PaymentMethodFormField) -> some View {
        switch field.formFieldType {
        case "DISPLAY":
            Text(field.content ?? "")
                .font(appearance.fonts.bold16)
                .multilineTextAlignment(.leading)
                .foregroundStyle(appearance.onBackgroundColor)
                .lineLimit(2, reservesSpace: true)
        case "INPUT":
            FormFieldView(
                label: LocalizedStringKey(field.label ?? ""),
                textValue: Binding(
                    get: { fieldValues[field.id] ?? "" },
                    set: {
                        fieldValues[field.id] = $0
                        if !$0.isEmpty || $0 == "" {
                            touchedFields.insert(field.id)
                        }
                    }
                ),
                errorMessage: getErrorMessage(for: field),
                formatter: getFormatter(for: field),
                keyboardType: getKeyboardType(for: field),
                focusedState: $focusedField,
                focusedField: field.id,
                placeholder: field.placeholder
            )
            .padding(.vertical, 8)
        default:
            EmptyView()
        }
    }
    
    // MARK: - Helper Methods
    
    private func getPreFilledFieldValues() -> [String: String] {
        guard let form = method.form, let fields = form.formFields else {
            return [:]
        }
        var result: [String: String] = [:]
        for field in fields {
            if field.formFieldType == "INPUT" {
                if field.inputType == "TEL",
                    let phone = sessionStore.sessionState?.info?.buyerMobilePhone, !phone.isEmpty {
                    if let pattern = field.validation?.pattern {
                        let formatter = RegexFormatter(pattern: pattern)
                        if formatter.isValid(phone) {
                            result[field.id] = phone
                            touchedFields.insert(field.id)
                        }
                    } else {
                        result[field.id] = phone
                        touchedFields.insert(field.id)
                    }
                }
            }
        }
        return result
    }
    
    private func getFormatter(for field: PaymentMethodFormField) -> (any FormFieldView<String>.Formatter)? {
        guard let pattern = field.validation?.pattern else {
            return nil
        }
        return RegexFormatter(pattern: pattern)
    }
    
    private func getKeyboardType(for field: PaymentMethodFormField) -> UIKeyboardType {
        // Détection automatique du type de clavier basé sur le pattern
        guard let validation = field.validation,
              let pattern = validation.pattern else {
            return .default
        }
        
        // Si le pattern contient des emails
        if pattern.contains("@") {
            return .emailAddress
        }
        
        // Si le pattern ne contient que des chiffres
        if pattern.range(of: "\\d", options: .regularExpression) != nil &&
           pattern.range(of: "[A-Za-z]", options: .regularExpression) == nil {
            return .numberPad
        }
        
        return .default
    }
    
    private func getErrorMessage(for field: PaymentMethodFormField) -> LocalizedStringKey? {
        let fieldId = field.id
        let currentValue = fieldValues[fieldId] ?? ""

        // Ne pas afficher d'erreurs si le champ n'a pas été touché
        guard touchedFields.contains(fieldId) else {
            return nil
        }

        // Ne pas afficher d'erreur tant que le champ est vide
        if currentValue.isEmpty {
            return nil
        }

        // Vérifier la validation si le champ n'est pas vide et qu'il y a une validation
        if let pattern = field.validation?.pattern {
            let formatter = RegexFormatter(pattern: pattern)
            if !formatter.isValid(currentValue) {
                return LocalizedStringKey(field.validationErrorMessage ?? "Format invalide")
            }
        }

        return nil
    }
    
    private func getFormDataWithKeys() -> [String: String] {
       guard let form = method.form, let fields = form.formFields else {
           return [:]
       }
       
       var result: [String: String] = [:]
       
       for field in fields.filter({ $0.formFieldType == "INPUT" }) {
           let fieldId = field.id
           let fieldKey = field.key ?? fieldId // Utiliser 'key' si disponible, sinon 'id'
           
           if let value = fieldValues[fieldId], !value.isEmpty {
               result[fieldKey] = value
           }
       }
       
       return result
   }
    
    // MARK: - Form Validation
    
    private func validateForm() {
        guard let form = method.form,
              let fields = form.formFields else {
            formValid = true
            return
        }
        
        // Récupérer seulement les champs INPUT
        let inputFields = fields.filter { $0.formFieldType == "INPUT" }
        
        for field in inputFields {
            let fieldId = field.id
            let currentValue = fieldValues[fieldId] ?? ""
            
            // Vérifier si un champ requis est vide
            if field.required == true && currentValue.isEmpty {
                formValid = false
                return
            }
            
            // Vérifier la validation pour les champs non vides avec validation
            if !currentValue.isEmpty, let pattern = field.validation?.pattern {
                let formatter = RegexFormatter(pattern: pattern)
                if !formatter.isValid(currentValue) {
                    formValid = false
                    return
                }
            }
        }
        
        // Si on arrive ici, tous les champs sont valides
        formValid = true
    }
}
