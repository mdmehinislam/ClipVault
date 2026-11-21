import SwiftUI
import SwiftData

struct ContentView: View {
    var isPopup = false
    var onClose: (() -> Void)? = nil

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClipboardEntry.createdAt, order: .reverse) private var entries: [ClipboardEntry]
    @State private var searchText = ""
    @State private var selectedID: UUID?
    @State private var showClearConfirmation = false

    private var pinned: [ClipboardEntry] {
        filtered.filter(\.isPinned)
    }
    private var recent: [ClipboardEntry] {
        filtered.filter { !$0.isPinned }
    }
    private var filtered: [ClipboardEntry] {
        guard !searchText.isEmpty else { return entries }
        return entries.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search clipboard...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(10)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            List(selection: $selectedID) {
                if !pinned.isEmpty {
                    Section("PINNED") {
                        ForEach(pinned) { item in itemRow(item) }
                    }
                }
                Section("RECENT") {
                    ForEach(recent) { item in itemRow(item) }
                }
            }
            .listStyle(.inset)
            footer
        }
        .background(.background)
        .confirmationDialog("Clear all unpinned clipboard history?",
                            isPresented: $showClearConfirmation,
                            titleVisibility: .visible) {
            Button("Clear All Unpinned History", role: .destructive) {
                for item in entries where !item.isPinned {
                    modelContext.delete(item)
                }
                try? modelContext.save()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onKeyPress(.return) {
            guard let item = entries.first(where: { $0.id == selectedID }) else {
                return .ignored
            }
            paste(item)
            return .handled
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "doc.on.clipboard").font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("ClipVault").font(.headline)
                Text("\(entries.count) saved items").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if isPopup {
                Button(action: { onClose?() }) {
                    Image(systemName: "xmark")
                }.buttonStyle(.plain)
            }
        }
        .padding(16)
    }

    private func itemRow(_ item: ClipboardEntry) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: item.isPinned ? "pin.fill" : "doc.text")
                .foregroundStyle(item.isPinned ? .orange : .secondary)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.text)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2).foregroundStyle(.tertiary)
            }
            Spacer(minLength: 4)
            Menu {
                Button(item.isPinned ? "Unpin" : "Pin",
                       systemImage: item.isPinned ? "pin.slash" : "pin") {
                    item.isPinned.toggle()
                    try? modelContext.save()
                }
                Button("Copy", systemImage: "doc.on.doc") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(item.text, forType: .string)
                }
                Button("Paste", systemImage: "return") { paste(item) }
                if !item.isPinned {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(item)
                        try? modelContext.save()
                    }
                }
            } label: {
                Image(systemName: "ellipsis").padding(5)
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture { selectedID = item.id }
        .contextMenu {
            Button("Paste") { paste(item) }
            Button(item.isPinned ? "Unpin" : "Pin") {
                item.isPinned.toggle()
                try? modelContext.save()
            }
        }
    }

    private var footer: some View {
        HStack {
            Text("500 unpinned items max").font(.caption).foregroundStyle(.secondary)
            Spacer()
            Button("Clear History", role: .destructive) {
                showClearConfirmation = true
            }
            .disabled(entries.allSatisfy(\.isPinned))
        }
        .padding(12)
    }

    private func paste(_ item: ClipboardEntry) {
        if isPopup {
            QuickPasteService.shared.paste(item.text) { onClose?() }
        } else {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(item.text, forType: .string)
        }
    }
}
