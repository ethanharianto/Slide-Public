//
//  OTPTextField.swift
//  Slide
//
//  Created by Ethan Harianto on 9/10/23.
//

import Combine
import SwiftUI

struct OTPTextField: View {
    // MARK: - > PROPERTIES
    
    enum FocusPin {
        case pinOne, pinTwo, pinThree, pinFour, pinFive, pinSix
    }
    
    @FocusState private var pinFocusState: FocusPin?
    @Binding var pin: [String]
    @State private var pinOne: String = ""
    @State private var pinTwo: String = ""
    @State private var pinThree: String = ""
    @State private var pinFour: String = ""
    @State private var pinFive: String = ""
    @State private var pinSix: String = ""
    
    // MARK: - > BODY

    var body: some View {
        VStack {
            HStack {
                TextField("", text: $pinOne)
                    .modifier(OtpModifer(pin: $pinOne))
                    .onChange(of: pinOne) { newVal in
                        if newVal.count == 1 {
                            pin[0] = newVal
                            pinFocusState = .pinTwo
                            print(pin.joined())
                        }
                    }
                    .focused($pinFocusState, equals: .pinOne)
                    
                TextField("", text: $pinTwo)
                    .modifier(OtpModifer(pin: $pinTwo))
                    .onChange(of: pinTwo) { newVal in
                        if newVal.count == 1 {
                            pin[1] = newVal
                            pinFocusState = .pinThree
                            print(pin.joined())
                        } else {
                            if newVal.count == 0 {
                                pinFocusState = .pinOne
                            }
                        }
                    }
                    .focused($pinFocusState, equals: .pinTwo)

                TextField("", text: $pinThree)
                    .modifier(OtpModifer(pin: $pinThree))
                    .onChange(of: pinThree) { newVal in
                        if newVal.count == 1 {
                            pin[2] = newVal
                            pinFocusState = .pinFour
                            print(pin.joined())
                        } else {
                            if newVal.count == 0 {
                                pinFocusState = .pinTwo
                            }
                        }
                    }
                    .focused($pinFocusState, equals: .pinThree)

                TextField("", text: $pinFour)
                    .modifier(OtpModifer(pin: $pinFour))
                    .onChange(of: pinFour) { newVal in
                        if newVal.count == 1 {
                            pin[3] = newVal
                            pinFocusState = .pinFive
                            print(pin.joined())
                        } else {
                            pinFocusState = .pinThree
                        }
                    }
                    .focused($pinFocusState, equals: .pinFour)
                
                TextField("", text: $pinFive)
                    .modifier(OtpModifer(pin: $pinFive))
                    .onChange(of: pinFive) { newVal in
                        if newVal.count == 1 {
                            pin[4] = newVal
                            pinFocusState = .pinSix
                            print(pin.joined())
                        } else {
                            pinFocusState = .pinFour
                        }
                    }
                    .focused($pinFocusState, equals: .pinFive)
                
                TextField("", text: $pinSix)
                    .modifier(OtpModifer(pin: $pinSix))
                    .onChange(of: pinSix) { newVal in
                        if newVal.count == 1 {
                            pin[5] = newVal
                            print(pin.joined())
                        }
                        if newVal.count == 0 {
                            pinFocusState = .pinFive
                        }
                    }
                    .focused($pinFocusState, equals: .pinSix)

            }
            .padding()
        }
    }
}

struct OtpFormFieldView_Previews: PreviewProvider {
    static var previews: some View {
        OTPTextField(pin: .constant(Array(repeating: " ", count: 6)))
    }
}
