import Foundation

extension SHACLTurtleSubsetParser {
    func tokenize(_ statement: String) throws -> [String] {
        var tokens: [String] = []
        var index = statement.startIndex

        while index < statement.endIndex {
            let ch = statement[index]

            if ch.isWhitespace {
                index = statement.index(after: index)
                continue
            }

            if ch == "{",
               statement.index(after: index) < statement.endIndex,
               statement[statement.index(after: index)] == "|" {
                tokens.append("{|")
                index = statement.index(index, offsetBy: 2)
                continue
            }

            if ch == "|",
               statement.index(after: index) < statement.endIndex,
               statement[statement.index(after: index)] == "}" {
                tokens.append("|}")
                index = statement.index(index, offsetBy: 2)
                continue
            }

            if ch == ";" || ch == "," || ch == "(" || ch == ")" || ch == "[" || ch == "]" {
                tokens.append(String(ch))
                index = statement.index(after: index)
                continue
            }

            if ch == "<" {
                guard let close = statement[index...].firstIndex(of: ">") else {
                    throw SHACLError.invalidStatement(statement)
                }
                tokens.append(String(statement[index...close]))
                index = statement.index(after: close)
                continue
            }

            if ch == "\"" {
                let next = statement.index(after: index)
                let isLongLiteral = next < statement.endIndex
                    && statement[next] == "\""
                    && statement.index(after: next) < statement.endIndex
                    && statement[statement.index(after: next)] == "\""

                var end: String.Index
                if isLongLiteral {
                    end = statement.index(index, offsetBy: 3)
                    while end < statement.endIndex {
                        if statement[end] == "\"",
                           statement.index(after: end) < statement.endIndex,
                           statement[statement.index(after: end)] == "\"",
                           statement.index(end, offsetBy: 2) < statement.endIndex,
                           statement[statement.index(end, offsetBy: 2)] == "\"" {
                            end = statement.index(end, offsetBy: 2)
                            break
                        }
                        end = statement.index(after: end)
                    }
                } else {
                    end = statement.index(after: index)
                    var escaped = false
                    while end < statement.endIndex {
                        let c = statement[end]
                        if c == "\\" && !escaped {
                            escaped = true
                            end = statement.index(after: end)
                            continue
                        }
                        if c == "\"" && !escaped {
                            break
                        }
                        escaped = false
                        end = statement.index(after: end)
                    }
                }

                guard end < statement.endIndex else {
                    throw SHACLError.invalidStatement(statement)
                }

                var token = String(statement[index...end])
                var probe = statement.index(after: end)

                if probe < statement.endIndex, statement[probe] == "@" {
                    let langStart = probe
                    probe = statement.index(after: probe)
                    var langEnd = probe
                    while langEnd < statement.endIndex,
                          !statement[langEnd].isWhitespace,
                          statement[langEnd] != ";",
                          statement[langEnd] != ",",
                          statement[langEnd] != ")",
                          statement[langEnd] != "]" {
                        langEnd = statement.index(after: langEnd)
                    }
                    token += String(statement[langStart..<langEnd])
                    probe = langEnd
                } else if probe < statement.endIndex, statement[probe] == "^" {
                    let typedNext = statement.index(after: probe)
                    guard typedNext < statement.endIndex, statement[typedNext] == "^" else {
                        throw SHACLError.invalidStatement(statement)
                    }
                    probe = statement.index(after: typedNext)
                    var dtEnd = probe
                    while dtEnd < statement.endIndex,
                          !statement[dtEnd].isWhitespace,
                          statement[dtEnd] != ";",
                          statement[dtEnd] != ",",
                          statement[dtEnd] != ")",
                          statement[dtEnd] != "]" {
                        dtEnd = statement.index(after: dtEnd)
                    }
                    token += "^^" + String(statement[probe..<dtEnd])
                    probe = dtEnd
                }

                tokens.append(token)
                index = probe
                continue
            }

            if ch == "'" {
                var end = statement.index(after: index)
                var escaped = false
                while end < statement.endIndex {
                    let c = statement[end]
                    if c == "\\" && !escaped {
                        escaped = true
                        end = statement.index(after: end)
                        continue
                    }
                    if c == "'" && !escaped {
                        break
                    }
                    escaped = false
                    end = statement.index(after: end)
                }

                guard end < statement.endIndex else {
                    throw SHACLError.invalidStatement(statement)
                }

                let rawLexical = String(statement[statement.index(after: index)..<end])
                let unescapedLexical = rawLexical
                    .replacingOccurrences(of: "\\'", with: "'")
                    .replacingOccurrences(of: "\\\\", with: "\\")
                let escapedLexical = unescapedLexical.replacingOccurrences(of: "\"", with: "\\\"")
                var token = "\"\(escapedLexical)\""
                var probe = statement.index(after: end)

                if probe < statement.endIndex, statement[probe] == "@" {
                    let langStart = probe
                    probe = statement.index(after: probe)
                    var langEnd = probe
                    while langEnd < statement.endIndex,
                          !statement[langEnd].isWhitespace,
                          statement[langEnd] != ";",
                          statement[langEnd] != ",",
                          statement[langEnd] != ")",
                          statement[langEnd] != "]" {
                        langEnd = statement.index(after: langEnd)
                    }
                    token += String(statement[langStart..<langEnd])
                    probe = langEnd
                } else if probe < statement.endIndex, statement[probe] == "^" {
                    let typedNext = statement.index(after: probe)
                    guard typedNext < statement.endIndex, statement[typedNext] == "^" else {
                        throw SHACLError.invalidStatement(statement)
                    }
                    probe = statement.index(after: typedNext)
                    var dtEnd = probe
                    while dtEnd < statement.endIndex,
                          !statement[dtEnd].isWhitespace,
                          statement[dtEnd] != ";",
                          statement[dtEnd] != ",",
                          statement[dtEnd] != ")",
                          statement[dtEnd] != "]" {
                        dtEnd = statement.index(after: dtEnd)
                    }
                    token += "^^" + String(statement[probe..<dtEnd])
                    probe = dtEnd
                }

                tokens.append(token)
                index = probe
                continue
            }

            var end = index
            while end < statement.endIndex,
                  !statement[end].isWhitespace,
                  statement[end] != ";",
                  statement[end] != ",",
                  statement[end] != "(",
                  statement[end] != ")",
                  statement[end] != "[",
                  statement[end] != "]",
                  statement[end] != "{",
                  statement[end] != "|" {
                end = statement.index(after: end)
            }

            tokens.append(String(statement[index..<end]))
            index = end
        }

        return tokens
    }
}
