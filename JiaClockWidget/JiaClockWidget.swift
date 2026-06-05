import SwiftUI
import WidgetKit

struct JiaClockWidget: Widget {
    let kind = "JiaClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JiaClockWidgetProvider()) { entry in
            JiaClockWidgetView(entry: entry)
        }
        .configurationDisplayName(String(localized: "widget.display_name"))
        .description(String(localized: "widget.description"))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
