//
//  SignInView.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import SwiftUI

import Supabase

struct SignInView: View {
    @Environment(AppState.self) private var appState
    
    @State private var model: SignInViewModel = .init()
    
    var body: some View {
        NavigationStack {
            Text("Grouply")
                .fontWeight(.bold)
                .font(.largeTitle)
                .padding(48)
            
            Spacer()
            
            TextField("Email", text: self.$model.email)
                .textFieldStyle(SignInTextFieldStyle())
            
            TextField("Password", text: self.$model.password)
                .textFieldStyle(SignInTextFieldStyle())
            
            HStack {
                Text("Don't have an account?")
                
                NavigationLink(destination: SignUpView()) {
                    Text("Create one.")
                }
            }
            .padding(.bottom)
            
            GlassButton(title: "Sign In", tint: .accentColor) {
                if (self.model.validate()) {
                    Task {
                        self.appState.session = await self.model.signIn()
                    }
                }
            }
            
            Spacer()
        }
    }
}

fileprivate class SignInViewModel {
    var email: String = ""
    var password: String = ""
    
    // TODO: DISPLAY A PROPER MESSAGE IN THE UI TO ALERT USER OF FAILURE TO SIGN IN
    func validate() -> Bool {
        if (self.email.isEmpty || self.password.isEmpty || !self.isValidEmail()) {
            return false
        }
        
        return true
    }
    
    private func isValidEmail() -> Bool {
        return self.email.contains("@")
    }
    
    func signIn() async -> Session? {
        do {
            return try await supabase.auth.signIn(
                email: self.email,
                password: self.password
            )
        } catch {
            print("Failed to sign user in: \(error)")
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
    SignInView()
        .environment(AppState())
}
