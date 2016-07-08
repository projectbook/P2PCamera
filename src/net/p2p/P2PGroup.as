package net.p2p 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
	import general.utils.HashMap;
	
	import net.event.UserEvent;

	/**
	 * ...
	 * @author lizhi
	 */
	public class P2PGroup extends NetGroup
	{
		public var users:HashMap = new HashMap();
		public var connnecter:P2PConnecter;
		public var name:String;
		
		public var groupSpecifier:GroupSpecifier;
		private var helpStr:String;
		public function P2PGroup(connection:NetConnection, groupspec:String) 
		{
			super(connection, groupspec);
//			this.groupSpecifier = groupSpecifier;
		}

		public function getUser(id:String):P2PUser
		{
			return users.get(id);
		}
		public function addUser(user:P2PUser):void
		{
			users.put(user.id, user);
			dispatchEvent(new UserEvent(UserEvent.ADD_USER, user));
		}
		
		public function removeUser(id:String):void
		{
			var user:* = users.remove(id);
			dispatchEvent(new UserEvent(UserEvent.REMOVE_USER, user));
		}
		
		public function postMsg(data:Object):void {
			var msg:Object = createMsg(data);
			users.eachValue(function(user:P2PUser):void
			{post(msg);
//				sendToNearest(msg, convertPeerIDToGroupAddress(user.id));
			});
//			for each(var user:P2PUser in users) {
//				helpStr = sendToNearest(msg, convertPeerIDToGroupAddress(user.id));
//			}
		}
		
		public function sendTo(user:String, data:Object):void {
			helpStr = sendToNearest(createMsg(data), convertPeerIDToGroupAddress(user));
		}
		
		public function createMsg(data:Object):Object {
			var msg:Object = { };
			msg.sender = connnecter.nearID;
			msg.data = data;
			return msg;
		}
	}

}