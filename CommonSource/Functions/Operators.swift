import Foundation

infix operator <<-

infix operator ⋀⋀
infix operator ⋁⋁

infix operator ⋀⋀=
infix operator ⋁⋁=

/*
 precedencegroup AssignmentPrecedence {
  assignment: true
  associativity: right
}
precedencegroup FunctionArrowPrecedence {
  associativity: right
  higherThan: AssignmentPrecedence
}
precedencegroup TernaryPrecedence {
  associativity: right
  higherThan: FunctionArrowPrecedence
}
precedencegroup DefaultPrecedence {
  higherThan: TernaryPrecedence
}
precedencegroup LogicalDisjunctionPrecedence {
  associativity: left
  higherThan: TernaryPrecedence
}
precedencegroup LogicalConjunctionPrecedence {
  associativity: left
  higherThan: LogicalDisjunctionPrecedence
}
precedencegroup ComparisonPrecedence {
  higherThan: LogicalConjunctionPrecedence
}
precedencegroup NilCoalescingPrecedence {
  associativity: right
  higherThan: ComparisonPrecedence
}
precedencegroup CastingPrecedence {
  higherThan: NilCoalescingPrecedence
}
precedencegroup RangeFormationPrecedence {
  higherThan: CastingPrecedence
}
precedencegroup AdditionPrecedence {
  associativity: left
  higherThan: RangeFormationPrecedence
}
precedencegroup MultiplicationPrecedence {
  associativity: left
  higherThan: AdditionPrecedence
}
precedencegroup BitwiseShiftPrecedence {
  higherThan: MultiplicationPrecedence
}
*/

// MARK: - PseudoConstraint operators

precedencegroup IdentifierPrecedence {
  associativity: left
  lowerThan: FunctionArrowPrecedence
}

precedencegroup ConstraintBuilderPrecedence {
  higherThan: AdditionPrecedence
}

infix operator --> : IdentifierPrecedence  /// Identifier operator
infix operator ! : IdentifierPrecedence  /// Priority operator

prefix operator >=  /// Greater-than-or-equal spacing prefix operator
prefix operator <=  /// Less-than-or-equal spacing prefix operator
prefix operator ==  /// Equal spacing prefix operator

infix operator ∶|   : ConstraintBuilderPrecedence /// With a pinned head.
infix operator ∶|-  : ConstraintBuilderPrecedence /// With a pinned head and standard spacing.
infix operator ∶    : ConstraintBuilderPrecedence /// With an unpinned head.

postfix operator |   /// For PseudoContraintBuilder tail pinning
postfix operator -| /// For PseudoContraintBuilder tail pinning with standard spacing

infix operator +--> : RangeFormationPrecedence /// Range creation via start + length


// MARK: - Set operators

infix operator ∈  : ComparisonPrecedence   /// Set member operator
infix operator ∋  : ComparisonPrecedence   /// Set member operator
infix operator ∉  : ComparisonPrecedence   /// Not a set member operator
infix operator ∌  : ComparisonPrecedence   /// Not a set member operator
infix operator ∖  : AdditionPrecedence     /// Set minus operator
infix operator ∖= : AssignmentPrecedence   /// Set minus assignment operator
infix operator ∪  : AdditionPrecedence     /// Set union operator
infix operator ∪= : AssignmentPrecedence   /// Set union assignment operator
infix operator ∩  : AdditionPrecedence     /// Set intersection operator
infix operator ∩= : AssignmentPrecedence   /// Set intersection assignment operator
infix operator ⊂  : ComparisonPrecedence   /// Strict subset operator
infix operator ⊃  : ComparisonPrecedence   /// Strict subset operator
infix operator ⊄  : ComparisonPrecedence   /// Not strict subset operator
infix operator ⊅  : ComparisonPrecedence   /// Not strict subset operator
infix operator ⊆  : ComparisonPrecedence   /// subset operator
infix operator ⊇  : ComparisonPrecedence   /// subset operator
infix operator ⊈  : ComparisonPrecedence   /// Not subset operator
infix operator ⊉  : ComparisonPrecedence   /// Not subset operator
infix operator ∆  : AdditionPrecedence     /// Symmetric difference operator
infix operator ∆= : AssignmentPrecedence   /// Symmetric difference assignment operator


// MARK: - AttributedString operators

prefix operator ¶  /// AttributedString formation operator
infix operator ¶|  /// AttributedString formation operator

// MARK: - Fraction & Ratio operators

precedencegroup FractionFormationPrecedence {
  higherThan: MultiplicationPrecedence
}

infix operator ╱ : FractionFormationPrecedence  /// Fraction formation operator
infix operator ÷ : FractionFormationPrecedence  /// Fraction formation operator
//infix operator ∶ : FractionFormationPrecedence  /// Ratio formation operator

prefix operator *  /// Unpacking operator

// MARK: - (Closed)Unbounded(Lower/Upper)Range operators

postfix operator |->  /// UnboundedUpperRange formation operator
postfix operator -->  /// ClosedUnboundedUpperRange formation operator
prefix operator <-|   /// UnboundedLowerRange formation operator
prefix operator <--   /// ClosedUnboundedLowerRange formation operator

postfix operator ...  /// Single element closed range.

// MARK: - Convenience comparable negations
infix operator ≮ : ComparisonPrecedence
infix operator ≯ : ComparisonPrecedence
infix operator ≰ : ComparisonPrecedence
infix operator ≱ : ComparisonPrecedence
infix operator !< : ComparisonPrecedence
infix operator !> : ComparisonPrecedence
infix operator !<= : ComparisonPrecedence
infix operator !>= : ComparisonPrecedence
//infix operator ≥ : ComparisonPrecedence
//infix operator ≤ : ComparisonPrecedence

// MARK: - Regular expression and predicate operators

prefix operator ~/  /// RegularExpression formation operator
infix operator ~=>  /// RegularExpression capture

prefix operator ∀  /// NSPredicate formation operator


prefix operator 〖 /// Open lower interval endpoint formation
postfix operator 〗 /// Open upper interval endpoint formation


prefix operator 【 /// Open lower interval endpoint formation
postfix operator 】 /// Open upper interval endpoint formation

infix operator .. : RangeFormationPrecedence
