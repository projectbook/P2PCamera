package net.p2p 
{
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.describeType;
	
	import general.utils.HashMap;
	
	
	/**
	 * ...
	 * @author lizhi
	 */
	public class P2PConnecter extends NetConnection
	{
		public var groups:Vector.<P2PGroup>=new Vector.<P2PGroup>;
		public var users:HashMap = new HashMap();
		
		public var receiveFun:Function;
		
		public function P2PConnecter() 
		{
		}
		
		public function getUser(id:String):P2PUser {
			return users.get(id);
		}
		
		public function addUser(id:String):P2PUser
		{
			var user:P2PUser = getUser(id);
			if (user == null)
			{
				user = new P2PUser();
				user.id = id;
				users.put(id, user);
			}
			return user;
		}
		
		public function removeUser(id:String):P2PUser
		{
			return users.remove(id);
		}
		
		public function connectSuccess():void {
			dispatchEvent(new Event(Event.CONNECT));
		}
		
		public function startGroup(group:P2PGroup):void {
			var p2pGroup:P2PGroup = group;
			group.connnecter = this;
//			var netg:NetGroup = new NetGroup(this, p2pGroup.groupSpecifier.groupspecWithAuthorizations());
			groups.push(p2pGroup);
//			netg.addEventListener(NetStatusEvent.NET_STATUS, onNetGroupStatus);
		}
		
		private function onNetConnectionStatus(e:NetStatusEvent):void 
		{
			switch(e.info.code)
			{
				case "NetConnection.Connect.Success":
				{
					connectSuccess();
					break;
				}
				case "NetGroup.Connect.Success":
				{
					trace(describeType(e.info));
					// 连上
				}
				default:
				{
					break;
				}
			}
		}
		private function onNetGroupStatus(e:NetStatusEvent):void 
		{
			var group:P2PGroup = e.currentTarget as P2PGroup;
			switch(e.info.code)
			{
				case "NetGroup.Connect.Success":
				{
					//group.connectSuccess();
					break;
				}
				case "NetGroup.Posting.Notify":
				{
					receive(group, getUser(e.info.message.sender),e.info.message.data);
					break;
				}
				case "NetGroup.SendTo.Notify":
				{
					receive(group, getUser(e.info.message.sender),e.info.message.data);
					break;
				}
				case "NetGroup.Neighbor.Connect":
				{
					var user:P2PUser = new P2PUser();
					user.id = e.info.peerID;
					user.name = "???";
					group.addUser(user);
					break;
				}
				case "NetGroup.Neighbor.Disconnect":
				{
					group.removeUser(e.info.peerID);
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		public function receive(group:P2PGroup, user:P2PUser, data:Object):void {
			if (receiveFun!=null) {
				receiveFun(group, user, data);
			}
		}
	}
	
}