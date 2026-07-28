// ──────────────────────────────────────────────
// AvatarView.swift — Componente Reutilizable de Avatar
// ──────────────────────────────────────────────
// Dibuja el avatar con su respectivo gradiente de fondo y emoji.

import SwiftUI

struct AvatarView: View {
    let avatarString: String?
    let size: CGFloat
    
    var body: some View {
        let (option, bgGradient) = AvatarSystem.parseAvatar(avatarString)
        
        ZStack {
            Circle()
                .fill(bgGradient.gradient)
                .shadow(color: bgGradient.colors[0].opacity(0.15), radius: size * 0.1, x: 0, y: size * 0.05)
            
            Text(option.emoji)
                .font(.system(size: size * 0.52))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack {
        AvatarView(avatarString: "owl:0", size: 80)
        AvatarView(avatarString: "fox:1", size: 80)
        AvatarView(avatarString: "cat:2", size: 80)
    }
    .padding()
}
