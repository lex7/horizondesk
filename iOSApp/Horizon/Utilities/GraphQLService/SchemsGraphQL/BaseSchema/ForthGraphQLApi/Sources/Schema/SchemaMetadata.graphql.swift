// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == ForthGraphQLApi.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == ForthGraphQLApi.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == ForthGraphQLApi.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == ForthGraphQLApi.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "query": return ForthGraphQLApi.Objects.Query
    case "CreditorResponseDto": return ForthGraphQLApi.Objects.CreditorResponseDto
    case "DebtTransactionDto": return ForthGraphQLApi.Objects.DebtTransactionDto
    case "ContactResponseDto": return ForthGraphQLApi.Objects.ContactResponseDto
    case "BankAccountResponseDto": return ForthGraphQLApi.Objects.BankAccountResponseDto
    case "DictionariesQuery": return ForthGraphQLApi.Objects.DictionariesQuery
    case "DictionaryMember": return ForthGraphQLApi.Objects.DictionaryMember
    case "ExceptionDto": return ForthGraphQLApi.Objects.ExceptionDto
    case "HelpResponseDto": return ForthGraphQLApi.Objects.HelpResponseDto
    case "FaqResponseDto": return ForthGraphQLApi.Objects.FaqResponseDto
    case "TransactionStatusDto": return ForthGraphQLApi.Objects.TransactionStatusDto
    case "TransactionsConnection": return ForthGraphQLApi.Objects.TransactionsConnection
    case "PageInfo": return ForthGraphQLApi.Objects.PageInfo
    case "TransactionResponseDto": return ForthGraphQLApi.Objects.TransactionResponseDto
    case "DashboardResponseDto": return ForthGraphQLApi.Objects.DashboardResponseDto
    case "TaskResponseDto": return ForthGraphQLApi.Objects.TaskResponseDto
    case "DocumentsConnection": return ForthGraphQLApi.Objects.DocumentsConnection
    case "DocumentResponseDto": return ForthGraphQLApi.Objects.DocumentResponseDto
    case "StatementResponseDto": return ForthGraphQLApi.Objects.StatementResponseDto
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
