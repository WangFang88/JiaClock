import WidgetKit

struct JiaClockWidgetEntry: TimelineEntry {
    let date: Date
    let settings: WidgetSharedSettings
}

struct JiaClockWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> JiaClockWidgetEntry {
        JiaClockWidgetEntry(date: .now, settings: .default)
    }

    func getSnapshot(in context: Context, completion: @escaping (JiaClockWidgetEntry) -> Void) {
        completion(JiaClockWidgetEntry(date: .now, settings: WidgetSharedSettings.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<JiaClockWidgetEntry>) -> Void) {
        let settings = WidgetSharedSettings.load()
        let start = WidgetTimeFormatter.nextMinuteBoundary(from: .now)
        var entries: [JiaClockWidgetEntry] = []
        for offset in 0..<60 {
            guard let date = Calendar.current.date(byAdding: .minute, value: offset, to: start) else { continue }
            entries.append(JiaClockWidgetEntry(date: date, settings: settings))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
