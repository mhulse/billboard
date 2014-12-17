﻿package {		//----------------------------------	// Imports:	//----------------------------------		import flash.display.*;	import flash.filters.*;	import flash.events.*;	import flash.external.*;	import flash.system.*;	import com.greensock.*;	import com.greensock.easing.*;	import com.greensock.events.*;	import com.greensock.plugins.*	import com.greensock.loading.*;	import com.greensock.loading.core.*;	import me.hulse.util.*;		//--------------------------------------------------------------------		/**	* Billboard document class.	* 	* @author Micky Hulse	* @copyright Copyright (c) 2011, Micky Hulse	* @link http://hulse.me/	*/		public class Main extends MovieClip {				//----------------------------------		// Meta:		//----------------------------------				private static const APP_NAME:String = 'Billboard';		private static const APP_VERSION:String = '1.3';		private static const APP_MODIFIED:String = '2012/09/27';		private static const APP_AUTHOR:String = 'Micky Hulse <micky@hulse.me>';				//----------------------------------		// Private constants:		//----------------------------------				private static const ALLOWED_DOMAINS:Array = ['registerguard.com', 'hulse.me', 'guardnet.com'];				//----------------------------------		// Private:		//----------------------------------				private var _ft:FireTrace;		private var _lockDown:LockDown2;		private var _stager:Stager;		private var _cookie:HttpCookie;		private var _timing:Timing;		private var _clickTag:ClickTag;		private var _params:Params;		private var _mainMc:MainMc;		private var _loaders:LoaderMax		private var _cookieName:String;		private var _cookieAllowed:Boolean;		private var _cookieChecker:Boolean;		private var _contentMc:MovieClip;		private var _advertMc:MovieClip;		private var _advertMcLoad:MovieClip;		private var _advertImg:Boolean;		private var _teaseMc:MovieClip;		private var _teaseMcLoad:MovieClip;		private var _teaseImg:Boolean;		private var _openCloseMc:MovieClip;		private var _heightClosed:String;		private var _heightOpen:String;		private var _timeOpen:Number;				//--------------------------------------------------------------------				/**		* Class constructor.		* 		* @access public    		*/				public function Main() {						//----------------------------------			// Boilerplate:			//----------------------------------						addEventListener(Event.ADDED_TO_STAGE, ready, false, 0, true);					};				//--------------------------------------------------------------------				/**		* Called once the stage is ready.		* 		* @param Event		* 		* @access private		* @return void		*/				private function ready($e:Event):void {						//----------------------------------			// Garbage collection:			//----------------------------------						removeEventListener(Event.ADDED_TO_STAGE, ready);						//----------------------------------			// Logging:			//----------------------------------						_ft = new FireTrace();						_ft.log('ready() instantiated...');						//----------------------------------			// Who, what, when, where and why:			//----------------------------------						_ft.log('Name: ' + APP_NAME + '; Version: ' + APP_VERSION + '; Modified: ' + APP_MODIFIED + '; Author: ' + APP_AUTHOR);						//----------------------------------			// Domain security crap:			//----------------------------------						//Security.allowDomain(ALLOWED_DOMAINS);			Security.allowDomain('*'); // '*' needed for OAS to work.						//----------------------------------			// Simple SWF domain locking:			//----------------------------------						_lockDown = new LockDown2(ALLOWED_DOMAINS);			if (_lockDown.unlocked) { this.init(); }					};				//--------------------------------------------------------------------				/**		* Initialize program.		* 		* @access private		* @return void		*/				private function init():void {						_ft.log('init()...');						//----------------------------------			// Instantiate params class:			//----------------------------------						_params = new Params(this);						//----------------------------------			// GreenSock plugins & loaders:			//----------------------------------						// Activation is permanent in the SWF, so this line only needs to be run once:			TweenPlugin.activate([AutoAlphaPlugin]);						// http://www.greensock.com/as/docs/tween/com/greensock/loading/LoaderMax.html#parse()			// Activate the necessary loaders so that their file extensions can be recognized (do this once):			LoaderMax.activate([ImageLoader, SWFLoader]);						//----------------------------------			// Load assets:			//----------------------------------						// Create assets array:			var assets:Array = [				_params.getParam('tease', 'tease.png'),				_params.getParam('advert', 'advert.swf')			];						// Now parse all of the urls, creating a LoaderMax that contains the correct type of loaders (an ImageLoader, XMLLoader, SWFLoader, and MP3Loader respectively):			_loaders = LoaderMax.parse(assets, { name:'mainQueue', autoDispose:true, onComplete:completeHandler }) as LoaderMax;						// Begin loading:			_loaders.load();					};				//--------------------------------------------------------------------				/**		* Called after external assets have loaded.		* 		* @param Event		* 		* @access private		* @return void		*/				private function completeHandler($e:LoaderEvent):void {						_ft.log('Load complete...');						//----------------------------------			// Add ExternalInterface callbacks:			//----------------------------------						ExternalInterface.addCallback('asClosed', jsClosed);						//----------------------------------			// Get flashvar params:			//----------------------------------			 			_heightClosed = _params.getParam('height_closed', '30'); // Height closed.			_heightOpen = _params.getParam('height_open', '415'); // Height open.			_timeOpen = Number(_params.getParam('seconds', '10')) * 1000; // Time, in milliseconds, open.						//----------------------------------			// Setup stage:			//----------------------------------						_stager = new Stager(this, 'NO_SCALE', 'BOTTOM'); // Setup stage.						//----------------------------------			// Cookies:			//----------------------------------						_cookie = new HttpCookie('billboard'); // Target HTML object.			_cookieName = _cookie.name;			_ft.log('Cookie name: "' + _cookieName + '"');			_cookieChecker = _cookie.checkCookie(_cookieName);			_cookieAllowed = _cookie.allowed;						//----------------------------------			// Clicktag:			//----------------------------------						_clickTag = new ClickTag(this);						//----------------------------------			// Setup our primary movieclip:			//----------------------------------						_mainMc = new MainMc(); // Create new instance.			_mainMc.x = 0; // Position.			_mainMc.y = 0; // IBID.			_mainMc.mouseChildren = true; // Trying to fix Firefox 4.						//----------------------------------			// Content holder movieclip:			//----------------------------------						_contentMc = _mainMc.content_mc;			_contentMc.addEventListener(MouseEvent.MOUSE_UP, onClick, false, 0, true); // http://www.kirupa.com/forum/showthread.php?t=260312			_contentMc.mouseChildren = false;			_contentMc.buttonMode = true;			_contentMc.useHandCursor = true;						//----------------------------------			// Controller movielcip:			//----------------------------------						_openCloseMc = _mainMc.openclose_mc;			controller(_openCloseMc, 'stop');			_openCloseMc.addEventListener(MouseEvent.MOUSE_UP, onOpenCloseClick, false, 0, true); // http://www.kirupa.com/forum/showthread.php?t=260312						//----------------------------------			// Get loaders:			//----------------------------------						// Returns and array of all child loaders inside the LoaderMax:			var loaders:Array = _loaders.getChildren();						//----------------------------------			// Advert:			//----------------------------------						_advertMc = _contentMc.ad_mc; // Target MC.			var advert:Object = loaders[1].rawContent; // Loaded content.			_advertImg = isImage(advert); // Image or swf?						/* Todo: Some of the below code could be moved to method(s). */						if (_advertImg) {								//----------------------------------				// Image:				//----------------------------------								var advertBmLoad:Bitmap = advert as Bitmap;				advertBmLoad.x = 0;				advertBmLoad.y = 415 - advertBmLoad.loaderInfo.height; // 415 = height of "billboard" stage.				_ft.log('415 - ' + advertBmLoad.loaderInfo.height + ' = ' + advertBmLoad.y);				_advertMc.addChild(advertBmLoad);							} else {								//----------------------------------				// SWF:				//----------------------------------								_advertMcLoad = advert as MovieClip; // Cast 'DisplayObject' to 'MovieClip'.				controller(_advertMcLoad, 'gotoAndStop'); // Stop until told to play.				_advertMcLoad.x = 0;				_advertMcLoad.y = 415 - _advertMcLoad.loaderInfo.height; // IBID				_ft.log('415 - ' + _advertMcLoad.loaderInfo.height + ' = ' + _advertMcLoad.y);				_advertMc.addChild(_advertMcLoad);							}						//----------------------------------			// Tease:			//----------------------------------						_teaseMc = _contentMc.tease_mc; // Target MC.			var tease:Object = loaders[0].rawContent; // Loaded content.			_teaseImg = isImage(tease); // Image or SWF?						if (_teaseImg) {								//----------------------------------				// Image:				//----------------------------------								var teaseBmLoad:Bitmap = tease as Bitmap				teaseBmLoad.x = 0;				teaseBmLoad.y = 415 - teaseBmLoad.loaderInfo.height; // IBID				_ft.log('415 - ' + teaseBmLoad.loaderInfo.height + ' = ' + teaseBmLoad.y);				_teaseMc.addChild(teaseBmLoad);							} else {								//----------------------------------				// SWF:				//----------------------------------								_teaseMcLoad = tease as MovieClip;				_teaseMcLoad.x = 0;				_teaseMcLoad.y = 415 - _teaseMcLoad.loaderInfo.height; // IBID				_ft.log('415 - ' + _teaseMcLoad.loaderInfo.height + ' = ' + _teaseMcLoad.y);				_teaseMc.addChild(_teaseMcLoad);							}						//----------------------------------			// Add everything to stage:			//----------------------------------						this.addChild(_mainMc);						//----------------------------------			// Begin program:			//----------------------------------						this.startBillboard();					};				//--------------------------------------------------------------------				/**		* Checks for existence of cookie.		* 		* <p>Opens billboard if cookie not found.</p>		* 		* @access private		* @return void		*/				private function startBillboard():void {						_ft.log('startBillboard()...');						//----------------------------------			// Cookie checks:			//----------------------------------						// Can we use cookies?			if (_cookieAllowed) {								// If cookie does not exist:				if (!_cookieChecker) {										_ft.log('First time visit...');										// Set cookie:					_cookie.setCookie(_cookieName, _cookieName);										// Open/close with a timer:					this.openTimer();									} else {										_ft.log('Cookie already set...');									}							}					};				//--------------------------------------------------------------------				/**		* Calls garbage collector.		* 		* <p>Called from javascript using ExternalInterface.addCallback().</p>		* 		* @access private		* @return void		*/				private function jsClosed():void {						_ft.log('jsClosed()...');						//----------------------------------			// GC & controls:			//----------------------------------						this.timingGc(); // GC.						// Put ad back on its frame 1:			controller(_advertMcLoad, 'gotoAndStop');					};				//--------------------------------------------------------------------				/**		* Garbage collector.		* 		* @access private		* @return void		*/				private function timingGc():void {						_ft.log('timingGc()...');						//----------------------------------			// GC:			//----------------------------------						if (_timing.hasEventListener(Timing.TIMING_COMPLETE)) {								_timing.removeEventListener(Timing.TIMING_COMPLETE, onOpenClose);								_ft.log('timingGc() complete...');							}					};				//--------------------------------------------------------------------				/**		* Initializes "open" timer.		* 		* @access private		* @return void		*/				private function openTimer():void {						_ft.log('openTimer()...');						//----------------------------------			// Timer & open/close:			//----------------------------------						// Timer:			_timing = new Timing(_timeOpen); // 10 seconds === 10,000 miliseconds.			_timing.addEventListener(Timing.TIMING_COMPLETE, onOpenClose, false, 0, true);						// Open/close:			this.openClose();					};				//--------------------------------------------------------------------				/**		* Main control; Show/hides tease.		* 		* <p>		* 	Communicates with JS via billboardControl();		* 	Plays the ad from the ad's frame 1.		* </p>		* 		* @access private		* @return void		*/				private function openClose():void {						_ft.log('openClose()...');						//----------------------------------			// Advert:			//----------------------------------						if (!_advertImg) {								_ft.log('Ad current frame: ' + _advertMcLoad.currentFrame);				if (_advertMcLoad.currentFrame == 1) {					controller(_advertMcLoad);				}							}						//----------------------------------			// Open/close button:			//----------------------------------						(_openCloseMc.currentFrame == 2) ? controller(_openCloseMc, 'gotoAndStop') : controller(_openCloseMc, 'gotoAndStop', 2);						//----------------------------------			// Tease:			//----------------------------------						if (!_teaseImg) {								// Show/hide SWF:				(_teaseMc.visible) ? TweenLite.to(_teaseMc, 1, { autoAlpha: 0, onComplete: controller, onCompleteParams: [_teaseMcLoad, 'gotoAndStop'] }) : TweenLite.to(_teaseMc, 1, { autoAlpha: 1, onComplete: controller, onCompleteParams: [_teaseMcLoad, 'gotoAndPlay'] });							} else {								// Show/hide image:				(_teaseMc.visible) ? TweenLite.to(_teaseMc, 1, { autoAlpha: 0 }) : TweenLite.to(_teaseMc, 1, { autoAlpha: 1 });							}						//----------------------------------			// Call javascript:			//----------------------------------						ExternalInterface.call('billboardControl', _heightClosed, _heightOpen);					};				//--------------------------------------------------------------------				/**		* Playback control.		* 		* @param Target MovieClip; Required.		* @param: Controller type? Options: 'gotoAndStop', 'gotoAndPlay', 'stop', 'play'. Default is 'play'.		* @param: Frame number. Default is frame #1.		* 		* @access private		* @return void		*/				private function controller($mc:MovieClip, $t:String = 'play', $f:Number = 1):void {						_ft.log('controller(' + $mc + ', ' + $t + ', ' + $f + ')...');						//----------------------------------			// For advert movieclips:			//----------------------------------						switch ($t.toLowerCase()) {								case 'gotoandstop':					$mc.gotoAndStop($f);					break;								case 'gotoandplay':					$mc.gotoAndPlay($f);					break;								case 'stop':					$mc.stop();					break;								case 'play':					$mc.play();					break;							}								};				//--------------------------------------------------------------------				/**		* Click listener method.		* 		* <p>The clickTAG gets initialized here.</p>		* 		* @param MouseEvent		* 		* @access private		* @return void		*/				private function onClick($e:MouseEvent):void {						_ft.log('onClick()...');						//----------------------------------			// Setup clickTAG:			//----------------------------------						_clickTag.getURL();					};				//--------------------------------------------------------------------				/**		* Listener method for Timing.TIMING_COMPLETE.		* 		* <p>Garbage collects, and calls main control.</p>		* 		* @param: Event		* 		* @access private		* @return void		*/				private function onOpenClose($e:Event):void {						_ft.log('onOpenClose()...');						//----------------------------------			// Open/close:			//----------------------------------						this.openClose();					};				//--------------------------------------------------------------------				/**		* Click listener method.		* 		* <p>Applied to open/close button.</p>		* 		* @param MouseEvent		* 		* @access private		* @return void		*/				private function onOpenCloseClick($e:MouseEvent):void {						_ft.log('onOpenCloseClick()...');						//----------------------------------			// Open/close with a timer:			//----------------------------------						this.openTimer();					};				//--------------------------------------------------------------------				/**		* Click listener method.		* 		* <p>Applied to open/close button.</p>		* 		* @param MouseEvent		* 		* @access private		* @return void		*/				private function isImage($o:*):Boolean {						// Create regexp:			//var validImageRegExp:RegExp =/(?i)\.(jpg|png|gif|jpeg)$/			//return validImageRegExp.test($o) // Boolean true/false.						//----------------------------------			// Downcast:			//----------------------------------						var mc:MovieClip = $o as MovieClip;			return (!mc) ? true : false;					};				//--------------------------------------------------------------------			};	};