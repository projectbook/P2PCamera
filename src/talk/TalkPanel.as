package talk {
	import com.bit101.components.HBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import general.utils.HashMap;
	
	import net.p2p.P2PUser;
	
	import ui.ImageTextArea;

	/**
	 * ...
	 * @author lizhi
	 */
	public class TalkPanel extends EventDispatcher
	{
		public static const POST_EVENT:String = "postevent";
		public static const CUTOVER_EVENT:String = "cutoverevent";
//		public static const FILEOVER_EVENT:String = "fileoverevent";
		public static const CLICKUSER_EVENT:String = "clickUserEvent";
		
		private var con:ImageTextArea;
		private var list:VBox;
		public var input:TextArea;
		public var btn2user:Dictionary = new Dictionary;
		private var file:FileReference;
		public var isGroup:Boolean;
		
		public var currentBmd:BitmapData;
		public var currentByte:ByteArray;
		public var currentUser:P2PUser;
		
		private var panel:Window;
		
		public var useNativeWindow:Boolean = false;
		private var wrapper:Sprite = new Sprite;
		private var user:P2PUser;
		private var fileCode:int;
		private var filesDir:Array = [];
		public function TalkPanel(isGroup:Boolean, xpos:Number=0, ypos:Number=0, title:String="Window") 
		{
			panel = new Window(null, xpos, ypos, title);
			this.isGroup = isGroup;
			
			var w:Number = 500;
			var h:Number = 400;
			
			//setSize(720, 560);
			if(isGroup)
			panel.setSize(w, h);
			else
			panel.setSize(w - 110, h);
			
			panel.addChild(wrapper);
			var hbox:HBox = new HBox(wrapper,5,5);
			var vbox:VBox = new VBox(hbox);
			con = new ImageTextArea(vbox);
			con.editable = false;
			con.html = true;
			con.setSize(w - 120, h - 160);
			con.textField.addEventListener(TextEvent.LINK, textField_link);
			input = new TextArea(vbox);
			input.setSize(w-120, 100);
			
			var hbox2:HBox = new HBox(vbox);
			new PushButton(hbox2, 0, 0, "发送",post);
			
			list = new VBox(hbox);
			
			if(isGroup)
			addLine("open source flash p2p talk tool. <u><a href='https://github.com/matrix3d/p2ptalk'>https://github.com/matrix3d/p2ptalk</a></u>");
			
			if(wrapper.stage)
			addedToStage(null)
			else
			wrapper.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			if (!isGroup) {
				panel.hasCloseButton = true;
				panel.addEventListener(Event.CLOSE, closeButton_click);
			}
		}
		
		private function textField_link(e:TextEvent):void 
		{
			var arr:Array = e.text.split(",");
			var v:String=arr[1]
			switch(arr[0]) {
				case "file":
					var files:Array = filesDir[v];
					if (files) {
						var file:FileReference = new FileReference;
						file.save(files[1], files[0]);
					}
					break;
			}
		}
		
		private function closeButton_click(e:Event):void 
		{
			if (panel.parent) {
				panel.parent.removeChild(panel);
			}
		}
		
		private function addedToStage(e:Event):void 
		{
			wrapper.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			wrapper.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
		}
		
		private function stage_keyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode==Keyboard.ENTER&&e.ctrlKey) {
				post(null);
			}
		}
		
		private function post(e:Event):void {
			dispatchEvent(new Event(POST_EVENT));
		}
		
		public function addLine(txt:String):void {
			con.text +="<p>"+ txt.replace(/\r/g,"<br>") + "</p>";
			con.draw();
			con.textField.scrollV = con.textField.maxScrollV;
		}
		
		public function updateUserList(users:Array):void {
			if (!isGroup) return;
			list.removeChildren();
			for each(var e:P2PUser in users) {
				var btn:PushButton = new PushButton(list, 0, 0, e.name,btnclick);
				btn2user[btn] = e;
			}
		}
		
		private function btnclick(e:Event):void 
		{
			currentUser = btn2user[e.currentTarget];
			dispatchEvent(new Event(CLICKUSER_EVENT));
		}
		
		public function receive(users:HashMap,name:String, time:Number, code:int, data:Object, user:P2PUser = null):void {
			this.user = user;
			var date:Date = new Date(time);
			if(code!=ChatTest.CODE_NAME)
				addLine("<font color='#0000FF'>"+name+" "+ date.toLocaleTimeString()+"</font>");
			switch(code) {
				case ChatTest.CODE_TXT:
					addLine("<textformat indent='20'><font color='#000000'>"+data+"</font></textformat>");
					break;
				case ChatTest.CODE_NAME:
					user.name = data+"";
					updateUserList(users.values());
					panel.title = user.name;

					break;
				case ChatTest.CODE_IMAGE:
					var loader:Loader = new Loader;
					loader.loadBytes(data as ByteArray);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
					
					break;
			}
		}
		private function loader_complete(e:Event):void 
		{
			var li:LoaderInfo = e.currentTarget as LoaderInfo;
			var image:Bitmap = (li.content as Bitmap);
			addImage(image.bitmapData);
		}
		public function addImage(bmd:BitmapData):void {
			con.addImage(new Bitmap(bmd), bmd.width, bmd.height,20);
			con.draw();
			con.textField.scrollV = con.textField.maxScrollV;
		}
		public function show(parent:Sprite):void {
			{
				parent.addChild(panel);
			}
		}
		
	}

}