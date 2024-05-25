// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TasksQuery: GraphQLQuery {
  public static let operationName: String = "TasksQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query TasksQuery { tasks { __typename taskId taskName notes dueDate createdDate overdue completed completedDate } }"#
    ))

  public init() {}

  public struct Data: ForthGraphQLApi.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("tasks", [Task].self),
    ] }

    public var tasks: [Task] { __data["tasks"] }

    /// Task
    ///
    /// Parent Type: `TaskResponseDto`
    public struct Task: ForthGraphQLApi.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ForthGraphQLApi.Objects.TaskResponseDto }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("taskId", Int.self),
        .field("taskName", String.self),
        .field("notes", String.self),
        .field("dueDate", ForthGraphQLApi.Date.self),
        .field("createdDate", ForthGraphQLApi.Date.self),
        .field("overdue", Bool.self),
        .field("completed", Bool.self),
        .field("completedDate", ForthGraphQLApi.Date?.self),
      ] }

      public var taskId: Int { __data["taskId"] }
      public var taskName: String { __data["taskName"] }
      public var notes: String { __data["notes"] }
      public var dueDate: ForthGraphQLApi.Date { __data["dueDate"] }
      public var createdDate: ForthGraphQLApi.Date { __data["createdDate"] }
      public var overdue: Bool { __data["overdue"] }
      public var completed: Bool { __data["completed"] }
      public var completedDate: ForthGraphQLApi.Date? { __data["completedDate"] }
    }
  }
}
