//  PhoneNumberView.swift
//  Slide
//  Created by Ethan Harianto on 9/9/23.

import iPhoneNumberField
import SwiftUI

struct PhoneNumberView: View {
    @StateObject var viewModel = PasswordViewModel()
    @State private var loading = false
    @State private var number = true
    @State private var pin = ["", "", "", "", "", ""]
    @State private var isLoading: Bool = false

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                if number {
                    Text("Your phone number helps us find your friends on Slide!")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)

                    iPhoneNumberField("(000) 000-0000", text: $viewModel.phoneNumber)
                        .formatted()
                        .maximumDigits(10)
                        .checkMarkTextField()
                        .bubbleStyle(color: .primary)
                        .padding()

                    Button(action: {
                        withAnimation {
                            viewModel.sendCode()
                        }
                        number.toggle()
                        loading.toggle()
                    }, label: {
                        Text("Send OTP")
                            .filledBubble()
                    }).padding(.horizontal)
                }
            }

            if loading {
                ProgressView()
            }

            if viewModel.verifying {
                VStack {
                    Text("Enter the 6 digit code we texted \(Text(viewModel.phoneNumber))")
                        .foregroundColor(.secondary)

                    OTPTextField(pin: $pin)

                    Button(action: {
                        viewModel.sendCode()
                    }, label: {
                        Text("Resend OTP")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    })

                    Button(action: {
                        if !pin.joined().isEmpty {
                            viewModel.verifyCode(code: pin.joined())
                        }
                    }, label: {
                        Text("Verify")
                            .filledBubble()
                    })
                    .padding()
                    .disabled(viewModel.loadingVerify)
                }
                .opacity(viewModel.verifying ? 1 : 0)
                .onAppear {
                    loading.toggle()
                }
            }
        }
        .alert(isPresented: $viewModel.error, content: {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage))
        })
    }
}

struct PhoneNumberView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneNumberView()
    }
}
