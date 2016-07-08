package net.event 
{
	import flash.events.Event;
	
	import net.p2p.P2PUser;

	/**
	 * ...
	 * @author lizhi
	 */
	public class UserEvent extends Event
	{
		public static const ADD_USER:String = "adduser";
		public static const REMOVE_USER:String = "removeuser";
		
		public var user:P2PUser;
		public function UserEvent(type:String,user:P2PUser) 
		{
			super(type);
			this.user = user;
			
		}
		
	}

}