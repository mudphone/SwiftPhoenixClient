//
//  Presence.swift
//  SwiftPhoenixClient
//

import Swift

public class Presence {
  typealias Dictionary = [String: AnyObject]
  typealias State = [String: Dictionary]
  typealias Callback = (String, Dictionary, Dictionary) -> Void
  
  /**
   Used to sync the list of presences on the server with the client
   
   Collect the new "joins" and "leaves" (and associated metadata),
   and pass to `syncDiff`. For more info on the Presence datastructure
   see: https://hexdocs.pm/phoenix/Phoenix.Presence.html#list/2
   
   - parameter state:    existing list of presences
   - parameter newState: new list of presences
   - parameter onJoin:   join callback
   - parameter onLeave:  leave callback
   */
  func syncState(state: State, newState: State, onJoin: Callback, onLeave: Callback) {
    var joins  = State()
    var leaves = State()
    
    for (key, presence) in state {
      if (newState[key] == nil) {
        leaves[key] = presence
      }
    }
    
    for (key, newPresence) in newState {
      if let currentPresence = state[key] {
        let newRefs = refs(newPresence)
        let curRefs = refs(currentPresence)
        let joinedMetas = metas(newPresence).filter {
          if let ref = $0["phx_ref"] as? String {
            return !curRefs.contains(ref)
          }
          else { return false }
        }
        let leftMetas = metas(currentPresence).filter {
          if let ref = $0["phx_ref"] as? String {
            return !newRefs.contains(ref)
          }
          else { return false }
        }
        
        if joinedMetas.count > 0 {
          var upd = newPresence
          upd["metas"] = joinedMetas as AnyObject?
          joins[key] = upd
        }
        
        if leftMetas.count > 0 {
          var upd = currentPresence
          upd["metas"] = leftMetas as AnyObject?
          leaves[key] = upd
        }
      } else {
        joins[key] = newPresence
      }
    }
    return syncDiff(state: state, joins: joins, leaves: leaves, onJoin: onJoin, onLeave: onLeave)
  }
  
  func refs(_ presence: Dictionary) -> [String] {
    let meta = metas(presence)
    return meta.map { m in m["phx_refs"]! as! String }
  }
  
  func metas(_ presence: Dictionary) -> [Dictionary] {
    if let meta = presence["metas"] {
      return meta as! [Dictionary]
    } else {
      return [Dictionary]()
    }
  }
  
  /**
   Syncs a diff of the presence join and leave events from the server
   
   - parameter state:   presence list
   - parameter joins:   join events
   - parameter leaves:  leave events
   - parameter onJoin:  join callback
   - parameter onLeave: leave callback
   */
  func syncDiff(state: State, joins: State, leaves: State, onJoin: Callback, onLeave: Callback) {
    
  }
  
  /**
   Returns a list of presence information based on the metadata
   
   - parameter presences: list of presences
   - parameter chooser: function for choosing metadata
   */
  func list(presences: Dictionary, chooser: Dictionary) {
    
  }
}
