package  
{
	import com.kelvinluck.audio.MP3Player;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.Timer;
	
	import fl.controls.Button;
	import fl.controls.Label;
	import fl.controls.Slider;
	
	import org.audiofx.mp3.MP3FileReferenceLoader;
	import org.audiofx.mp3.MP3SoundEvent;

	/**
	 * @author Tiger
	 */
	public class SpeedSoundPlay extends Sprite 
	{
		public var loadMp3Button:Button;
		public var speedLabel:Label;
		public var speedValue:Label;
		public var speedSlider:Slider;

		private var fr:FileReference;
		private var mp3Player:MP3Player;
		private var mp3Loader:MP3FileReferenceLoader;

		public function SpeedSoundPlay()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,addToState);
		}
		
		protected function addToState(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,addToState);
			mp3Player = new MP3Player();
			mp3Loader = new MP3FileReferenceLoader();
			mp3Loader.addEventListener(MP3SoundEvent.COMPLETE, onMp3LoadComplete);
			loadMp3Button.addEventListener(MouseEvent.CLICK, onLoadMp3);
			
			speedSlider.snapInterval = 0.1;
			speedSlider.addEventListener(Event.CHANGE,updatePlaySpeed);
			speedSlider.value = 1;
			updatePlaySpeed(null);
		}
		
		protected function updatePlaySpeed(event:Event):void
		{
			mp3Player.playbackSpeed = speedSlider.value;
			speedValue.text = speedSlider.value + "";
		}

		private function onLoadMp3(event:MouseEvent):void
		{
			fr = new FileReference();

			fr.addEventListener(Event.SELECT, onFileSelect);
			fr.addEventListener(Event.CANCEL, onCancel);
			
			fr.browse([new FileFilter('Mp3 files', '*.mp3')]);
		}

		private function onFileSelect(e:Event):void
		{
			mp3Player.stop();
			mp3Loader.getSound(fr);
		}

		private function onCancel(e:Event):void
		{
			trace("File Browse Cancelled");
			fr = null;
		}
		
		private function onMp3LoadComplete(event:MP3SoundEvent):void
		{
			mp3Player.playLoadedSound(event.sound);
			startChcekTimer();
		}
		
		//进度监听时间
		private var mTime:Timer;
		private function startChcekTimer():void
		{
			mTime = new Timer(500);
			mTime.addEventListener(TimerEvent.TIMER,updateSpeed);
			mTime.start();
		}
		
		protected function updateSpeed(event:TimerEvent):void
		{
			speedLabel.text = mp3Player.curSoundTime + "";
		}
	}
}
