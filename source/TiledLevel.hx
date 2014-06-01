package;

import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import haxe.io.Path;

/**
 * ...
 * @author Samuel Batista
 */
class TiledLevel extends TiledMap {
    // For each "Tile Layer" in the map, you must define a "tileset" property which contains the name of a tile sheet image
    // used to draw tiles in that layer (without file extension). The image file must be located in the directory specified bellow.
    private inline static var c_PATH_LEVEL_TILESHEETS = "assets/data/";

    public var foregroundTiles:FlxGroup; // 前面レイヤー(描画用)
    public var backgroundTiles:FlxGroup; // 背面レイヤー(描画用)
    public var player:Player; // プレイヤー

    private var collidableTileLayers:Array<FlxTilemap>; // コリジョンレイヤー

    /**
     * コンストラクタ
     * @param tileLevel *.tmxファイルパス
     **/
    public function new(tiledLevel:Dynamic) {
        // *.tmxファイルのロード
        super(tiledLevel);

        // コリジョン用グループ
        foregroundTiles = new FlxGroup();
        // 背景用グループ
        backgroundTiles = new FlxGroup();

        //FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);

        // TMXファイルをレイヤーに展開する
        // "layers"にレイヤー情報が格納されている
        for(tileLayer in layers) {

            // タイルセットとして扱う名前を取得
            var tileSheetName:String = tileLayer.properties.get("tileset");

            if(tileSheetName == null) {

                // 不正なタイルセット
                throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
            }

            var tileSet:TiledTileSet = null;
            for(ts in tilesets) {
                if(ts.name == tileSheetName) {
                    //
                    tileSet = ts;
                    break;
                }
            }

            if(tileSet == null) {

                // タイルセットが存在しない
                throw "Tileset '" + tileSheetName + " not found. Did you mispell the 'tilesheet' property in " + tileLayer.name + "' layer?";
            }

            var imagePath = new Path(tileSet.imageSource);
            var processedPath = c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;

            // FlxTilemapを使ってロードする
            var tilemap:FlxTilemap = new FlxTilemap();
            tilemap.widthInTiles = width;
            tilemap.heightInTiles = height;
            //tilemap.loadMap(tileLayer.tileArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, FlxTilemap.OFF, 1, 1, 1);
            // CSVにしている場合は csvData を指定する
            tilemap.loadMap(tileLayer.csvData, processedPath, tileSet.tileWidth, tileSet.tileHeight, FlxTilemap.OFF, 1, 1, 1);

            if(tileLayer.properties.contains("nocollide")) {
                // コリジョンなしの場合は背景レイヤー
                backgroundTiles.add(tilemap);
            }
            else {
                // コリジョンありの場合はコリジョンレイヤー
                if(collidableTileLayers == null) {

                    collidableTileLayers = new Array<FlxTilemap>();
                }

                foregroundTiles.add(tilemap);
                collidableTileLayers.push(tilemap);
            }
        }
    }

    /**
     * オブジェクトからインスタンスを生成
     **/
    public function loadObjects(state:PlayState) {
        for(group in objectGroups) {
            for(o in group.objects) {
                loadObject(o, group, state);
            }
        }
    }

    /**
     * オブジェクトからインスタンスを生成
     **/
    private function loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState) {
        var x:Int = o.x;
        var y:Int = o.y;

        // objects in tiled are aligned bottom-left (top-left in flixel)
        if(o.gid != -1) {
            y -= g.map.getGidOwner(o.gid).tileHeight;
        }

        switch (o.type.toLowerCase())
        {
            case "player_start":
                // プレイヤーのスタート地点
                var player = new Player(x, y);
                state.player = player;
                state.add(player);
        }
    }

    public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject -> FlxObject -> Void, ?processCallback:FlxObject -> FlxObject -> Bool):Bool {
        if(collidableTileLayers != null) {
            for(map in collidableTileLayers) {
                // IMPORTANT: Always collide the map with objects, not the other way around.
                //			  This prevents odd collision errors (collision separation code off by 1 px).
                return FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate);
            }
        }
        return false;
    }
}
