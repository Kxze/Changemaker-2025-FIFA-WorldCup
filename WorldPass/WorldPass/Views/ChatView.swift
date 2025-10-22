//
//  ChatView.swift
//  WorldPass
//
//  Created by Pau Pau on 21/10/25.
//

//
//  ChatbotFlowView.swift
//

import SwiftUI
import Foundation

//
enum GeminiError: LocalizedError {
    case missingAPIKey
    case httpError(Int, String)
    case decoding
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Falta la API Key (revisa Info.plist → GEMINI_API_KEY)."
        case .httpError(let code, let body):
            return "Error HTTP \(code): \(body)"
        case .decoding:
            return "No se pudo decodificar la respuesta."
        case .emptyResponse:
            return "La IA no devolvió contenido."
        }
    }
}

struct GeminiRequest: Encodable {
    let contents: [GeminiContent]
}
struct GeminiContent: Encodable {
    let role: String
    let parts: [GeminiPart]
}
struct GeminiPart: Encodable {
    let text: String
}

struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]?
    let promptFeedback: GeminiPromptFeedback?
}
struct GeminiCandidate: Decodable {
    let content: GeminiContentResponse?
    let finishReason: String?
}
struct GeminiContentResponse: Decodable {
    let parts: [GeminiPartResponse]?
}
struct GeminiPartResponse: Decodable {
    let text: String?
}
struct GeminiPromptFeedback: Decodable {
    let safetyRatings: [GeminiSafety]?
}
struct GeminiSafety: Decodable {
    let category: String?
    let probability: String?
}

struct GeminiClient {
    // modelo de gemini
    let model: String = "gemini-2.5-flash"

    private func resolveAPIKey() -> String? {
        if let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String {
            let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // Solo para previews
            return "AIzaSyAlEHW76I6ARzb3-qaZOgJMWhZMlcf9_Vo"
        }
        #endif
        return nil
    }

    func generate(_ userText: String) async throws -> String {
        guard let apiKey = resolveAPIKey(), !apiKey.isEmpty else {
            throw GeminiError.missingAPIKey
        }

        var comps = URLComponents(
            string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent"
        )!
        comps.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        let url = comps.url!

        let payload = GeminiRequest(
            contents: [GeminiContent(role: "user", parts: [GeminiPart(text: userText)])]
        )

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw GeminiError.httpError(-1, "Respuesta no HTTP")
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<sin cuerpo>"
            throw GeminiError.httpError(http.statusCode, body)
        }

        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        if let text = decoded.candidates?
            .compactMap({ $0.content?.parts?.compactMap(\.text).joined(separator: "") })
            .first, !text.isEmpty {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            throw GeminiError.emptyResponse
        }
    }
}

// =============================================================


extension Font {
    static func fwcTitle(_ size: CGFloat) -> Font {
        .custom("FWC2026-NormalBlack", size: size)
    }
    static func fwcText(_ size: CGFloat) -> Font {
        .custom("FWC2026-NormalRegular", size: size)
    }
}

private extension Color {
    static let bubbleBot    = Color(red: 0.90, green: 0.97, blue: 0.92) // verde claro
    static let bubbleUser   = Color(red: 0.95, green: 0.96, blue: 0.97) // gris claro
    static let bubbleStroke = Color.white.opacity(0.7)
}



struct ChatbotFlowView: View {
    var body: some View {
        NavigationStack {
            ZayuIntroView()
                .navigationBarHidden(true)
        }
        // Si quieres tipografía global por defecto:
        .environment(\.font, .custom("FWC2026-NormalRegular", size: 16))
    }
}

//

struct ZayuIntroView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("FondoVerde")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        // Botón atrás opcional (si llegas aquí desde otro punto)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.95))
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 1))
                            .opacity(0) // oculto en la intro (solo decorativo como en el mock)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    Spacer(minLength: 8)
                    
                    // Título
                    Text("¡HOLA,\nSOY ZAYU!")
                        .multilineTextAlignment(.center)
                        .font(.fwcTitle(44))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        .padding(.bottom, 8)
                    
                    // Personaje
                    Image("Zayu")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 260)
                        .padding(.vertical, 6)
                    
                    Spacer()
                    
                    // Subtítulo
                    Text("¿Cómo puedo ayudarte?")
                        .font(.fwcText(18))
                        .foregroundStyle(.white.opacity(0.95))
                        .padding(.bottom, 8)
                    
                    // Botón Comenzar → navega al chat
                    NavigationLink {
                        IAPrediccionesView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Text("Comenzar")
                            .font(.fwcTitle(17))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
                            )
                    }
                    .padding(.bottom, 28)
                }
            }
        }
    }
}

// =============================================================

// =============================================================

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var subtitle: String? = nil
}

struct IAPrediccionesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [Message] = [
        Message(text: "¡Hola! Soy Zayu 🐆\n¿Cómo puedo ayudarte hoy?", isUser: false)
    ]
    @State private var currentMessage: String = ""
    @State private var isLoading = false
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        ZStack {
            
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollViewReader { proxy in
                    GeometryReader { geo in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 14) {
                                ForEach(messages) { msg in
                                    ChatBubble(message: msg, containerWidth: geo.size.width)
                                        .id(msg.id)
                                }
                                if isLoading {
                                    TypingBubble()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .padding(.bottom, 110)
                        }
                        .onChange(of: messages.count) { _, _ in
                            withAnimation(.easeOut(duration: 0.25)) {
                                proxy.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            composer
                .background(.ultraThinMaterial)
                .overlay(Divider(), alignment: .top)
        }
        .onTapGesture { isFieldFocused = false }
    }

    // Header
    private var topBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 34, height: 34)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
            }

            Spacer(minLength: 4)

            Text("HABLA CON ZAYU")
                .font(.fwcTitle(21))
                .kerning(0.5)
                .foregroundStyle(.black)

            Spacer()
            Color.clear.frame(width: 34, height: 34)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .bottom)
    }

    // Composer
    private var composer: some View {
        HStack(spacing: 10) {
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 42, height: 42)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
            }

            TextField("Pregunta o busca lo que quieras", text: $currentMessage, axis: .vertical)
                .font(.fwcText(16))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                .focused($isFieldFocused)

            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.black)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
            }
            .disabled(isLoading || currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(isLoading || currentMessage.isEmpty ? 0.6 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // Lógica
    private func sendMessage() {
        let userText = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userText.isEmpty else { return }

        messages.append(Message(text: userText, isUser: true))
        currentMessage = ""
        isLoading = true

        Task {
            if let response = await fetchGeminiResponse(for: userText) {
                messages.append(Message(text: response, isUser: false))
            } else {
                messages.append(Message(text: "Error al obtener respuesta de la IA.", isUser: false))
            }
            isLoading = false
        }
    }

    private func fetchGeminiResponse(for text: String) async -> String? {
        let client = GeminiClient()
        do {
            let reply = try await client.generate(text)
            return reply
        } catch {
            return "Ocurrió un problema con Gemini: \(error.localizedDescription)"
        }
    }

    
    private struct ChatBubble: View {
        let message: Message
        let containerWidth: CGFloat

        var body: some View {
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {

                // Avatar
                HStack {
                    if message.isUser {
                       Spacer()
                        Circle()
                            .fill(Color.white)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.black)
                            )
                            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
                    } else {
                        Image("ZayuChat")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
                        Spacer()
                    }
                }
                .padding(.horizontal, 4)

                // Burbuja
                HStack(alignment: .bottom, spacing: 8) {
                    if message.isUser { Spacer(minLength: 36) }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(message.text)
                            .font(.fwcText(16))
                            .foregroundStyle(.black)
                            .lineSpacing(2)
                            .frame(maxWidth: containerWidth * 0.75, alignment: .leading)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(message.isUser ? Color.bubbleUser : Color.bubbleBot)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.bubbleStroke, lineWidth: 0.7)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 2)

                    if !message.isUser { Spacer(minLength: 36) }
                }
            }
        }
    }

    private struct TypingBubble: View {
        @State private var phase: CGFloat = 0
        var body: some View {
            HStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.bubbleBot)
                    .frame(width: 64, height: 36)
                    .overlay(
                        HStack(spacing: 6) {
                            Circle().frame(width: 6, height: 6)
                            Circle().frame(width: 6, height: 6)
                            Circle().frame(width: 6, height: 6)
                        }
                        .foregroundStyle(.black.opacity(0.5))
                        .offset(y: sin(phase) * 2)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                   value: phase)
                    )
                    .onAppear { phase = .pi / 2 }
                Spacer()
            }
        }
    }
}


#Preview {
    ChatbotFlowView()
}
