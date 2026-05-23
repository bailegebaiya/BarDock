import AppKit
import SwiftUI

struct BarDockPanel: View {
    @ObservedObject var store: BarDockStore
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            controls
            Divider()
            footer
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(nsColor: .separatorColor).opacity(0.45), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "menubar.rectangle")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.tint)
                .frame(width: 26, height: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text("BarDock")
                    .font(.system(size: 15, weight: .semibold))
                Text(store.isCollapsed ? "已隐藏" : "已展开")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(store.isCollapsed ? "‹" : "›")
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 26, height: 26)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 8)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                onToggle()
            } label: {
                Label(
                    store.isCollapsed ? "展开菜单栏图标" : "隐藏菜单栏图标",
                    systemImage: store.isCollapsed ? "eye" : "eye.slash"
                )
                .frame(maxWidth: .infinity)
            }
            .controlSize(.large)

            VStack(alignment: .leading, spacing: 8) {
                StepRow(symbol: "command", text: "拖动 `·` 到隐藏边界")
                StepRow(symbol: "cursorarrow.click", text: "点击 `›/‹` 隐藏或显示")
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 12)
    }

    private var footer: some View {
        HStack {
            Spacer()

            Button(role: .destructive) {
                NSApp.terminate(nil)
            } label: {
                Label("退出", systemImage: "power")
            }
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 8)
    }
}

private struct StepRow: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18, height: 18)

            Text(.init(text))
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
    }
}
