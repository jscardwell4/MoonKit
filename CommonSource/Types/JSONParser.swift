//
//  JSONParser.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/2/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/**

`JSONParser` is a simple class for parsing a JSON string into an object. The following grammar is used for parsing.
*note: All whitespace excluding that which appears inside a quoted string is ignored.

start → array | object

object → left-curly-bracket key-value-pairs? right-curly-bracket

key-value-pairs → key-value (comma key-value)*

key-value → string colon value

array → left-square-bracket values? right-square-bracket

values → value (comma value)*

value → 'null'

value → 'true'

value → 'false'

value → number

value → string

value → array

value → object

string → " ­character* "

character → Any Unicode character except for ", ⏎, \

character → \ ["\/bfnrt]

character → \ u [0-9A-F]{4}

number →  -? [0-9]+ (. [0-9]+)? ([eE] [+-]? [0-9]+)?

comment → '/' '/' non-return-character* '⏎'

comment → '/' '*' (non-asterisk-character | '*' non-solidus-character)* '*' '/'

non-return-character → Any Unicode character except for ⏎

non-asterisk-character → Any Unicode character except for *

non-solidus-character → Any Unicode character except for /

comma → comment? ',' comment?

colon → comment? ':' comment?

left-curly-bracket → comment? '{' comment?

right-curly-bracket → comment? '}' comment?

left-square-bracket → comment? '[' comment?

right-square-bracket → comment? ']' comment?


*/
public final class JSONParser {

  public var string: String { return scanner.string }
  public let allowFragment: Bool
  public let ignoreExcess: Bool
  public var idx: String.Index { get { scanner.currentIndex } set { scanner.currentIndex = newValue } }

  fileprivate var contextStack: Stack<Context>   = []
  fileprivate var objectStack:  Stack<JSONValue> = []
  fileprivate var keyStack:     Stack<String>    = []
  fileprivate let scanner:      Scanner

  /**
  initWithString:

  - parameter string: String
  */
  public init(string: String, allowFragment: Bool = false, ignoreExcess: Bool = false) {
    scanner = Scanner.localizedScanner(with: string) as! Scanner
    self.allowFragment = allowFragment
    self.ignoreExcess = ignoreExcess
  }


  // MARK: - Error handling and debugging



  /** Parser error domain and error codes */
  public let JSONParserErrorDomain = "JSONParserErrorDomain"
  public enum JSONParserErrorCode: Int { case `internal`, invalidSyntax }

  /**
  - parameter code: JSONParserErrorCode
  - parameter reason: String?
  
  - returns: NSError
  */
  fileprivate func errorWithCode(_ code: JSONParserErrorCode,
                    _ reason: String?,
             underlyingError: NSError? = nil) -> NSError
  {

      // Create the info dictionary for our new error object
      var info = [String:Any]()

      // Check if we have been provided with an underlying error
      if let providedUnderlyingError = underlyingError {

        // Check if we just added an existing error to the dicitonary in the above if clause
        if let existingError = info[NSUnderlyingErrorKey] as? NSError {

          // Add them both as an array
          info[NSUnderlyingErrorKey] = [existingError, providedUnderlyingError]

        }

          // Otherwise just add the underlying error provided
        else {

          info[NSUnderlyingErrorKey] = providedUnderlyingError

        }

      }

      // Check if we are given a reason for the error
      if let failureReason = reason {

        // Add the reason to our dictionary with the current scanner location appended
        info[NSLocalizedFailureReasonErrorKey] = "\(failureReason) near location \(idx)"

      }

      // Finally, set the pointer's memory to a new error object
      return NSError(domain: JSONParserErrorDomain, code: code.rawValue, userInfo: info)
  }

  /**
  - parameter reason: String?
  - parameter underlyingError: NSError? = nil

  - returns: NSError
  */
  fileprivate func internalError(_ reason: String?, underlyingError: NSError? = nil) -> NSError {
    return errorWithCode(.internal, reason, underlyingError: underlyingError)
  }

  /**
  - parameter reason: String?
  - parameter underlyingError: NSError? = nil

  - returns: NSError
  */
  fileprivate func syntaxError(_ reason: String?, underlyingError: NSError? = nil) -> NSError {
    return errorWithCode(.invalidSyntax, reason, underlyingError: underlyingError)
  }

  /**
  dumpState
  */
  fileprivate func dumpState(_ error: NSError? = nil) {
    print("scanner.atEnd? \(scanner.isAtEnd)\nidx: \(idx)")
    print("keyStack[\(keyStack.count)]: " + ", ".join(keyStack.map{"'\($0)'"}))
    print("contextStack[\(contextStack.count)]: " + ", ".join(contextStack.map{$0.rawValue}))
    print("objectStack[\(objectStack.count)]:\n" + "\n".join(objectStack.map{String(describing: $0)}))
    if error != nil {
      print("error: \(error!))")
    }
  }


  // MARK: - Scanning the string

  /** Enumeration to represent the current parser state */
  fileprivate enum Context: String {
    case Start  = "start"
    case Object = "object"
    case Value  = "value"
    case Array  = "array"
    case Key    = "key"
    case End    = "end"
  }

  /** Enumeration for specifying a type of scan to perform */
  fileprivate enum ScanType {
    case charactersFromSet     (CharacterSet)
    case upToCharactersFromSet (CharacterSet)
    case text                  (String)
    case upToText              (String)
    case number
  }

  /**
  scanFor:into:discardingComments:skipping:error:

  - parameter type: ScanType
  - parameter object: AnyObject?
  - parameter discardingComments: Bool = true
  - parameter skipCharacters: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()

  - returns: Bool
  */
  fileprivate func scanFor(_ type: ScanType,
            into object: inout AnyObject?,
    discardingComments: Bool = true,
              skipping skipCharacters: CharacterSet = CharacterSet.whitespacesAndNewlines) -> Bool
  {
    if discardingComments { do { try scanComment() } catch {} }

    let currentSkipCharacters = scanner.charactersToBeSkipped
    scanner.charactersToBeSkipped = skipCharacters
    defer { scanner.charactersToBeSkipped = currentSkipCharacters }

    switch type {

    case .charactersFromSet(let set):
      object = scanner.scanCharacters(from: set) as AnyObject?

    case .upToCharactersFromSet(let set):
      object = scanner.scanUpToCharacters(from: set) as AnyObject?

    case .text (let text):
      object = scanner.scanString(text) as AnyObject?

    case .upToText(let text):
      object = scanner.scanUpToString(text) as AnyObject?

    case .number:
      object = scanner.scanDouble() as AnyObject?

    }

//    scanner.charactersToBeSkipped = currentSkipCharacters
    if discardingComments { do { try scanComment() } catch {} }

    return object != nil
    
  }

  /** scanComment */
  fileprivate func scanComment() throws {

    var scannedObject: AnyObject?

    // Try scanning the for solidus characters
    if scanFor(.charactersFromSet(CharacterSet(charactersIn: "/" )),
      into: &scannedObject, discardingComments: false) {

        if let scannedString = scannedObject as? String {

          if scannedString.hasPrefix("//") {

            _ = scanFor(.upToCharactersFromSet(CharacterSet.newlines),
              into: &scannedObject, discardingComments: false, skipping: CharacterSet(charactersIn: ""))

          }

          else if scanFor(.charactersFromSet(CharacterSet(charactersIn: "*" )),
            into: &scannedObject, discardingComments: false, skipping: CharacterSet(charactersIn: ""))
          {
            if !scanFor(.upToText("*/"), into: &scannedObject, discardingComments: false) {
              throw syntaxError("open-ended multi-line comment")
            }

            else { _ = scanFor(.text("*/"), into: &scannedObject, discardingComments: false) }

          }

          else {
            throw syntaxError("malformed comment detected")
          }

        }

        else {
          throw internalError("scan succeeded but scanned object is empty")
        }

    }

  }

  /**
  scanNumber:

  - parameter number: AnyObject?

  - returns: Bool
  */
  fileprivate func scanNumber(_ number:inout AnyObject?) -> Bool { return scanFor(.number, into: &number) }

  /**
  scanQuotedString:error:

  - parameter string: AnyObject?
  - parameter error: NSErrorPointer

  - returns: Bool
  */
  fileprivate func scanQuotedString(_ string:inout AnyObject?) throws -> Bool {
    var scannedObject: AnyObject?
    var success = false

    if scanFor(.text("\""), into: &scannedObject) {

      var scannedString = ""

      // Check if we have an empty string
      if scanFor(.text("\""), into: &scannedObject) { success = true }

      else {

        while !success && scanFor(.upToCharactersFromSet(CharacterSet(charactersIn: "\"")),
          into: &scannedObject, skipping: CharacterSet(charactersIn: ""))
        {
          // Make sure we scanned something and that we didn't scan up to an escaped quotation mark
          if let s = scannedObject as? String {

            scannedString += s // Append what we just scanned to accumulating string

            // Set success if our quotation mark was not escaped
            if !s.hasSuffix("\\") { success = true }

          }

        }

        // At this point, to be valid syntax we must have scanned an opening quotation mark,
        // some text, and be sitting on an unescaped quotation mark
        if !(success && scanFor(.text("\""), into: &scannedObject, skipping: CharacterSet(charactersIn: ""))) {

          success = false
          throw syntaxError("unmatched double quote")

        }

      }

      // If we have succeeded, be sure to set the inout parameter to our accumulated string
      if success { string = scannedString as AnyObject
      }

    }

    return success

  }


  // MARK: - Parsing the string



  /**
  parseObject:

  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  fileprivate func parseObject() throws -> Bool {

    var success = false
    var scannedObject: AnyObject?

    // Try to scan the opening punctuation for an object
    if scanFor(.text("{"), into: &scannedObject) {

      success = true
      objectStack.push(.object([:])) // Push a new dictionary onto the object stack
      contextStack.push(.Object)     // Push object context
      contextStack.push(.Key)        // Push key context


    }

    // Then try to scan a comma separating another object key value pair
    else if scanFor(.text(","), into: &scannedObject) {
        success = true
        contextStack.push(.Key)
    }

      // Lastly, try to scan the closing punctuation for an object
    else if scanFor(.text("}"), into: &scannedObject) {

          // Pop context and object stacks
          if let context = contextStack.pop(), let object = objectStack.pop() {

            switch (context, object) {

              case (_, _) where contextStack.peek == .Start:
                // Replace start context with end context if we have completed the root object
                contextStack.pop()
                contextStack.push(.End)
                objectStack.push(object)
                success = true

              case (.Object, .object(_)):
                do { try addValueToTopObject(object); success = true } catch { throw error }

              case (_, .object(_)):

                throw internalError("incorrect context popped off of stack")

              case (.Object, _):
                throw internalError("dictionary absent from object stack")

              default:
                assert(false, "shouldn't this be unreachable?")
            }

          }

          else {
            throw internalError("one or both of context and object stacks is empty")
      }

    }

    return success
  }

  /**
  parseArray:

  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  fileprivate func parseArray() throws -> Bool {

    var success = false
    var scannedObject: AnyObject?

    // Try to scan the opening punctuation for an object
    if scanFor(.text("["), into: &scannedObject) {

      success = true
      objectStack.push(.array([])) // Push a new array onto the object stack
      contextStack.push(.Array)    // Push the array context
      contextStack.push(.Value)    // Push the value context

    }

      // Then try to scan a comma separating another object key value pair
    else if scanFor(.text(","), into: &scannedObject) {
        success = true
        contextStack.push(.Value)
    }

      // Lastly, try to scan the closing punctuation for an object
    else if scanFor(.text("]"), into: &scannedObject) {

          // Pop context and object stacks
          if let context = contextStack.pop(), let object = objectStack.pop() {

            switch (context, object) {
            case (_, _) where contextStack.peek == .Start:
              // Replace start context with end context if we have completed the root object
              contextStack.pop()
              contextStack.push(.End)
              objectStack.push(object)
              success = true

            case (.Array, .array(_)):
              do {
                try addValueToTopObject(object)
                success = true
              } catch {
                throw error
              }

            case (_, .array(_)):
              throw internalError("incorrect context popped off of stack")

            case (.Array, _):
              throw internalError("array absent from object stack")

            default:
              assert(false, "shouldn't this be unreachable?")
            }
          }

          else {
            throw internalError("one or both of context and object stacks is empty")
      }

    }
    return success
  }

  /**
  parseValue:

  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  @discardableResult
  fileprivate func parseValue() throws -> Bool {

    var success = false
    var value: JSONValue?
    var scannedObject: AnyObject?

    if !(contextStack.pop() == Context.Value) {
      throw internalError("incorrect context popped off of stack")
    }

    // Try scanning a true literal
    if scanFor(.text("true"), into: &scannedObject) {
      value = true
      success = true
    }

      // Try scanning a false literal
    else if scanFor(.text("false"), into: &scannedObject) {
        value = false
        success = true
    }

      // Try scanning a null literal
    else if scanFor(.text("null"), into: &scannedObject) {
          value = .null
          success = true
    }

      // Try scanning a number
    else if scanFor(.number, into: &scannedObject) {
            value = .number(scannedObject as! NSNumber)
            success = true
    }

    else {
      do {
        // Try scanning a string
        if (try scanQuotedString(&scannedObject)) {
          value = .string(scannedObject as! Swift.String)
          success = true
        } else if (try parseObject()) {
          success = true
        } else if (try parseArray()) {
          success = true
        } else {
          throw syntaxError("failed to parse value")
        }
      } catch {
        throw error
      }
    }

    // If we have a value, add it to the top object in our stack
    if let v = value , success {
      do {
        try addValueToTopObject(v)
      } catch {
        throw error
      }
    }

    return success

  }

  /**
  parseKey:

  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  fileprivate func parseKey() throws -> Bool {

    var localError = false
    var scannedObject: AnyObject?

    do {
      if (try scanQuotedString(&scannedObject)) {
        if contextStack.pop() != .Key {
          localError = true
          throw internalError("incorrect context popped off of stack")
        } else if let key = scannedObject as? String {
          keyStack.push(key)

          // Parse the delimiting colon
          if !scanFor(.text(":"), into: &scannedObject) {
            localError = true
            throw syntaxError("missing colon after key")
          }

            // Push value context and set success if we found the colon
          else { contextStack.push(.Value); return true }
        }
      } else {
        return false
      }
    } catch {
      throw localError ? error : syntaxError("missing key for object element", underlyingError: error as NSError)
    }

    return false
  }


  /**
  addValueToTopObject:error:

  - parameter value: AnyObject
  - parameter error: NSErrorPointer = nil

  - returns: Bool
  */
  fileprivate func addValueToTopObject(_ value: JSONValue) throws {

    if let context = contextStack.peek, let object = objectStack.pop() {

      switch (context, object) {
        case (.Object, .object(var d)):
          if let k = keyStack.pop() {
            d[k] = value
            objectStack.push(.object(d))
          } else {
            throw internalError("empty key stack")
        }

        case (.Array, .array(var a)):
          a.append(value)
          objectStack.push(.array(a))

        case (_, .object(_)),
             (_, .array(_)):
          throw internalError("invalid context-object pairing: \(context)-\(object)")

        case (.Object, _),
             (.Array, _):
          throw internalError("missing object in stack to receive new value")

        default:
          assert(false, "should be unreachable?")
      }

    } else if allowFragment && objectStack.isEmpty {
      objectStack.push(value)
      if contextStack.peek == .Start { contextStack.pop(); contextStack.push(.End) }
    } else if contextStack.isEmpty && objectStack.isEmpty {
      throw internalError("empty stacks")
    } else if contextStack.isEmpty {
      throw internalError("empty context stack")
    } else if objectStack.isEmpty {
      throw internalError("empty object stack")
    } else {
      throw internalError("an unknown internal error has occurred")
    }
  }

  /**
  parse:

  - parameter error: NSErrorPointer = nil

  - returns: JSONValue?
  */
  public func parse() throws -> JSONValue {

    // Start in a known context
    contextStack.push(.Start)

    // Scan while we have input, completing the root object will exit the loop even if text remains
    scanLoop: while !scanner.isAtEnd {

      // We must have a context on top of the context stack
      if let context = contextStack.peek {

        // Perform a context-appropriate action
        switch context {

          // To be valid, we must be able to scan an opening bracked of some kind
          case .Start:

            // Check if we are allowing the string to be a json fragment
            if allowFragment {
              contextStack.push(.Value)
              do { try parseValue() }
              catch { throw syntaxError("root is not a valid json fragment", underlyingError: error as NSError) }

            }

            // Set error if we fail to match the start of an array or an object and exit loop
            else {
              var didParse = false
              do {
                didParse = try parseObject()
                if !didParse { didParse = try parseArray() }
              } catch { throw error }
              if !didParse { throw syntaxError("root must be an object/array") }
            }

          // Try to scan a number, a boolean, null, the start of an object, or the start of an array
          case .Value: do { if !(try parseValue()) { break scanLoop } } catch { throw error }

          // Try to scan a comma or curly bracket
          case .Object: do { if !(try parseObject()) { break scanLoop } } catch { throw error }

          // Try to scan a comma or square bracket
          case .Array: do { if !(try parseArray()) { break scanLoop } } catch { throw error }

          // Try to scan a quoted string for use as a dictionary key
          case .Key: do { if !(try parseKey()) { break scanLoop } } catch { throw error }

          // Just break out of scan loop
          case .End:
            if !(scanner.isAtEnd || ignoreExcess) { throw syntaxError("parse completed but scanner is not at end") }
            break scanLoop
        }

      }


    }

    // If the root object ends the text we won't hit the `.End` case in our switch statement
    if !objectStack.isEmpty {

      // Make sure we don't have more than one object left in the stack
      if objectStack.count > 1 { throw internalError("objects left in stack") }

      // Otherwise pop the root object from the stack
      else { return objectStack.pop()! }

    } else { throw syntaxError("failed to parse anything") }

  }

}
