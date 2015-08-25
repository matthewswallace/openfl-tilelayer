package aze.display;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.display.Tilesheet;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using StringTools;

/**
 * A cross-targets Tilesheet container, with animation and trimming support
 *
 * - animations are matched by name (startsWith) and cached after 1st request,
 * - rect: marks the actual pixel content of the spritesheet that should be displayed for a sprite,
 * - size: original (before trimming) sprite dimensions are indicated by the size's (width,height); 
 *         rect offset inside the original sprite is indicated by size's (left,top).
 *
 * @author Philippe / http://philippe.elsass.me
 */
class TilesheetEx extends Tilesheet
{
	public var scale:Float;
	var defs:Array<String>;
	var sizes:Array<Rectangle>;
	var anims:Map<String, Array<Int>>;
	var tiles:Map<String, Int>;
	#if flash
	var bmps:Array<BitmapData>;
	#end

	public function new(img:BitmapData, textureScale:Float = 1.0)
	{
		super(img);
		
		scale = 1/textureScale;
		defs = new Array<String>();
		anims = new Map<String, Array<Int>>();
		tiles = new Map<String, Int>();
		sizes = new Array<Rectangle>();
		#if flash
		bmps = new Array<BitmapData>();
		#end
	}

	#if flash
	public function addDefinition(name:String, size:Rectangle, bmp:BitmapData)
	{
		defs.push(name);
		sizes.push(size);
		bmps.push(bmp);
	}
	#else
	public function addDefinition(name:String, size:Rectangle, rect:Rectangle, center:Point)
	{
		defs.push(name);
		sizes.push(size);
		if (scale != 1.0)
		{
			rect.x /= scale;
			rect.y /= scale;
			rect.width /= scale;
			rect.height /= scale;
			center.x /= scale;
			center.y /= scale;
		}
		addTileRect(rect, center);
	}
	#end

	public function getAnim(name:String):Array<Int>
	{
		if (anims.exists(name))
			return anims.get(name);
		var indices = new Array<Int>();
		for (i in 0...defs.length)
		{
			if (defs[i].startsWith(name)) 
				indices.push(i);
		}
		anims.set(name, indices);

		#if debug
		if (indices.length == 0) {
			trace("Tilesheet has no tile with name \"" + name + "\"");
		}
		#end 
		
		return indices;
	}
	
	public function getIndex(name:String):Int
	{
		if (tiles.exists(name))
			return tiles.get(name);
		var index:Int = defs.indexOf(name);
		tiles.set(name, index);
		
		#if debug
		if(index == -1)
			trace("Tilesheet has no tile with name \"" + name + "\"");
		#end 
		
		return index;
	}

	inline public function getSize(indice:Int):Rectangle
	{
		if (indice < sizes.length) return sizes[indice];
		else return new Rectangle();
	}

	#if flash
	inline public function getBitmap(indice:Int):BitmapData
	{
		return bmps[indice];
	}
	#end

	/**
	 * 
	 * @param	fileNames
	 * @param	padding
	 * @param	spacing
	 * @param	useCenterPoint default value = true, false means that the center point will be top left
	 */
	static public function createFromAssets(fileNames:Array<String>, padding:Int=0, spacing:Int=0, useCenterPoint:Bool = true) 
	{
		var names:Array<String> = [];
		var images:Array<BitmapData> = [];
		for(fileName in fileNames)
		{
			var name = fileName.split("/").pop();
			var image = Assets.getBitmapData(fileName);
			names.push(name);
			images.push(image);
		}
		return createFromImages(names, images, padding, spacing, useCenterPoint);
	}

	/**
	 * 
	 * @param	names
	 * @param	images
	 * @param	padding
	 * @param	spacing
	 * @param	useCenterPoint default value = true, false means that the center point will be top left
	 */
	static public function createFromImages(names:Array<String>, images:Array<BitmapData>, padding:Int=0, spacing:Int=0, useCenterPoint:Bool = true) 
	{
		var width = 0;
		var height = padding;
		for(image in images)
		{
			if (image.width + padding*2 > width) width = image.width + padding*2;
			height += image.height + spacing;
		}
		height -= spacing;
		height += padding;

		var img = new BitmapData(closestPow2(width), closestPow2(height), true, 0);
		var sheet = new TilesheetEx(img);

		var pos = new Point(padding, padding);
		for(i in 0...images.length)
		{
			var image = images[i];
			img.copyPixels(image, image.rect, pos, null, null, true);
			#if flash
			sheet.addDefinition(names[i], image.rect, image);
			#else
			var rect = new Rectangle(padding, pos.y, image.width, image.height);
			var center = useCenterPoint ? new Point(image.width/2, image.height/2) : null;
			sheet.addDefinition(names[i], image.rect, rect, center);
			#end
			pos.y += image.height + spacing;
		}
		return sheet;
	}

	static public function closestPow2(v:Int)
	{
		var p = 2;
		while (p < v) p = p << 1;
		return p;
	}
}


