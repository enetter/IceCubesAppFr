import SwiftUI
import Network

@MainActor
class TimelineViewModel: ObservableObject {
  enum State {
    enum PadingState {
      case hasNextPage, loadingNextPage
    }
    case loading
    case display(statuses: [Status], nextPageState: State.PadingState)
    case error
  }
  
  private let client: Client
  private var statuses: [Status] = []
  
  @Published var state: State = .loading
  
  var serverName: String {
    client.server
  }
  
  init(client: Client) {
    self.client = client
  }
  
  func refreshTimeline() async {
    do {
      statuses = try await client.fetchArray(endpoint: Timeline.pub(sinceId: nil))
      state = .display(statuses: statuses, nextPageState: .hasNextPage)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func loadNextPage() async {
    do {
      guard let lastId = statuses.last?.id else { return }
      state = .display(statuses: statuses, nextPageState: .loadingNextPage)
      let newStatuses: [Status] = try await client.fetch(endpoint: Timeline.pub(sinceId: lastId))
      statuses.append(contentsOf: newStatuses)
      state = .display(statuses: statuses, nextPageState: .hasNextPage)
    } catch {
      print(error.localizedDescription)
    }
  }
}
