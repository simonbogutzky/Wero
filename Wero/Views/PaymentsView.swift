//
//  PaymentsView.swift
//  Wero
//
//  Copyright © 2025 Bogutzky. All rights reserved.
//

import SwiftUI

struct PaymentsView: View {
    // MARK: - Properties

    @Binding var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("Person-to-Person") {
                    NavigationLink(destination: P2PPaymentView(appState: $appState)) {
                        Label("Geld an Kontakt senden", systemImage: "person.2.fill")
                    }
                }

                Section("Händler-Zahlungen") {
                    NavigationLink(destination: MerchantPaymentView(appState: $appState, paymentType: .merchantContactless)) {
                        Label("Kontaktlos zahlen", systemImage: "wave.3.right")
                    }

                    NavigationLink(destination: MerchantPaymentView(appState: $appState, paymentType: .merchantQRCode)) {
                        Label("QR-Code scannen", systemImage: "qrcode.viewfinder")
                    }

                    NavigationLink(destination: MerchantPaymentView(appState: $appState, paymentType: .merchantOnline)) {
                        Label("Online bezahlen", systemImage: "cart.fill")
                    }
                }
            }
            .navigationTitle("Zahlen")
        }
    }
}
