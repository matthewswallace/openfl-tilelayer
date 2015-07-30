package aze.display;

import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;

/**
parrow spritesheet parser for TileLayer
 * - supports animations
 * - supports sprite trimming
 * - does NOT support sprite rotation
 * @author Philippe / http://philippe.elsass.me
 */
class SparrowTilesheet extends TilesheetEx
{

	/**
	 * 
	 * @param	img texture atlas
	 * @param	xml
	 * @param	textureScale
	 * @param	useCenterPoint default value = true, false means that the center point will be top left
	 */
	public function new(img:BitmapData, xml:String, textureScale:Float = 1.0, useCenterPoint:Bool = true) 
	{
		super(img, textureScale);
		
		var ins = new Point(0,0);
		var x = new haxe.xml.Fast( Xml.parse(xml).firstElement() );

		for (texture in x.nodes.SubTexture)
		{
			var name = texture.att.name;
			var rect = new Rectangle(
				Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y),
				Std.parseFloat(texture.att.width), Std.parseFloat(texture.att.height));
			
			var size = if (texture.has.frameX) // trimmed
					new Rectangle(
						Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY),
						Std.parseInt(texture.att.frameWidth), Std.parseInt(texture.att.frameHeight));
				else 
					new Rectangle(0, 0, rect.width, rect.height);
			
			#if flash
			var bmp = new BitmapData(cast size.width, cast size.height, true, 0);
			ins.x = -size.left;
			ins.y = -size.top;
			bmp.copyPixels(img, rect, ins);
			addDefinition(name, size, bmp);
			#else
			var center = useCenterPoint ? new Point((size.x + size.width / 2), (size.y + size.height / 2)) : null;
			addDefinition(name, size, rect, center);
			#end
		}
	}

}
