/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2015 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.ui.skin;

// Not prototypable due to reference tree
import com.genome2d.spine.GSpine;
class GUISpineSkin extends GUISkin {
    public var spine:GSpine;

    override public function getMinWidth():Float {
        return 0;
    }

    override public function getMinHeight():Float {
        return 0;
    }

    public function new(p_id:String = "", p_spine:GSpine, p_origin:GUISpineSkin = null) {
        super(p_id, p_origin);

        spine = p_spine;
        if (g2d_origin == null) Genome2D.getInstance().onUpdate.add(update_handler);
    }

    override public function render(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float, p_red:Float, p_green:Float, p_blue:Float, p_alpha:Float):Bool {
        var tx:Float = p_left + (p_right - p_left)/2;
        var ty:Float = p_top + (p_bottom - p_top)/2;

        spine.render(tx, ty, 1, 1);

        return true;
    }

    private function update_handler(p_deltaTime:Float):Void {
        spine.update(p_deltaTime);
    }

    override public function clone():GUISkin {
        var clone:GUISpineSkin = new GUIParticleSkin("", spine, (g2d_origin == null)?this:cast g2d_origin);
        clone.red = red;
        clone.green = green;
        clone.blue = blue;
        clone.alpha = alpha;
        return clone;
    }

    override public function dispose():Void {
        if (g2d_origin == null) Genome2D.getInstance().onUpdate.remove(update_handler);

        super.dispose();
    }
}
