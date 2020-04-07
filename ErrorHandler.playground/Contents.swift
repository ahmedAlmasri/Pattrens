
import Foundation


public typealias HandleAction<T> = (T) throws -> ()

public protocol ErrorHandleable: AnyObject {
	associatedtype Parent: ErrorHandleable
    func `throw`(_ error: Error, finally: @escaping (Bool) -> Void)
    func `catch`(action: @escaping HandleAction<Error>) -> Parent
	init(action: @escaping HandleAction<Error>, parent: Parent?)
}

public extension ErrorHandleable {
	
	func `catch`<T: Error&Equatable>( value: T, action: @escaping HandleAction<Error>) -> Parent {
		
		return `catch` { (error) in
			if (error as? T) == value {
				try action(error)
			}else {
				throw error
			}
		}
	}
}

class ErrorHandler: ErrorHandleable {
	
	private var parent: ErrorHandler?
	private let action: HandleAction<Error>
	
	convenience init(action: @escaping HandleAction<Error> = { throw $0 }) {
		self.init(action: action, parent: nil)
	}
	
	required init(action: @escaping HandleAction<Error>, parent: ErrorHandler?) {
		self.action = action
		self.parent = parent
	}
	
	func `throw`(_ error: Error, finally: @escaping (Bool) -> Void) {
		
		`throw`(error, previous: [], finally: finally)
	}
	
	private func `throw`(_ error: Error, previous: [ErrorHandler], finally: @escaping (Bool) -> Void) {
		
		if let parent = parent {
			
			parent.throw(error, previous: previous + [self], finally: finally)
			
			return
			
		}
		
		exe(error, previous: previous.reversed(), finally: finally)
	}
	
	private func exe(_ error: Error, previous: [ErrorHandler], finally: @escaping (Bool) -> Void) {
		
		do {
			try action(error)
			
		}catch {
			
			 if let nextHandler = previous.first {
				nextHandler.exe(error, previous: Array(previous.dropFirst()), finally: finally)
			}
		}
	}
	
	func `catch`(action: @escaping HandleAction<Error>) -> ErrorHandler {
		
		return ErrorHandler(action: action, parent: self)
	}
	
	
}

enum MyError: Error {
	
	case error1
 case error2
 case error3
}
do {
	
	let error = ErrorHandler().catch(value: MyError.error1) { (_) in
		print("Error 1")
	}.catch(value: MyError.error2) { (_) in
		print("Error 2")
	}.catch { (error) in
		print("errooooooor")
	}
	
	error.throw(MyError.error3) { (_) in
		
	}
}

