//
//  AuthSessionState.swift
//  ClothesShop
//
//  Created by Alex on 29.09.2026.
//


enum AuthSessionState: Equatable {
    case signedOut
    case awaitingEmailVerification(String)
    case verified
}