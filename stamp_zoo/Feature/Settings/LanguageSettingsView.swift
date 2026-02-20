import SwiftUI

struct LanguageSettingsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(localizationManager.supportedLanguages, id: \.self) { language in
                        HStack {
                            Text(localizationManager.supportedLanguageNames[language] ?? language)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if localizationManager.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            localizationManager.setLanguage(language)
                        }
                    }
                } header: {
                    Text("language_selection".localized)
                }
            }
            .navigationTitle("language_settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LanguageSettingsView()
} 