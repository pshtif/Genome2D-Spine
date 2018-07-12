/**
 * Created with IntelliJ IDEA.
 * User: Peter "sHTiF" Stefcek
 * Date: 17.5.2013
 * Time: 14:03
 * To change this template use File | Settings | File Templates.
 */
package com.genome2d.spine;

import spinehaxe.attachments.MeshAttachment;
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

    private var _matrix:GMatrix;

    public function new(p_atlas:String, p_texture:GTexture, p_defaultAnim:String = "stand"):Void {
        _skeletons = new Map<String,Skeleton>();
        _states = new Map<String,AnimationState>();

        _atlasLoader = new GAtlasTextureLoader(p_texture);

        var atlas:Atlas = new Atlas(p_atlas, _atlasLoader);
        _attachmentLoader = new GAtlasAttachmentLoader(atlas);
        
        _matrix = new GMatrix();
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
        var context:IGContext = Genome2D.getInstance().getContext();

        if (_activeSkeleton != null) {
            var drawOrder:Array<Slot> = _activeSkeleton.drawOrder;
            var texture:GTexture;
            var meshVertices:Array<Float>;

            for (i in 0...drawOrder.length) {
                var slot:Slot = drawOrder[i];
                if (Std.is(slot.attachment, RegionAttachment)) {
                    var regionAttachment:RegionAttachment = cast slot.attachment;
                    var bone:Bone = slot.bone;

                    texture = cast regionAttachment.rendererObject;
                    _matrix.identity();
                    _matrix.scale(p_scaleX * regionAttachment.scaleX, p_scaleY * regionAttachment.scaleY);
                    _matrix.rotate(-regionAttachment.rotation * Math.PI/180 + (texture.rotate?Math.PI / 2:0));
                    _matrix.scale(bone.worldScaleX, bone.worldScaleY);
                    _matrix.rotate(bone.worldRotationX * Math.PI / 180);

                    _matrix.translate(p_x + p_scaleX*(bone.worldX + regionAttachment.x * bone.a + regionAttachment.y * bone.b), p_y + p_scaleY*(bone.worldY + regionAttachment.x * bone.c + regionAttachment.y * bone.d));
//                    matrix.translate(p_x + bone.worldX + regionAttachment.x * bone.a + regionAttachment.y * bone.b, p_y + bone.worldY + regionAttachment.x * bone.c + regionAttachment.y * bone.d);

                    context.drawMatrix(texture, GBlendMode.NORMAL, _matrix.a, _matrix.b, _matrix.c, _matrix.d, _matrix.tx, _matrix.ty);
                } else if (Std.is(slot.attachment, MeshAttachment)) {

                    var meshAttachment:MeshAttachment = cast slot.attachment;
                    var bone:Bone = slot.bone;

                    meshVertices = [];
                    meshAttachment.computeWorldVertices(slot,meshVertices);
                    texture = cast meshAttachment.rendererObject;
                    var uvs:Array<Float> = [];
                    var vs:Array<Float> = [];
                    for (j in 0...meshAttachment.triangles.length) {
                        vs.push(meshVertices[meshAttachment.triangles[j]*2]);
                        vs.push(meshVertices[meshAttachment.triangles[j]*2+1]);
                        uvs.push(meshAttachment.uvs[meshAttachment.triangles[j]*2]);
                        uvs.push(meshAttachment.uvs[meshAttachment.triangles[j]*2+1]);
                    }

                    context.drawPoly(texture, GBlendMode.NORMAL, vs, uvs, p_x, p_y, p_scaleX, p_scaleY, 0, 1, 1, 1, 1);
                    
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