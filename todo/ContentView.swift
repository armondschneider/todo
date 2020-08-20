import SwiftUI

struct ContentView: View {
    private enum Section: String, CaseIterable {
        case now = "Now"
        case later = "Later"
    }

    @StateObject private var store = TodoStore()
    @State private var selectedSection = Section.now
    @State private var newTodo = ""
    @FocusState private var isAddingTodo: Bool

    private var visibleItems: [Item] {
        store.items.filter { $0.isLater == (selectedSection == .later) }
    }

    private var trimmedTodo: String {
        newTodo.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                sectionPicker
                    .padding(.top, 12)
                todoList
                    .padding(.top, 20)
            }
        }
        .safeAreaInset(edge: .bottom) {
            addTodoBar
        }
    }

    private var sectionPicker: some View {
        GeometryReader { geometry in
            let tabWidth = (geometry.size.width - 8) / 2

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white)

                Capsule()
                    .fill(Color.primary)
                    .frame(width: tabWidth, height: 40)
                    .offset(x: selectedSection == .now ? 4 : tabWidth + 4)

                HStack(spacing: 0) {
                    ForEach(Section.allCases, id: \.self) { section in
                        Button {
                            selectedSection = section
                        } label: {
                            Text(section.rawValue)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(selectedSection == section ? Color(UIColor.systemBackground) : .secondary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
            }
            .animation(.easeInOut(duration: 0.2), value: selectedSection)
        }
        .frame(height: 48)
        .padding(.horizontal, 24)
    }

    private var todoList: some View {
        ZStack {
            List {
                ForEach(visibleItems) { item in
                    todoRow(item)
                        .listRowInsets(EdgeInsets(top: 5, leading: 24, bottom: 5, trailing: 24))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                store.move(item)
                            } label: {
                                Label(selectedSection == .now ? "Later" : "Now",
                                      systemImage: selectedSection == .now ? "clock" : "sun.max")
                            }
                            .tint(Color(UIColor.systemGray))
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.delete(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

            if visibleItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: selectedSection == .now ? "checkmark" : "clock")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 54, height: 54)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    Text(selectedSection == .now ? "Nothing for now" : "Nothing waiting")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    Text("Add a todo below to get started.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func todoRow(_ item: Item) -> some View {
        HStack(spacing: 14) {
            Button {
                store.toggle(item)
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundColor(item.isCompleted ? Color(UIColor.systemGray) : .secondary)
            }
            .buttonStyle(.plain)

            Text(item.title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(item.isCompleted ? .secondary : .primary)
                .strikethrough(item.isCompleted, color: .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 13)
        .background(Color.white.opacity(item.isCompleted ? 0.65 : 1))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var addTodoBar: some View {
        HStack(spacing: 10) {
            TextField("Add todo", text: $newTodo)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .textInputAutocapitalization(.never)
                .focused($isAddingTodo)
                .submitLabel(.done)
                .onSubmit(addTodo)
                .onChange(of: newTodo) { value in
                    let lowercaseValue = value.lowercased()
                    if value != lowercaseValue {
                        newTodo = lowercaseValue
                    }
                }

            Button(action: addTodo) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(trimmedTodo.isEmpty ? Color(UIColor.systemGray4) : Color(UIColor.systemBlue))
                    .clipShape(Circle())
                    .scaleEffect(trimmedTodo.isEmpty ? 0.92 : 1)
            }
            .disabled(trimmedTodo.isEmpty)
            .animation(.easeInOut(duration: 0.2), value: trimmedTodo.isEmpty)
        }
        .padding(8)
        .padding(.leading, 10)
        .background(Color.white)
        .clipShape(Capsule())
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private func addTodo() {
        guard !trimmedTodo.isEmpty else { return }
        store.add(trimmedTodo, isLater: selectedSection == .later)
        newTodo = ""
        isAddingTodo = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
