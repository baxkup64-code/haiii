import SwiftUI

struct SettingsView: View {
    @AppStorage("streamingQuality") private var streamingQuality = "Normal"
    @AppStorage("downloadOverWifiOnly") private var wifiOnly = true
    private let qualities = ["Niedrig", "Normal", "Hoch"]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Theme.Color.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 26) {
                        Text("Einstellungen")
                            .font(Theme.Font.largeTitle())
                            .foregroundStyle(Theme.Color.textPrimary)

                        settingsSection("WIEDERGABE") {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Streaming-Qualität")
                                        .font(Theme.Font.body())
                                        .foregroundStyle(Theme.Color.textPrimary)
                                    Spacer()
                                    Picker("", selection: $streamingQuality) {
                                        ForEach(qualities, id: \.self) { quality in
                                            Text(quality).tag(quality)
                                        }
                                    }
                                    .labelsHidden()
                                    .tint(Theme.Color.accent)
                                }
                                .padding(16)

                                Divider().overlay(Theme.Color.divider)

                                Toggle(isOn: $wifiOnly) {
                                    Text("Nur über WLAN herunterladen")
                                        .font(Theme.Font.body())
                                        .foregroundStyle(Theme.Color.textPrimary)
                                }
                                .tint(Theme.Color.accent)
                                .padding(16)
                            }
                            .background(Theme.Color.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        settingsSection("MUSIKQUELLEN") {
                            VStack(alignment: .leading, spacing: 12) {
                                sourceRow(icon: "music.note.list", title: "Spotify", detail: "Direkte Musikquelle")
                                sourceRow(icon: "waveform", title: "SoundCloud", detail: "Direkte Musikquelle")
                            }
                            .padding(16)
                            .background(Theme.Color.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        settingsSection("ÜBER") {
                            VStack(spacing: 0) {
                                LabeledContent("Version", value: "1.1.0")
                                    .padding(16)
                            }
                            .background(Theme.Color.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, max(8, proxy.safeAreaInsets.top + 8))
                    .padding(.bottom, max(24, proxy.safeAreaInsets.bottom + 96))
                }
                .scrollIndicators(.hidden)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(Theme.Font.caption())
                .foregroundStyle(Theme.Color.textSecondary)
                .padding(.horizontal, 4)
            content()
        }
    }

    private func sourceRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.Color.accent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Font.subheading())
                    .foregroundStyle(Theme.Color.textPrimary)
                Text(detail)
                    .font(Theme.Font.caption())
                    .foregroundStyle(Theme.Color.textSecondary)
            }

            Spacer(minLength: 0)
        }
    }
}
