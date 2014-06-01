package;

import flash.errors.Error;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
 
/**
 * ...
 * @author .:BuzzJeux:.
 */
class PlayState extends FlxState
{
	public var player:Player;
	private var _level:TiledLevel;
	private var _howto:FlxText;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		bgColor = 0xFF18A068;

        // Tiled Map Editorファイルの読み込み
		_level = new TiledLevel("assets/data/map.tmx");

        // 背面レイヤーのオブジェクト登録
		add(_level.backgroundTiles);

        // 前面レイヤーのオブジェクト登録
		add(_level.foregroundTiles);
		
        // プレイヤーオブジェクト生成
		_level.loadObjects(this);
		
		#if !mobile
		// Set and create Txt Howto
		_howto = new FlxText(0, 225, FlxG.width);
		_howto.alignment = "center";
		_howto.text = "Use the ARROW KEYS or WASD to move around.";
		_howto.scrollFactor.set(0, 0);
		add(_howto);
		#end
	}
	
	override public function update():Void
	{
        if(FlxG.keys.justPressed.ESCAPE) {
            throw new Error("terminate.");
        }

		super.update();
		
		// Collide with foreground tile layer
		if (_level.collideWithLevel(player))
		{
            // 衝突しているので移動しない
			player.moveToNextTile = false;
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		player = null;
		_level = null;
		_howto = null;
	}
}
