import DesignSystem
import Env
import Models
import Shimmer
import SwiftUI

public struct StatusesListView<Fetcher>: View where Fetcher: StatusesFetcher {
  @EnvironmentObject private var theme: Theme

  @ObservedObject private var fetcher: Fetcher
  private let isRemote: Bool

  public init(fetcher: Fetcher, isRemote: Bool = false) {
    self.fetcher = fetcher
    self.isRemote = isRemote
  }

  public var body: some View {
    switch fetcher.statusesState {
    case .loading:
      ForEach(Status.placeholders()) { status in
        StatusRowView(viewModel: .init(status: status, isCompact: false))
          .redacted(reason: .placeholder)
      }
    case .error:
      ErrorView(title: "status.error.title",
                message: "status.error.loading.message",
                buttonTitle: "action.retry") {
        Task {
          await fetcher.fetchStatuses()
        }
      }
      .listRowBackground(theme.primaryBackgroundColor)
      .listRowSeparator(.hidden)

    case let .display(statuses, nextPageState):
      ForEach(statuses, id: \.viewId) { status in
        let viewModel = StatusRowViewModel(status: status, isCompact: false, isRemote: isRemote)
        if viewModel.filter?.filter.filterAction != .hide {
          StatusRowView(viewModel: viewModel)
            .id(status.id)
            .onAppear {
              fetcher.statusDidAppear(status: status)
            }
            .onDisappear {
              fetcher.statusDidDisappear(status: status)
            }
        }
      }
      switch nextPageState {
      case .hasNextPage:
        loadingRow
          .onAppear {
            Task {
              await fetcher.fetchNextPage()
            }
          }
      case .loadingNextPage:
        loadingRow
      case .none:
        EmptyView()
      }
    }
  }

  private var loadingRow: some View {
    HStack {
      Spacer()
      ProgressView()
      Spacer()
    }
    .padding(.horizontal, .layoutPadding)
    .listRowBackground(theme.primaryBackgroundColor)
  }
}
