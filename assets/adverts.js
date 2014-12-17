/*
**                   
**             File: adverts.js
**            Title: The Register-Guard Advertisement Javascript
**         Site URL: http://www.registerguard.com/
**      Description: Javascript utilities used for RG-specific advertising.
**          Created: 10/13/09
**         Modified: 10/13/09
**           Author: Micky Hulse <micky.hulse@registerguard.com>
**     Dependencies: 
**                   [1]
**                       jQuery Javascript Library
**                       http://jquery.com/
**                   [2]
**                       jQuery Cookie Plugin
**                       http://plugins.jquery.com/project/cookie
**             Todo: 
**                   - Make jQuery plugin(s).
**                   - Rethink nameCookie?
** 
*/

/*
** =========================================================
** Global:
** =========================================================
*/

function checkCookie(key) { return ($.cookie(key)) ? true : false; }
function setCookie(key, val) { return ($.cookie(key, val, { path: '/', domain: 'registerguard.com' })) ? true : false; }
function getCookie(key) { return $.cookie(key); }

function nameCookie(type) {
	switch (type) {
		case 'peel':
			$obj = $('#peel object');
			break;
		case 'billboard':
			$obj = $('#billboard object')
			break;
		default:
			$obj = null;
	}
	return ($obj !== null) ? $obj.attr('id') : 'default';
}

/*
** =========================================================
** Billboard specific:
** =========================================================
*/

function asControl(name) {
	
	$obj = $('#billboard object')[0];
	if ($obj && typeof $obj.asClosed != 'undefined') {
		$obj.asClosed();
	}
	
}

function billboardControl(height_closed, height_open) {
	
	var $billboard = $('#billboard');
	var billboard_name = $('#billboard object').attr('name');
	var speed = 1000;
	
	height_closed = (height_closed !== null) ? height_closed : '30';
	height_open = (height_open !== null) ? height_open : '420';
	
	if ($billboard.height() < height_open) {
		$billboard.animate({ height: height_open }, speed);
	} else {
		$billboard.animate({ height: height_closed }, speed, function() {
			asControl(billboard_name);
		});
	}
	
}

/*
** =========================================================
** Peel specific:
** =========================================================
*/

function peelControl(mode) {
	$peel = $('#peel');
	if (mode == "open") { $peel.width(600).height(600); }
	if (mode == "close") { $peel.width(100).height(100); }
}