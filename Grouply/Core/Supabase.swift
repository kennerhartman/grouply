//
//  Supabase.swift
//  Grouply
//
//  Created by Kenner Hartman on 7/21/26.
//  Copyright © 2026 Kenner Hartman. All rights reserved.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as! String)!,
    supabaseKey: Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as! String,
    options: SupabaseClientOptions(
        auth: SupabaseClientOptions.AuthOptions(
            emitLocalSessionAsInitialSession: true
        )
    )
)
