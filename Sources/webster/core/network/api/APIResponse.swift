//
// APIResponse.swift
//

/// A response from an Network API call
public enum APIResponse<Value> {
    case success(Value)
    case failure(Error)
}
