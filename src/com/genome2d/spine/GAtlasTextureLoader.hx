/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2019 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.spine;

import com.genome2d.geom.GRectangle;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureManager;

import spinehaxe.atlas.AtlasPage;
import spinehaxe.atlas.AtlasRegion;

import spinehaxe.atlas.TextureLoader;

class GAtlasTextureLoader implements TextureLoader {
    private var _texture:GTexture;

    public function new(p_texture:GTexture) {
		_texture = p_texture;
    }

    public function loadPage(page:AtlasPage, path:String) : Void {
        page.rendererObject = _texture;
        page.width = Std.int(_texture.width);
        page.height = Std.int(_texture.height);
    }
	
    public function loadRegion(region:AtlasRegion) : Void {
        //var id:String = (region.page.name == region.name) ? region.name : region.page.name+"_" + region.name;
		var atlas:GTexture = cast region.page.rendererObject;
        var texture:GTexture = GTextureManager.getTexture(atlas.id+"_"+region.name);
        if (texture == null) {
			texture = GTextureManager.createSubTexture(region.name, atlas, new GRectangle(region.x, region.y, region.rotate?region.height:region.width, region.rotate?region.width:region.height), new GRectangle(region.offsetX, region.offsetY, region.rotate?region.originalHeight:region.originalWidth, region.rotate?region.originalWidth:region.originalHeight));
			texture.rotate = region.rotate;
		}

        region.rendererObject = texture;
    }

    public function unloadPage (page:AtlasPage) : Void {
        (page.rendererObject).dispose();
    }

    public function dispose():Void {
    }
}
