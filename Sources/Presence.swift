//
//  Presence.swift
//  SwiftPhoenixClient
//

import Swift

public class Presence {
  public typealias Dictionary = [String: AnyObject]
  public typealias State = [String: Dictionary]
  public typealias Callback = (String, Dictionary?, Dictionary?) -> ()
  
  static func voidCallback(key: String, currentPresence: Dictionary?, newPresence: Dictionary?) -> () {}
  
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
  func syncState(state: State, newState: State, onJoin: Callback, onLeave: Callback) -> State {
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
          !curRefs.contains($0["phx_ref"] as! String)
        }
        let leftMetas = metas(currentPresence).filter {
          !newRefs.contains($0["phx_ref"] as! String)
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
    return meta.map { $0["phx_refs"]! as! String }
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
  func syncDiff(state: State, joins: State, leaves: State,
                onJoin: Callback = Presence.voidCallback,
                onLeave: Callback = Presence.voidCallback ) -> State {
  
    var newState = state
    
    for (key, newPresence) in joins {
      let currentPresence = state[key]
      if let currentPresence = currentPresence {
        var upd = newPresence
        upd["metas"] = [metas(newPresence), metas(currentPresence)].joined() as AnyObject?
        newState[key] = upd
      } else {
        newState[key] = newPresence
      }
      onJoin(key, currentPresence, newPresence)
    }
    
    for (key, leftPresence) in leaves {
      if let currentPresence = state[key] {
        let refsToRemove = refs(leftPresence)
        var upd = currentPresence
        let updMetas = metas(currentPresence).filter {
          !refsToRemove.contains($0["phx_ref"] as! String)
        }
        upd["metas"] = updMetas as AnyObject?
        onLeave(key, currentPresence, leftPresence)
        
        if metas(currentPresence).isEmpty {
          newState.removeValue(forKey: key)
        }
      }
    }
    
    return newState
  }
  
  /**
   Returns a list of presence information based on the metadata
   
   - parameter presences: list of presences
   - parameter chooser: function for choosing metadata
   */
  func list(presences: Dictionary, chooser: Dictionary) {
    
  }
}
