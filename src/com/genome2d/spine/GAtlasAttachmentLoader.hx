/*
 * 	Genome2D - 2D GPU Framework
 * 	http://www.genome2d.com
 *
 *	Copyright 2011-2019 Peter Stefcek. All rights reserved.
 *
 *	License:: ./doc/LICENSE.md (https://github.com/pshtif/Genome2D/blob/master/LICENSE.md)
 */
package com.genome2d.spine;

import spinehaxe.atlas.AtlasRegion;
import spinehaxe.attachments.PathAttachment;
import com.genome2d.textures.GTexture;

import spinehaxe.Bone;
import spinehaxe.Skin;
import spinehaxe.atlas.Atlas;
import spinehaxe.attachments.AttachmentLoader;
import spinehaxe.attachments.BoundingBoxAttachment;
import spinehaxe.attachments.MeshAttachment;
import spinehaxe.attachments.RegionAttachment;

class GAtlasAttachmentLoader implements AttachmentLoader {
    private var g2d_atlas:Atlas;
    public function new(p_atlas:Atlas) {
        g2d_atlas = p_atlas;

        Bone.yDown = true;
    }

    public function newRegionAttachment(p_skin:Skin, p_name:String, p_path:String) : RegionAttachment {
        var regionAttachment:RegionAttachment = new RegionAttachment(p_name);

        //var texture:GTexture = GTextureManager.getTexture(g2d_atlasPrefix+"_"+p_name);
        var texture:GTexture = cast g2d_atlas.findRegion(p_path).rendererObject;
        regionAttachment.rendererObject = texture;
        regionAttachment.regionOffsetX = texture.pivotX * texture.width;
        regionAttachment.regionOffsetY = texture.pivotY * texture.height;
        regionAttachment.regionWidth = texture.width;
        regionAttachment.regionHeight = texture.height;
        regionAttachment.regionOriginalWidth = texture.width;
        regionAttachment.regionOriginalHeight = texture.height;
        return regionAttachment;
    }
    public function newMeshAttachment(skin:Skin, name:String, path:String):MeshAttachment {
        var attachment:MeshAttachment = new MeshAttachment(name);

        var texture:GTexture = cast g2d_atlas.findRegion(path).rendererObject;

        attachment.rendererObject = texture;
//
        var region:AtlasRegion = g2d_atlas.findRegion(path);

        var scaleX:Float = 1;
        var scaleY:Float = 1;
        attachment.regionU = 0;
        attachment.regionV = 0;
        attachment.regionU2 = 1;
        attachment.regionV2 = 1;
        attachment.regionRotate = region.rotate;
        attachment.regionOffsetX = texture.pivotX * texture.width;
        attachment.regionOffsetY = texture.pivotY * texture.height;
        attachment.regionWidth = texture.width;
        attachment.regionHeight = texture.height;
        attachment.regionOriginalWidth = texture.width;
        attachment.regionOriginalHeight = texture.height;
        return attachment;
    }



    /** @return May be null to not load an attachment. */
    public function newBoundingBoxAttachment (skin:Skin, name:String) : BoundingBoxAttachment {
        return null;
    }

    public function newPathAttachment(skin:Skin, name:String):PathAttachment {
        return null;
    }
}
