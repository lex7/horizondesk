// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public enum ConsumerTransactionType: String, EnumType {
  /// Undefined
  case undefined = "UNDEFINED"
  /// ACH Client Debit
  case d = "D"
  /// ACH Debit
  case ach = "ACH"
  /// Transfer
  case t = "T"
  /// Check Payment
  case cp = "CP"
  /// Balance Transfer
  case bt = "BT"
  /// ACH Credit / Fee
  case c = "C"
  /// Client Refund
  case r = "R"
  /// ACH Credit From Trust
  case cft = "CFT"
  /// Settlement Payment
  case s = "S"
  /// Settlement Advance
  case sa = "SA"
  /// Fee Deposit
  case fd = "FD"
  /// Disbursement Fee
  case sf = "SF"
  /// Reversal
  case rv = "RV"
  /// Fee Account Withdrawal
  case faw = "FAW"
  /// Custodial Fee
  case dpg = "DPG"
  /// GCS Fee
  case gcs = "GCS"
  /// FORTH Reimbursement
  case dpgr = "DPGR"
  /// Trust Deposit
  case td = "TD"
  /// Loan Payment
  case lp = "LP"
  /// Custodial Reimbursement
  case cr = "CR"
  /// Credit Card Payment
  case cc = "CC"
  /// Debit Card Payment
  case dc = "DC"
  /// Fee Withdrawal
  case fw = "FW"
  /// Deferred Fee
  case fa = "FA"
  /// Earned Performance Fee
  case pf = "PF"
  /// Withdrawal
  case w = "W"
  /// Fee Account Deposit
  case fad = "FAD"
  /// Remittance
  case rmt = "RMT"
  /// Check Paid Fee
  case cpf = "CPF"
  /// Transaction Fee
  case tf = "TF"
  /// Grouped Check
  case grpc = "GRPC"
  /// Balance Forward
  case bf = "BF"
  /// RAM
  case ram = "RAM"
}
