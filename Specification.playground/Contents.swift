import UIKit


public protocol Specification {
	
	func and(other: Specification) -> Specification
	func or(other: Specification) -> Specification
	func IsSatisfiedBy(candidate: Any) -> Bool


}

extension Specification {
	
	public func and(other: Specification) -> Specification {
		return AndSpecification(leftCondition: self, rightCondition: other)
	}
	
	public func or(other: Specification) -> Specification {
		return OrSpecification(leftCondition: self, rightCondition: other)
	}
	
}

public class AndSpecification : Specification {

	private let leftCondition: Specification
	private let rightCondition: Specification

	init(leftCondition: Specification, rightCondition: Specification) {

		self.leftCondition = leftCondition
		self.rightCondition = rightCondition
	}

	public func IsSatisfiedBy(candidate: Any) -> Bool {

		return leftCondition.IsSatisfiedBy(candidate: candidate) && rightCondition.IsSatisfiedBy(candidate: candidate)
	}
}

public class OrSpecification: Specification {
	private let leftCondition: Specification
	private let rightCondition: Specification

	init(leftCondition: Specification, rightCondition: Specification) {

		self.leftCondition = leftCondition
		self.rightCondition = rightCondition
	}

	public func IsSatisfiedBy(candidate: Any) -> Bool {

		return leftCondition.IsSatisfiedBy(candidate: candidate) ||
               rightCondition.IsSatisfiedBy(candidate: candidate)
	}
}

public class RegexSpecification: Specification {
	public let regex: NSRegularExpression
	 init(pattern: String) {
		self.regex = try! NSRegularExpression(pattern: pattern, options: [])
	}

  	public func IsSatisfiedBy(candidate: Any) -> Bool {
		guard let value = candidate as? String else { return false }
		return regex.numberOfMatches(in: value, options: [],
                                                 range: NSMakeRange(0, value.count)) > 0
	}
  
}


func == (lhs: Specification, rhs: Any) -> Bool {
	return lhs.IsSatisfiedBy(candidate: rhs)
}

let emailRegex = RegexSpecification(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
let phoneRegex = RegexSpecification(pattern: "^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]\\d{3}[\\s.-]\\d{4}$")


let result =  emailRegex.or(other: phoneRegex)

emailRegex == "ahmed.almasri@ymail.com"
result == "ahmed.almasri@ymail.com"
result == "ahmed.almasri"
result == "123-456-7890"


