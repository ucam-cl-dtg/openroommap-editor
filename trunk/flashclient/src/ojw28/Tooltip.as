/**
 * SpeechBubble drawing code by A. Atkins (http://www.razorberry.com/blog/)
 * Please retain this message if you re-distribute!
 */

package ojw28
{
	import flash.display.Graphics;
	import flash.display.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.events.*;
	
	public final class Tooltip extends MovieClip
	{
		private var mFading:Boolean = false;
		private var mFadeCount:Number = 0;
		
		public function Tooltip(rect:Rectangle, cornerRadius:Number, point:Point, iText:String)
		{
			addEventListener(Event.ENTER_FRAME, onEnter);
			var lText:TextField = new TextField();
			addChild(lText);
			/* Create a new TextFormat object, and set the font property to the myFont
			   object's fontName property. */
			var myFormat:TextFormat = new TextFormat();
			var lFont:Font = new FgdHeading();
			myFormat.font = lFont.fontName;
			myFormat.bold = true;
			myFormat.size = 14;
			myFormat.color = 0xFFFFFF;
			lText.autoSize = TextFieldAutoSize.LEFT;
			lText.defaultTextFormat = myFormat;
			lText.embedFonts = true;
			lText.x = rect.x + 10;
			lText.y = rect.y + 10;
			lText.text = iText;
			lText.selectable = false;
			
			rect.width = lText.width + 20;
			rect.height = lText.height + 20;
			
			var g:Graphics = graphics;
			var r:Number = cornerRadius;
			
g.clear();
g.lineStyle(0,0x000000,1,true);
g.beginFill(0x0098FF,0.8);

			var x:Number = rect.x;
			var y:Number = rect.y;
			var w:Number = rect.width;
			var h:Number = rect.height;
			var px:Number = point.x;
			var py:Number = point.y;
			var min_gap:Number = 20;
			var hgap:Number = Math.min(w - r - r, Math.max(min_gap, w / 5));
			var left:Number = px <= x + w / 2 ? 
				 (Math.max(x+r, px))
				:(Math.min(x + w - r - hgap, px - hgap));
			var right:Number = px <= x + w / 2?
				 (Math.max(x + r + hgap, px+hgap))
				:(Math.min(x + w - r, px));
			var vgap:Number = Math.min(h - r - r, Math.max(min_gap, h / 5));
			var top:Number = py < y + h / 2 ?
				 Math.max(y + r, py)
				:Math.min(y + h - r - vgap, py-vgap);
			var bottom:Number = py < y + h / 2 ?
				 Math.max(y + r + vgap, py+vgap)
				:Math.min(y + h - r, py);
					
			//bottom right corner
			var a:Number = r - (r*0.707106781186547);
			var s:Number = r - (r*0.414213562373095);
			
			g.moveTo ( x+w,y+h-r);
			if (r > 0)
			{
				if (px > x+w-r && py > y+h-r && Math.abs((px - x - w) - (py - y - h)) <= r)
				{
					g.lineTo(px, py);
					g.lineTo(x + w - r, y + h);
				}
				else
				{
					g.curveTo( x + w, y + h - s, x + w - a, y + h - a);
					g.curveTo( x + w - s, y + h, x + w - r, y + h);
				}
			}
	
			if (py > y + h && (px - x - w) < (py - y -h - r) && (py - y - h - r) > (x - px))
			{
				// bottom edge
				g.lineTo(right, y + h);
				g.lineTo(px, py);
				g.lineTo(left, y + h);
			}
			
			g.lineTo ( x+r,y+h );
			
			//bottom left corner
			if (r > 0)
			{
				if (px < x + r && py > y + h - r && Math.abs((px-x)+(py-y-h)) <= r)
				{
					g.lineTo(px, py);
					g.lineTo(x, y + h - r);
				}
				else
				{
					g.curveTo( x+s,y+h,x+a,y+h-a);
					g.curveTo( x, y + h - s, x, y + h - r);
				}
			}
	
			if (px < x && (py - y - h + r) < (x - px) && (px - x) < (py - y - r) )
			{
				// left edge
				g.lineTo(x, bottom);
				g.lineTo(px, py);
				g.lineTo(x, top);
			}
			
			g.lineTo ( x,y+r );
			
			//top left corner
			if (r > 0)
			{
				if (px < x + r && py < y + r && Math.abs((px - x) - (py - y)) <= r)
				{
					g.lineTo(px, py);
					g.lineTo(x + r, y);
				}
				else
				{
					g.curveTo( x,y+s,x+a,y+a);
					g.curveTo( x + s, y, x + r, y);
				}
			}
			
			if (py < y && (px - x) > (py - y + r) && (py - y + r) < (x - px + w))
			{
				//top edge
				g.lineTo(left, y);
				g.lineTo(px, py);
				g.lineTo(right, y);
			}
			
			g.lineTo ( x + w - r, y );
			
			//top right corner
			if (r > 0)
			{
				if (px > x + w - r && py < y + r && Math.abs((px - x - w) + (py - y)) <= r)
				{
					g.lineTo(px, py);
					g.lineTo(x + w, y + r);
				}
				else
				{
					g.curveTo( x+w-s,y,x+w-a,y+a);
					g.curveTo( x + w, y + s, x + w, y + r);
				}
			}
			
			if (px > x + w && (py - y - r) > (x - px + w) && (px - x - w) > (py - y - h + r) )
			{
				// right edge
				g.lineTo(x + w, top);
				g.lineTo(px, py);
				g.lineTo(x + w, bottom);
			}
			g.lineTo ( x+w,y+h-r );
			
			g.endFill();
		}
		
		public function fadeAndRemove()
		{
			mFading = true;
		}
		
		public function onEnter(evt:Event)
		{
			if(mFading)
			{
				mFadeCount++;
				if(mFadeCount > 120)
				{
					alpha = alpha - 0.05;
				}
			}
			if(alpha <= 0)
			{
				stop();
				parent.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, onEnter);				
			}
		}
	}
}
