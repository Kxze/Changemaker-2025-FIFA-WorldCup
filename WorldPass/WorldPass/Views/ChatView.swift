Código funcional gemini IA


import SwiftUI
import Foundation

// =============================================================
//
// =============================================================

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

//
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

//
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
// Diseño
// =============================================================

extension Font {
    static func fwcTitle(_ size: CGFloat) -> Font {
        .custom("FWC2026-NormalBlack", size: size)
    }
    static func fwcText(_ size: CGFloat) -> Font {
        .custom("FWC2026-NormalRegular", size: size)
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var subtitle: String? = nil
}

struct IAPrediccionesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [Message] = [
        Message(text: "¡Hola! Estoy aquí para asistirte\n¿Cómo puedo ayudarte hoy?", isUser: false)
    ]
    @State private var currentMessage: String = ""
    @State private var isLoading = false
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(messages) { msg in
                                ChatBubble(message: msg).id(msg.id)
                            }
                            if isLoading {
                                TypingBubble()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
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

            Text("IA PREDICCIONES")
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


    private var composer: some View {
        HStack(spacing: 10) {
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

        var body: some View {
            HStack(alignment: .bottom) {
                if message.isUser { Spacer(minLength: 36) }

                VStack(alignment: .leading, spacing: 6) {
                    Text(message.text)
                        .font(.fwcText(16))
                        .foregroundStyle(.black)
                        .lineSpacing(2)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(message.isUser
                              ? Color.gray.opacity(0.16)
                              : Color.green.opacity(0.18))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.6), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)

                if !message.isUser { Spacer(minLength: 36) }
            }
        }
    }

    private struct TypingBubble: View {
        @State private var phase: CGFloat = 0
        var body: some View {
            HStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.green.opacity(0.18))
                    .frame(width: 56, height: 36)
                    .overlay(
                        HStack(spacing: 6) {
                            Circle().frame(width: 6, height: 6)
                            Circle().frame(width: 6, height: 6)
                            Circle().frame(width: 6, height: 6)
                        }
                        .foregroundStyle(.black.opacity(0.5))
                        .offset(y: sin(phase) * 2)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: phase)
                    )
                    .onAppear { phase = .pi / 2 }
                Spacer()
            }
        }
    }
}


#Preview {
    NavigationStack {
        IAPrediccionesView()
            .navigationBarBackButtonHidden(true)
    }
}
