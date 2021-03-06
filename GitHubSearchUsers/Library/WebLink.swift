//The MIT License (MIT)
//
//Copyright (c) 2015 Kyle Fuller
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import Foundation

/// A structure representing a RFC 5988 link.
public struct Link: Equatable, Hashable {
  /// The URI for the link
  public let uri: String

  /// The parameters for the link
  public let parameters: [String: String]

  /// Initialize a Link with a given uri and parameters
  public init(uri: String, parameters: [String: String]? = nil) {
    self.uri = uri
    self.parameters = parameters ?? [:]
  }

  /// Relation type of the Link.
  public var relationType: String? {
    return parameters["rel"]
  }

  /// Reverse relation of the Link.
  public var reverseRelationType: String? {
    return parameters["rev"]
  }

  /// A hint of what the content type for the link may be.
  public var type: String? {
    return parameters["type"]
  }
}

// MARK: HTML Element Conversion
/// An extension to Link to provide conversion to a HTML element
extension Link {
  /// Encode the link into a HTML element
  public var html: String {
    let components = parameters.map { key, value in
      "\(key)=\"\(value)\""
      } + ["href=\"\(uri)\""]
    let elements = components.sorted().joined(separator: " ")
    return "<link \(elements) />"
  }
}

// MARK: Header link conversion
/// An extension to Link to provide conversion to and from a HTTP "Link" header
extension Link {
  /// Encode the link into a header
  public var header: String {
    let components = ["<\(uri)>"] + parameters.map { key, value in
      "\(key)=\"\(value)\""
    }
    return components.sorted().joined(separator: "; ")
  }

  /*** Initialize a Link with a HTTP Link header
  - parameter header: A HTTP Link Header
  */
  public init(header: String) {
    let (uri, parametersString) = takeFirst(separateBy(";")(header))
    let parameters = parametersString.map(split("=")).map { parameter in
      [parameter.0: trim("\"", "\"")(parameter.1)]
    }

    self.uri = trim("<", ">")(uri)
    self.parameters = parameters.reduce([:], +)
  }
}

/*** Parses a Web Linking (RFC5988) header into an array of Links
- parameter header: RFC5988 link header. For example `<?page=3>; rel=\"next\", <?page=1>; rel=\"prev\"`
:return: An array of Links
*/
public func parseLink(header: String) -> [Link] {
  return separateBy(",")(header).map { string in
    return Link(header: string)
  }
}

/// An extension to NSHTTPURLResponse adding a links property
extension HTTPURLResponse {
  /// Parses the links on the response `Link` header
  public var links: [Link] {
    if let linkHeader = allHeaderFields["Link"] as? String {
      return parseLink(header: linkHeader).map { link in
        var uri = link.uri

        /// Handle relative URIs
        if let baseURL = self.url, let relativeURI = URL(string: uri, relativeTo: baseURL)?.absoluteString {
          uri = relativeURI
        }

        return Link(uri: uri, parameters: link.parameters)
      }
    }

    return []
  }

  /// Finds a link which has matching parameters
  public func findLink(_ parameters: [String: String]) -> Link? {
    for link in links {
      if link.parameters ~= parameters {
        return link
      }
    }

    return nil
  }

  /// Find a link for the relation
  public func findLink(relation: String) -> Link? {
    return findLink(["rel": relation])
  }
}

/// MARK: Private methods (used by link header conversion)
/// Merge two dictionaries together
func +<K,V>(lhs: [K:V], rhs: [K:V]) -> [K:V] {
  var dictionary = [K:V]()

  for (key, value) in rhs {
    dictionary[key] = value
  }

  for (key, value) in lhs {
    dictionary[key] = value
  }

  return dictionary
}

/// LHS contains all the keys and values from RHS
func ~=(lhs: [String: String], rhs: [String: String]) -> Bool {
  for (key, value) in rhs {
    if lhs[key] != value {
      return false
    }
  }

  return true
}

/// Separate a trim a string by a separator
func separateBy(_ separator: String) -> (String) -> [String] {
  return { input in
    return input.components(separatedBy: separator).map {
      $0.trimmingCharacters(in: CharacterSet.whitespaces)
    }
  }
}

/// Split a string by a separator into two components
func split(_ separator: String) -> (String) -> (String, String) {
  return { input in
    let range = input.range(of: separator, options: NSString.CompareOptions(rawValue: 0), range: nil, locale: nil)

    if let range = range {
      let lhs = String(input[..<range.lowerBound])
      let rhs = String(input[range.upperBound...])
      return (lhs, rhs)
    }

    return (input, "")
  }
}

/// Separate the first element in an array from the rest
func takeFirst(_ input: [String]) -> (String, ArraySlice<String>) {
  if let first = input.first, first.count > 0 {
    let items = input[input.indices.suffix(from: (input.startIndex + 1))]
    return (first, items)
  }

  return ("", [])
}

/// Trim a prefix and suffix from a string
func trim(_ lhs: Character, _ rhs: Character) -> (String) -> String {
  return { input in
    if input.hasPrefix("\(lhs)") && input.hasSuffix("\(rhs)") {
      return String(input[input.index(after: input.startIndex)..<input.index(before: input.endIndex)])
    }

    return input
  }
}
