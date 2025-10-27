//
//  DividirGastosView.swift
//  WorldPass
//
//  Created by Pau Pau on 26/10/25.
//

import SwiftUI
import Foundation
import Combine

struct Friend: Identifiable, Hashable {
    let id = UUID()
    var name: String
}

struct Expense: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var amount: Decimal
    var currency: String = "MXN"
    var payer: Friend
    var participants: [Friend]
    var date: Date = .now
}

final class ExpensesStore: ObservableObject {
    @Published var friends: [Friend] = [
        .init(name: "Gigi"),
        .init(name: "Pau"),
        .init(name: "Diego"),
        .init(name: "Sol"),
        .init(name: "Tania"),
        .init(name: "Leo"),
        .init(name: "Tú")
    ]
    @Published var expenses: [Expense] = []
    
    var balances: [Friend: Decimal] {
        var map: [Friend: Decimal] = [:]
        friends.forEach { map[$0] = 0 }
        for e in expenses {
            let n = max(e.participants.count, 1)
            let share = e.amount / Decimal(n)
            map[e.payer, default: 0] += e.amount
            for f in e.participants {
                map[f, default: 0] -= share
            }
        }
        return map
    }
}

extension Decimal {
    func formattedMXN() -> String {
        let n = NSDecimalNumber(decimal: self)
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = "MXN"
        fmt.maximumFractionDigits = 2
        fmt.minimumFractionDigits = 2
        return fmt.string(from: n) ?? "MXN 0.00"
    }
}

struct GlassCardStyleModifier: ViewModifier {
    var corner: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 8)
    }
}

extension View {
    func glassCardStyle(corner: CGFloat = 16) -> some View { modifier(GlassCardStyleModifier(corner: corner)) }
    
    func fwcBlack(_ size: CGFloat) -> some View {
        self.font(.custom("FWC2026-NormalBlack", size: size, relativeTo: .headline))
    }
    func fwcRegular(_ size: CGFloat) -> some View {
        self.font(.custom("FWC2026-NormalRegular", size: size, relativeTo: .body))
    }
}

struct ExpensesRootView: View {
    @StateObject private var store = ExpensesStore()
    @State private var showAdd = false
    @Environment(\.dismiss) private var dismiss // ← necesario para el botón Atrás
    
    var body: some View {
        NavigationStack {
            GroupsListView()
                .environmentObject(store)
                .toolbar {
                    // ← Botón Atrás (superior izquierdo)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .symbolRenderingMode(.monochrome)
                            }
                            .foregroundStyle(.black)
                        }
                    }
                    // Título centrado
                    ToolbarItem(placement: .principal) {
                        Text("GASTOS").fwcBlack(20)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Spacer()
                        Button {
                            showAdd = true
                        } label: {
                            Image(systemName: "plus")
                                .symbolRenderingMode(.monochrome)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 62, height: 62)
                                .background(.ultraThinMaterial, in: Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                                .shadow(radius: 10)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                // Añadir gasto en pantalla completa
                .fullScreenCover(isPresented: $showAdd) {
                    AddExpenseSheet(isPresented: $showAdd)
                        .environmentObject(store)
                        .tint(.black)
                }
                .background(LinearGradient(colors: [Color.white, Color.white.opacity(0.9)], startPoint: .top, endPoint: .bottom))
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .tint(.black)
    }
}



struct GroupsListView: View {
    @EnvironmentObject var store: ExpensesStore
    @State private var goSummary = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("GRUPOS").fwcBlack(16).foregroundStyle(.secondary).padding(.horizontal)
            
            if store.expenses.isEmpty {
                VStack(spacing: 10) {
                    Text("Aún no hay gastos").fwcRegular(16).foregroundStyle(.secondary)
                    Text("Toca “+” para añadir el primero").fwcRegular(14).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity).padding()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(store.expenses) { e in
                            ExpenseRow(expense: e)
                                .glassCardStyle()
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            
            Button { goSummary = true } label: {
                Text("Ver resumen")
                    .fwcBlack(16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
            }
            .padding([.horizontal, .bottom])
            
            NavigationLink("", isActive: $goSummary) {
                SummaryView().environmentObject(store)
            }
        }
    }
}

struct ExpenseRow: View {
    var expense: Expense
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(expense.title.uppercased()).fwcBlack(13)
                Text(expense.participants.map(\.name).joined(separator: ", "))
                    .fwcRegular(12).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text(expense.amount.formattedMXN().replacingOccurrences(of: "MX$", with: ""))
                    .fwcBlack(18)
                Text(expense.currency).fwcRegular(10).foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.black)
                .padding(.leading, 8)
        }
    }
}

struct AddExpenseSheet: View {
    @EnvironmentObject var store: ExpensesStore
    @Binding var isPresented: Bool
    
    @State private var title: String = ""
    @State private var amountText: String = ""
    @State private var payer: Friend?
    @State private var selected: Set<Friend> = []
    @FocusState private var focusAmount: Bool
    
    var amount: Decimal {
        Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    var valid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && amount > 0 && payer != nil && !participants.isEmpty
    }
    var participants: [Friend] {
        selected.isEmpty ? store.friends : Array(selected)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // Campo Concepto
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AÑADIR GASTOS").fwcBlack(16)
                        TextField("Concepto (ej. Comida estadio)", text: $title)
                            .textInputAutocapitalization(.sentences)
                            .submitLabel(.next)
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.35), lineWidth: 1))
                    }
                    .glassCardStyle()
                    
                    // Monto
                    HStack(spacing: 10) {
                        Text("MXN").fwcBlack(14)
                            .padding(.horizontal, 12).padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .focused($focusAmount)
                            .fwcBlack(28)
                            .minimumScaleFactor(0.8)
                            .multilineTextAlignment(.trailing)
                            .padding(.horizontal, 12).padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.35), lineWidth: 1))
                    }
                    .glassCardStyle()
                    
                    // Pagado por
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Por").fwcBlack(14)
                        Picker("Pagado por", selection: Binding(get: {
                            payer ?? store.friends.first!
                        }, set: { new in
                            payer = new
                        })) {
                            ForEach(store.friends) { f in
                                Text(f.name).tag(f)
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.35), lineWidth: 1))
                    }
                    .glassCardStyle()
                    
                    // Participantes
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Entre").fwcBlack(14)
                        VStack(spacing: 8) {
                            ForEach(store.friends) { f in
                                FriendRowSelectable(friend: f, isOn: selected.contains(f)) {
                                    if selected.contains(f) { selected.remove(f) } else { selected.insert(f) }
                                }
                            }
                        }
                    }
                    .glassCardStyle()
                    
                    // Previsualización de división
                    if amount > 0 {
                        let count = max(participants.count, 1)
                        let share = amount / Decimal(count)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Se divide entre \(count) • \(share.formattedMXN()) c/u").fwcRegular(13).foregroundStyle(.secondary)
                            FlowChips(names: participants.map(\.name))
                        }
                        .glassCardStyle()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .onAppear {
                    payer = payer ?? store.friends.first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { focusAmount = true }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .symbolRenderingMode(.monochrome)
                            //Text("Atrás")
                        }
                        .foregroundStyle(.black)
                    }
                }
                // Confirmación
                ToolbarItem(placement: .confirmationAction) {
                    Button("Añadir") {
                        let exp = Expense(title: title.trimmingCharacters(in: .whitespaces),
                                          amount: amount,
                                          currency: "MXN",
                                          payer: payer ?? store.friends.first!,
                                          participants: participants)
                        store.expenses.append(exp)
                        isPresented = false
                    }
                    .disabled(!valid)
                }
                // Título centrado
                ToolbarItem(placement: .principal) {
                    Text("AÑADIR GASTO").fwcBlack(18)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .background(
                LinearGradient(colors: [Color.white, Color.white.opacity(0.95)],
                               startPoint: .top, endPoint: .bottom)
            )
        }
        .interactiveDismissDisabled(true)
        .tint(.black) // controles en negro
    }
}

struct FriendRowSelectable: View {
    var friend: Friend
    var isOn: Bool
    var toggle: () -> Void
    
    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 34, height: 34)
                        .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
                    Text(String(friend.name.prefix(1)).uppercased()).fwcBlack(14)
                }
                Text(friend.name).fwcBlack(14)
                Spacer()
                Image(systemName: isOn ? "checkmark.circle" : "circle")
                    .symbolRenderingMode(.monochrome)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.black) // ícono en negro
            }
            .padding(10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct FlowChips: View {
    var names: [String]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
            ForEach(names, id: \.self) { n in
                Text(n)
                    .fwcRegular(12)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
            }
        }
    }
}

struct SummaryView: View {
    @EnvironmentObject var store: ExpensesStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RESUMEN").fwcBlack(16).foregroundStyle(.secondary).padding(.horizontal)
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(store.friends) { f in
                        let bal = store.balances[f] ?? 0
                        HStack {
                            Text(f.name.uppercased()).fwcBlack(14)
                            Spacer()
                            Text(formattedBalance(bal))
                                .fwcBlack(18)
                                .foregroundStyle(bal >= 0 ? .green : .red)
                            Text("MXN").fwcRegular(10).foregroundStyle((bal >= 0) ? .green : .red.opacity(0.8))
                        }
                        .glassCardStyle()
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("RESUMEN").fwcBlack(20)
            }
        }
        .background(LinearGradient(colors: [Color.white, Color.white.opacity(0.9)], startPoint: .top, endPoint: .bottom))
    }
    
    private func formattedBalance(_ d: Decimal) -> String {
        let s = d.formattedMXN().replacingOccurrences(of: "MX$", with: "")
        return (d >= 0 ? "+" : "−") + s.replacingOccurrences(of: "-", with: "")
    }
}

struct ExpensesRootView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesRootView()
            .preferredColorScheme(.light)
    }
}
