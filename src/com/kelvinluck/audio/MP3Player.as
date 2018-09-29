package com.kelvinluck.audio 
{
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	/**
	 * @author Kelvin Luck
	 */
	public class MP3Player 
	{

		private var _playbackSpeed:Number = 1;	

		public function set playbackSpeed(value:Number):void
		{
			_playbackSpeed = value;
		}

		private var _mp3:Sound;
		private var _loadedMP3Samples:ByteArray;
		private var _dynamicSound:Sound;
		private var sndChanel:SoundChannel;

		private var _phase:Number;
		private var _numSamples:int;

		public function MP3Player()
		{
		}

		public function loadAndPlay(request:URLRequest):void
		{
			_mp3 = new Sound();
			_mp3.addEventListener(Event.COMPLETE, mp3Complete);
			_mp3.load(request);
		}

		public function playLoadedSound(s:Sound):void
		{
			var bytes:ByteArray = new ByteArray();
			s.extract(bytes, int(s.length * 44.1));
			play(bytes);
		}
		
		public function stop():void
		{
			if (_dynamicSound) {
				_dynamicSound.removeEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
				_dynamicSound = null;
			}
		}

		private function mp3Complete(event:Event):void
		{
			playLoadedSound(_mp3);
		}

		private function play(bytes:ByteArray):void
		{
			stop();
			_dynamicSound = new Sound();
			_dynamicSound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			
			sndChanel = new SoundChannel();
			
			_loadedMP3Samples = bytes;
			_numSamples = bytes.length / 8;
			
			_phase = 0;
			sndChanel = _dynamicSound.play();
			
		}

		private function onSampleData( event:SampleDataEvent ):void
		{
			
			var l:Number;
			var r:Number;
			
			var outputLength:int = 0;
			while (outputLength < 2048) { 
				// until we have filled up enough output buffer
				
				// move to the correct location in our loaded samples ByteArray
				_loadedMP3Samples.position = int(_phase) * 8; // 4 bytes per float and two channels so the actual position in the ByteArray is a factor of 8 bigger than the phase
				
				// read out the left and right channels at this position
				l = _loadedMP3Samples.readFloat();
				r = _loadedMP3Samples.readFloat();
				
				// write the samples to our output buffer
				event.data.writeFloat(l);
				event.data.writeFloat(r);
				
				outputLength++;
				
				// advance the phase by the speed...
				_phase += _playbackSpeed;
				
				// and deal with looping (including looping back past the beginning when playing in reverse)
				if (_phase < 0) {
					_phase += _numSamples;
				} else if (_phase >= _numSamples) {
					_phase -= _numSamples;
				}
			}
		}
		
		/** 当前时间 */
		public function get curSoundTime():int
		{
			if(sndChanel)
				return sndChanel.position*_playbackSpeed;
			return 0;
		}
		
	}
}
