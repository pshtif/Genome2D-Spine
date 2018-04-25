/**
 * Created with IntelliJ IDEA.
 * User: Peter "sHTiF" Stefcek
 * Date: 17.5.2013
 * Time: 14:03
 * To change this template use File | Settings | File Templates.
 */
package com.genome2d.spine;

import com.genome2d.geom.GRectangle;
import com.genome2d.context.GBlendMode;
import spinehaxe.Bone;
import spinehaxe.attachments.RegionAttachment;
import spinehaxe.Slot;
import com.genome2d.context.IGContext;
import com.genome2d.geom.GMatrix;
import com.genome2d.spine.GAtlasAttachmentLoader;
import com.genome2d.spine.GAtlasTextureLoader;
import com.genome2d.textures.GTexture;
import spinehaxe.animation.AnimationState;
import spinehaxe.animation.AnimationStateData;
import spinehaxe.atlas.Atlas;
import spinehaxe.Skeleton;
import spinehaxe.SkeletonData;
import spinehaxe.SkeletonJson;

class GSpine
{
    private var _attachmentLoader:GAtlasAttachmentLoader;
    private var _atlasLoader:GAtlasTextureLoader;

    private var _states:Map<String,AnimationState>;
    private var _activeState:AnimationState;

    private var _skeletons:Map<String,Skeleton>;
    private var _activeSkeleton:Skeleton;

    public function new(p_atlas:String, p_texture:GTexture, p_defaultAnim:String = "stand"):Void {
        _skeletons = new Map<String,Skeleton>();
        _states = new Map<String,AnimationState>();

        _atlasLoader = new GAtlasTextureLoader(p_texture);

        var atlas:Atlas = new Atlas(p_atlas, _atlasLoader);
        _attachmentLoader = new GAtlasAttachmentLoader(atlas);
    }

    public function setAttachment(p_slotName:String, p_attachmentName:String):Void {
        for (skeleton in _skeletons) {
            skeleton.setAttachment(p_slotName, p_attachmentName);
        }
    }

    public function setSkin(p_skinName:String):Void {
        for (skeleton in _skeletons) {
            skeleton.skinName = p_skinName;
        }
    }

    public function addSkeleton(p_id:String, p_json:String):Void {
        var json:SkeletonJson = new SkeletonJson(_attachmentLoader);
        var skeletonData:SkeletonData = json.readSkeletonData(p_json);
        var skeleton:Skeleton = new Skeleton(skeletonData);
        skeleton.updateWorldTransform();
        _skeletons.set(p_id, skeleton);

        var stateData:AnimationStateData = new AnimationStateData(skeletonData);
        var state:AnimationState = new AnimationState(stateData);
        _states.set(p_id, state);
    }

    public function setActiveSkeleton(p_skeletonId:String):Void {
        if (_skeletons.get(p_skeletonId) != null && _activeSkeleton != _skeletons.get(p_skeletonId)) {
            _activeSkeleton = _skeletons.get(p_skeletonId);
            _activeState = _states.get(p_skeletonId);
        }
    }

    public function setAnimation(p_trackIndex:Int, p_animId:String, p_loop:Bool):Void {
        _activeState.setAnimationByName(p_trackIndex, p_animId, p_loop);
        //_activeState.update(Math.random());
    }

    public function update(p_deltaTime:Float):Void {
        if (_activeState != null) {
            _activeState.update(p_deltaTime / 1000);
            _activeState.apply(_activeSkeleton);
            _activeSkeleton.updateWorldTransform();
        }
    }

    public function render(p_x:Float, p_y:Float, p_scaleX:Float, p_scaleY:Float):Void {
        var matrix:GMatrix = new GMatrix();
        var context:IGContext = Genome2D.getInstance().getContext();

        if (_activeSkeleton != null) {
            var drawOrder:Array<Slot> = _activeSkeleton.drawOrder;

            for (i in 0...drawOrder.length) {
                var slot:Slot = drawOrder[i];
                var regionAttachment:RegionAttachment = cast slot.attachment;
                if (regionAttachment != null) {
                    var bone:Bone = slot.bone;

                    var texture:GTexture = cast regionAttachment.rendererObject;
                    matrix.identity();
                    matrix.scale(p_scaleX, p_scaleY);
                    matrix.scale(regionAttachment.scaleX,regionAttachment.scaleY);
                    matrix.rotate(-regionAttachment.rotation * Math.PI/180 + (texture.rotate?Math.PI / 2:0));
                    matrix.scale(bone.worldScaleX, bone.worldScaleY);
                    matrix.rotate(bone.worldRotationX * Math.PI / 180);
                    matrix.translate(p_x + p_scaleX * (bone.worldX + regionAttachment.x * bone.a + regionAttachment.y * bone.b), p_y + p_scaleY * (bone.worldY  + regionAttachment.x * bone.c + regionAttachment.y * bone.d));

                    context.drawMatrix(texture, GBlendMode.NORMAL, matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty, slot.r, slot.g, slot.b, slot.a);
                }
            }
        }
    }

    public function dispose():Void {
        // Not sure this should be disposed if there is potentional reuse
        if (_atlasLoader != null) {
            _atlasLoader.dispose();
        }
    }
}