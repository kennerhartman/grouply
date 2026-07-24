//
//  SignInView.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI

import Supabase

struct SignUpView: View {
    @Environment(AppState.self) private var appState
    
    @State private var model: SignInViewModel = .init()
    
    var body: some View {
        VStack {
            Text("Grouply")
                .fontWeight(.bold)
                .font(.largeTitle)
                .padding(48)
            
            Spacer()
            
            HStack {
                TextField("First Name", text: self.$model.firstName)
                    .textFieldStyle(SignInTextFieldStyle())
                
                TextField("Last Name", text: self.$model.lastName)
                    .textFieldStyle(SignInTextFieldStyle())
            }
            
            TextField("Email", text: self.$model.email)
                .textFieldStyle(SignInTextFieldStyle())
            
            TextField("Password", text: self.$model.password)
                .textFieldStyle(SignInTextFieldStyle())
            
            GlassButton(title: "Sign Up", tint: .accentColor) {
                if (self.model.validate()) {
                    Task {
                        self.appState.session = await self.model.signUp()
                    }
                }
            }
            .buttonStyle(.glassProminent)
            
            Spacer()
        }
    }
}

fileprivate class SignInViewModel {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    
    // TODO: DISPLAY A PROPER MESSAGE IN THE UI TO ALERT USER OF FAILURE TO SIGN UP
    func validate() -> Bool {
        if (
            self.firstName.isEmpty ||
            self.lastName.isEmpty ||
            self.email.isEmpty ||
            self.password.isEmpty ||
            !self.isValidEmail()
        ) {
            return false
        }
        
        return true
    }
    
    private func isValidEmail() -> Bool {
        return self.email.contains("@")
    }
    
    func signUp() async -> Session? {
        do {
            let response: AuthResponse = try await supabase.auth.signUp(
                email: self.email,
                password: self.password,
                data: [
                    "first_name": .string(self.firstName),
                    "last_name": .string(self.lastName)
                ]
            )
            
            try await supabase
                .from("profiles")
                .insert([
                    "id": response.user.id.uuidString,
                    "first_name": self.firstName,
                    "last_name": self.lastName,
                ])
                .execute()
            
            return response.session
        } catch {
            print("Failed to sign user up: \(error)")
        }
        
        return nil
    }
}

fileprivate struct SignInTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack {
            configuration
            
            Divider()
        }
        .padding()
    }
}

#Preview {
    SignUpView()
        .environment(AppState())
}
