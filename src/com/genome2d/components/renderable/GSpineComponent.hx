/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2019 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.components.renderable;

import com.genome2d.spine.GSpine;
import com.genome2d.geom.GMatrix;
import com.genome2d.context.GBlendMode;
import com.genome2d.Genome2D;
import com.genome2d.components.GComponent;
import com.genome2d.components.renderable.IGRenderable;
import com.genome2d.context.GCamera;
import com.genome2d.context.IGContext;
import com.genome2d.input.GMouseInput;
import com.genome2d.spine.GAtlasAttachmentLoader;
import com.genome2d.spine.GAtlasTextureLoader;
import com.genome2d.textures.GTexture;
import com.genome2d.geom.GRectangle;

import spinehaxe.Bone;
import spinehaxe.Skeleton;
import spinehaxe.SkeletonData;
import spinehaxe.SkeletonJson;
import spinehaxe.Slot;
import spinehaxe.animation.AnimationState;
import spinehaxe.animation.AnimationStateData;
import spinehaxe.atlas.Atlas;
import spinehaxe.attachments.RegionAttachment;

class GSpineComponent extends GComponent implements IGRenderable
{
    public var autoUpdate:Bool = true;

    private var _spine:GSpine;
    public function getSpine():GSpine {
        return _spine;
    }

    override public function init():Void {
        node.core.onUpdate.add(update);
    }

    public function setupReferenced(p_spine:GSpine) {
        _spine = p_spine;
    }

    public function setup(p_atlas:String, p_texture:GTexture, p_defaultAnim:String = "stand"):Void {
        _spine = new GSpine(p_atlas, p_texture, p_defaultAnim);
    }

    public function update(p_deltaTime:Float):Void {
        if (_spine != null && autoUpdate) _spine.update(p_deltaTime);
    }

    public function render(p_camera:GCamera, p_useMatrix:Bool):Void {
        _spine.render(node.g2d_worldX, node.g2d_worldY, node.g2d_worldScaleX, node.g2d_worldScaleY, autoUpdate);
    }
	
    public function getBounds(p_bounds:GRectangle = null):GRectangle {
        // Hack for su
        if (p_bounds != null) p_bounds.setTo(-60, -60, 100, 60);
        else p_bounds = new GRectangle(-60,-60,100,60);
        return p_bounds;
    }

    public function captureMouseInput(p_input:GMouseInput):Void {
        p_input.captured = p_input.captured || hitTest(p_input.localX, p_input.localY);
    }

    public function hitTest(p_x:Float,p_y:Float):Bool {
        // Hack for su
        var hit:Bool = false;
        var width:Int = 60;
        var height:Int = 70;

        p_x = p_x / width + .5;
        p_y = p_y / height + .95;

        hit = (p_x >= 0 && p_x <= 1 && p_y >= 0 && p_y <= 1);

        return hit;
    }

    override public function onDispose():Void {
        node.core.onUpdate.remove(update);

        // Not sure for reuse
        if (_spine != null) {
            _spine.dispose();
        }
    }
}