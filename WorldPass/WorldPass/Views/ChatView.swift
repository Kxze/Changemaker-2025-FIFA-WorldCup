//
//  ChatView.swift
//  WorldPass
//
//  Created by Pau Pau on 21/10/25.
//

import SwiftUI
import Foundation
import Lottie

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

struct GeminiRequest: Encodable { let contents: [GeminiContent] }
struct GeminiContent: Encodable { let role: String; let parts: [GeminiPart] }
struct GeminiPart: Encodable { let text: String }

struct GeminiResponse: Decodable { let candidates: [GeminiCandidate]?; let promptFeedback: GeminiPromptFeedback? }
struct GeminiCandidate: Decodable { let content: GeminiContentResponse?; let finishReason: String? }
struct GeminiContentResponse: Decodable { let parts: [GeminiPartResponse]? }
struct GeminiPartResponse: Decodable { let text: String? }
struct GeminiPromptFeedback: Decodable { let safetyRatings: [GeminiSafety]? }
struct GeminiSafety: Decodable { let category: String?; let probability: String? }

struct GeminiClient {
    let model: String = "gemini-2.5-flash"

    private func resolveAPIKey() -> String? {
        if let key = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String {
            let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return "AIzaSyDd575EyaeP40k4O4owwSmGWs_gd13sFe0"
        }
        #endif
        return nil
    }

    func generate(_ userText: String) async throws -> String {
        guard let apiKey = resolveAPIKey(), !apiKey.isEmpty else { throw GeminiError.missingAPIKey }

        var comps = URLComponents(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        comps.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        let url = comps.url!

        let payload = GeminiRequest(contents: [GeminiContent(role: "user", parts: [GeminiPart(text: userText)])])

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else { throw GeminiError.httpError(-1, "Respuesta no HTTP") }
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

//  Estilos

extension Font {
    static func fwcTitle(_ size: CGFloat) -> Font { .custom("FWC2026-NormalBlack", size: size) }
    static func fwcText(_ size: CGFloat) -> Font { .custom("FWC2026-NormalRegular", size: size) }
}

private extension Color {
    static let bubbleBot    = Color(red: 0.90, green: 0.97, blue: 0.92)
    static let bubbleUser   = Color(red: 0.95, green: 0.96, blue: 0.97)
    static let bubbleStroke = Color.white.opacity(0.7)
}

//

struct ChatbotFlowView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
          
            KickoIntroView(onClose: { dismiss() })
        }
        .environment(\.font, .custom("FWC2026-NormalRegular", size: 16))
    }
}


struct KickoIntroView: View {
    @Environment(\.dismiss) private var dismiss
    var onClose: (() -> Void)? = nil

    var body: some View {
        GlassEffectContainer {
            ZStack {
                
                Image("FondoRojo")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 34, height: 34)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                    }
                    .hidden()
                    
                    Spacer(minLength: 8)
                    
                    Text("¡HOLA,\nSOY KICKO!")
                        .multilineTextAlignment(.center)
                        .font(.fwcTitle(44))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        .padding(.bottom, 8)
                    
                    LottieView(animation: .named("kickoD"))
                        .playing()
                        .looping()
                    
                    
                    Spacer()
                    
                    Text("¿Cómo puedo ayudarte?")
                        .font(.fwcText(18))
                        .foregroundStyle(.white.opacity(0.95))
                        .padding(.bottom, 8)
                    
                    NavigationLink {
                        
                        IAPrediccionesView(onClose: onClose)
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
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}


struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let isUser: Bool
    var subtitle: String? = nil

    init(id: UUID = UUID(), text: String, isUser: Bool, subtitle: String? = nil) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.subtitle = subtitle
    }
}

private enum ChatPersistence {
    static let key = "chat_history_v1"

    static func save(_ messages: [Message]) {
        do {
            let data = try JSONEncoder().encode(messages)
            UserDefaults.standard.set(data, forKey: key)
        } catch { }
    }

    static func load() -> [Message]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do { return try JSONDecoder().decode([Message].self, from: data) }
        catch { return nil }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}


struct IAPrediccionesView: View {
    @Environment(\.dismiss) private var dismiss
    var onClose: (() -> Void)? = nil

    @State private var messages: [Message] = ChatPersistence.load()
        ?? [Message(text: "¡Hola! Soy Kicko \n¿Cómo puedo ayudarte hoy?", isUser: false)]

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
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(messages) { msg in
                                    ChatBubble(message: msg, containerWidth: geo.size.width)
                                        .id(msg.id)
                                }
                                if isLoading {
                                    TypingRow()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .padding(.bottom, 110)
                        }
                        .scrollDismissesKeyboard(.interactively)
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
        .onChange(of: messages) { _, newValue in ChatPersistence.save(newValue) }
        // Ocultamos la barra SOLO en el chat
        .toolbar(.hidden, for: .navigationBar)
    }

    // Header
    private var topBar: some View {
        HStack(spacing: 12) {
            //
            Button {
                onClose?() ?? dismiss() //
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 34, height: 34)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
            }

            Spacer(minLength: 4)

            Text("HABLA CON KICKO")
                .font(.fwcTitle(21))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .allowsTightening(true)
                .truncationMode(.tail)

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
            TextField("Pregunta a Kicko", text: $currentMessage, axis: .vertical)
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
        ChatPersistence.save(messages)

        Task {
            if let response = await fetchGeminiResponse(for: userText) {
                messages.append(Message(text: response, isUser: false))
            } else {
                messages.append(Message(text: "Error al obtener respuesta de la IA.", isUser: false))
            }
            isLoading = false
            ChatPersistence.save(messages)
        }
    }

    private func fetchGeminiResponse(for text: String) async -> String? {
        let client = GeminiClient()
        let briefInstruction = "Responde de forma breve, clara y directa. Máximo 2 oraciones. "
        do {
            let reply = try await client.generate(briefInstruction + text)
            let maxChars = 280
            if reply.count > maxChars {
                if let lastSpace = reply.prefix(maxChars).lastIndex(of: " ") {
                    return String(reply[..<lastSpace]) + "…"
                }
                return String(reply.prefix(maxChars)) + "…"
            }
            return reply
        } catch {
            return "Ocurrió un problema con Gemini: \(error.localizedDescription)"
        }
    }

    // Burbujas
    private struct ChatBubble: View {
        let message: Message
        let containerWidth: CGFloat

        var body: some View {
            HStack(alignment: .bottom, spacing: 8) {
                if message.isUser {
                    Spacer(minLength: 36)

                    bubble
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.bubbleUser))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.bubbleStroke, lineWidth: 0.7))
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)

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
                    Image("KickoChat")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        .shadow(color: .black.opacity(0.06), radius: 3, y: 1)

                    bubble
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.bubbleBot))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.bubbleStroke, lineWidth: 0.7))
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)

                    Spacer(minLength: 36)
                }
            }
        }

        private var bubble: some View {
            Text(message.text)
                .font(.fwcText(16))
                .foregroundStyle(.black)
                .lineSpacing(2)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: containerWidth * 0.75, alignment: .leading)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private struct TypingRow: View {
        @State private var phase: CGFloat = 0

        var body: some View {
            HStack(spacing: 8) {
                Image("KickoChat")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 22, height: 22)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .shadow(color: .black.opacity(0.06), radius: 3, y: 1)

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
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: phase)
                    )
                    .onAppear { phase = .pi / 2 }

                Spacer(minLength: 36)
            }
        }
    }
}



#Preview {
    ChatbotFlowView()
}
