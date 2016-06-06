//
//  Presence.swift
//  SwiftPhoenixClient
//

import Swift

public class Presence {
  typealias Dictionary = [String: AnyObject]
  typealias Callback = Void -> AnyObject
  
  /**
   Used to sync the list of presences on the server with the client
   
   - parameter state:    existing list of presences
   - parameter newState: new list of presences
   - parameter onJoin:   join callback
   - parameter onLeave:  leave callback
   */
  func syncState(state: Dictionary, newState: Dictionary, onJoin: Callback, onLeave: Callback) {
    var joins = [Dictionary]()
    var leaves = [Dictionary]()
    
    for (key, presence) in state {
      if (newState[key] == nil) {
        leaves.append([key: presence])
      }
    }
    
    for (key, newPresence) in newState {
      if let currentPresence = state[key] {
        let newRefs = refs(newPresence as! Dictionary)
        let curRefs = refs(currentPresence as! Dictionary)
        let joinedMetas = metas(newPresence as! Dictionary).filter { m
          in curRefs.indexOf(m["phx_ref"] as! String) < 0
        }
        let leftMetas = metas(currentPresence as! Dictionary).filter { m in
          newRefs.indexOf(m["phx_ref"] as! String) < 0
        }
        
        if joinedMetas.count > 0 {
          joins[key] = newPresence
          joins[key]["metas"] = joinedMetas
        }
        
        if leftMetas.count > 0 {
          leaves[key] = currentPresence
          leaves[key]["metas"] = leftMetas
        }
      }
    }
  }
  
  func refs(presence: Dictionary) -> [String] {
    let meta = metas(presence)
    return meta.map { m in m["phx_refs"]! as! String }
  }
  
  func metas(presence: Dictionary) -> [Dictionary] {
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
  func syncDiff(state: Dictionary, joins: Dictionary, leaves: Dictionary, onJoin: Callback, onLeave: Callback) {
    
  }
  
  /**
   Returns a list of presence information based on the metadata
   
   - parameter presences: list of presences
   - parameter chooser: function for choosing metadata
   */
  func list(presences: Dictionary, chooser: Dictionary) {
    
  }
}
