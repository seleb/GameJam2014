package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;
import openfl.Assets;
import utils.GamepadUtil;
import utils.SoundManager;
import haxe.io.Eof;
#if flash
#else
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
#end
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

#if flash
#else
import utils.GamepadUtil;
#end

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	//private var _level:FlxTilemap;
	inline static private var TILE_WIDTH:Int = 16;
	inline static private var TILE_HEIGHT:Int = 16;
	
	//Flx Groups
	private var entities:FlxGroup;
	private var doors:FlxGroup;
	private var players:FlxGroup;
	private var npcs:FlxGroup;
	
	private var particles:FlxGroup;
	
	//players
	private var player1:Player;
	private var player2:Player;
	
	//npcs
	private var npcTest:NPC;
	
	#if flash
	#else
	//Utils 
	private var gamepadUtilOne:GamepadUtil;
	private var gamepadUtilTwo:GamepadUtil;
	#end
	
	//Thingies
	private var doorOne:Door;
	private var doorTwo:Door;
	//Sound
	private var soundManager:SoundManager;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void{
		//FlxG.mouse.visible = false;
		FlxG.cameras.bgColor = 0xffaaaaaa;
		
		#if flash
		#else
		generateMapCSV();
		#end
		
		Reg._level = new FlxTilemap();
		Reg._level.loadMap(Assets.getText("assets/level.csv"), "assets/images/testSet.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
		add(Reg._level);
		generateLevel();

		/*for (y in 0...Reg.gameHeight) {
			for (x in 0...Reg.gameWidth) {
				trace(Reg._level.overlapsPoint(new FlxPoint(x, y)));
			}
		}*/
		
		
		
		player1 = new Player();
		player2 = new Player();
		
		//generate npcs
		npcTest = new NPC();
		npcTest.x = 150;
		npcTest.y = 100;
		
		
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		#if flash
	trace("FLASH");
		#else
	trace("!FLASH");
		//Utils
		gamepadUtilOne = new GamepadUtil(0);
		gamepadUtilTwo = new GamepadUtil(1);
		#end
		
		//add entities to FlxGroup
		players = new FlxGroup();
		players.add(player1);
		players.add(player2);
		npcs = new FlxGroup();
		npcs.add(npcTest);
		for(i in 0...Reg.npcCount){
			npcs.add(new NPC());
		}
		entities = new FlxGroup();
		entities.add(players);
		entities.add(npcs);
		
		
		//Thingies
		var doorPath:String = "assets/images/door.png"; 
		doorOne = new Door(Reg.gameWidth/2,50,DOOR,doorPath,0,1);
		doorTwo = new Door(Reg.gameWidth/2,300,DOOR,doorPath,1,0);
		
		doors = new FlxGroup();
		doors.add(doorOne);
		doors.add(doorTwo);
		
		//add thingies
		add(doors);
		
		//add entities to game
		add(entities);
		
		
		//Add Sounds 
		soundManager = new SoundManager();
		soundManager.addSound("door", "assets/music/door.wav");
		
		particles = new FlxGroup();
		add(particles);
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void {
		//reset accelerations
		for (i in 0 ... players.length) {
			cast(players._members[i],Entity).acceleration.x = 0;
		}for (i in 0 ... npcs.length) {
			cast(npcs._members[i],Entity).acceleration.x = 0;
		}
		
		#if flash
		//player1 controls
		if (FlxG.keyboard.anyPressed(["J"])){
			player1.acceleration.x = -player1.maxVelocity.x * 4;
			player1.facing = FlxObject.LEFT;
		}
		if (FlxG.keyboard.anyPressed(["L"])){
			player1.acceleration.x = player1.maxVelocity.x * 4;
			player1.facing = FlxObject.RIGHT;
		}
		if (FlxG.keyboard.justPressed("I")) {
			player1.jump();
		}
		if (FlxG.keyboard.justPressed("K")) {
			player1.attacking = true;
		}
		if (FlxG.keyboard.justPressed("U")) {
			player1.interacting = true;
		}
		
		
		//player2 controls
		if (FlxG.keyboard.anyPressed(["A"])){
			player2.acceleration.x = -player2.maxVelocity.x * 4;
			player2.facing = FlxObject.LEFT;
		}if (FlxG.keyboard.anyPressed(["D"])){
			player2.acceleration.x = player2.maxVelocity.x * 4;
			player2.facing = FlxObject.RIGHT;
		}if (FlxG.keyboard.justPressed("W")) {
			player2.jump();
		}if (FlxG.keyboard.anyPressed(["S"])) {
			player2.attacking = true;
		}
		if (FlxG.keyboard.justPressed("Q")) {
			player2.interacting = true;
		}
		#else
		//player1 controls
		if (FlxG.keyboard.anyPressed(["J"]) || (gamepadUtilOne.getAxis() < -0.5 && gamepadUtilOne.getControllerId() == 0)){
			player1.acceleration.x = -player1.maxVelocity.x * 4;
			player1.facing = FlxObject.LEFT;
		}
		if (FlxG.keyboard.anyPressed(["L"])|| (gamepadUtilOne.getAxis() > 0.5 && gamepadUtilOne.getControllerId() == 0 )){
			player1.acceleration.x = player1.maxVelocity.x * 4;
			player1.facing = FlxObject.RIGHT;
		}
		if ((FlxG.keyboard.justPressed("I")|| (gamepadUtilOne.getPressedbuttons().exists(0)&& gamepadUtilOne.getControllerId() == 0 ))) {
			player1.jump();
		}
		if (FlxG.keyboard.justPressed("K")|| (gamepadUtilOne.getPressedbuttons().exists(1)&& gamepadUtilOne.getControllerId() == 0 )) {
			player1.attacking = true;
		}
		if (FlxG.keyboard.justPressed("U")|| (gamepadUtilOne.getPressedbuttons().exists(3)&& gamepadUtilOne.getControllerId() == 0 )) {
			player1.interacting = true;
		}
		if (gamepadUtilOne.getLastbuttonUp() == 7 && gamepadUtilOne.getControllerId() == 0) {
			player1.destroyGraphics();
			player1.generateGraphics();
			
		}
		
		
		//player2 controls
		if (FlxG.keyboard.anyPressed(["A"])|| (gamepadUtilTwo.getAxis() < -0.5 && gamepadUtilTwo.getControllerId() == 1)){
			player2.acceleration.x = -player2.maxVelocity.x * 4;
			player2.facing = FlxObject.LEFT;
		}if (FlxG.keyboard.anyPressed(["D"])|| (gamepadUtilTwo.getAxis() > 0.5 && gamepadUtilTwo.getControllerId() == 1 )){
			player2.acceleration.x = player2.maxVelocity.x * 4;
			player2.facing = FlxObject.RIGHT;
		}if ((FlxG.keyboard.justPressed("W") || (gamepadUtilTwo.getPressedbuttons().exists(0) && gamepadUtilTwo.getControllerId() == 1))) {
			player2.jump();
		}if (FlxG.keyboard.justPressed("S")|| (gamepadUtilTwo.getPressedbuttons().exists(1)&& gamepadUtilTwo.getControllerId() == 1 )) {
			player2.attacking = true;
		}
		if (FlxG.keyboard.justPressed("Q")|| (gamepadUtilTwo.getPressedbuttons().exists(3)&& gamepadUtilTwo.getControllerId() == 1 )) {
			player2.interacting = true;
		}
		if (gamepadUtilTwo.getLastbuttonUp() == 7 && gamepadUtilTwo.getControllerId() == 1) {
			player2.destroyGraphics();
			player2.generateGraphics();
		}
		
		if (FlxG.keyboard.anyJustPressed(["SPACE"])) {
			entities.callAll("destroyGraphics");
			entities.callAll("generateGraphics");
		}
		#end
		
		
		
		if (FlxG.keyboard.anyJustPressed(["SPACE"])) {
			entities.callAll("destroyGraphics");
			entities.callAll("generateGraphics");
		}
		
		//controls above
		npcs.callAll("moveAlongPath");
		npcs.callAll("tryInteract");
		npcs.callAll("tryJump");
		
		//states/controls above
		super.update();
		//updates below
		manageThingies();
		
		FlxG.collide(Reg._level, entities);
		FlxG.collide(Reg._level, particles,particleCollide);
		particles.callAll("postUpdate");
		
		entities.callAll("postUpdate");
		FlxG.overlap(entities, entities, entityToEntity);
		
		
		//Reset Variables
		entities.setAll("interacting", false);
		entities.callAll("attackDelay");
	}
	public function entityToEntity(attacker:Entity,victim:Entity) {
		if (attacker.interacting) {
			victim.talkBubble.alpha += 0.5;
		}
		if (victim.attacking && victim.attackTimer == 3) {
			makeGibs(attacker.x, attacker.y);
			attacker.kill();
		}
		if (attacker.attacking && attacker.attackTimer == 3) {
			makeGibs(victim.x, victim.y);
			victim.kill();
		}
	}
	public function makeGibs(_x:Float, _y:Float) {
		particles.add(new Particle(_x, _y));
		if(Math.random()>0.1){
		particles.add(new Particle(_x, _y));
			if(Math.random()>0.2){
		particles.add(new Particle(_x, _y));
				if(Math.random()>0.3){
		particles.add(new Particle(_x, _y));
					if(Math.random()>0.4){
		particles.add(new Particle(_x, _y));
						if(Math.random()>0.5){
		particles.add(new Particle(_x, _y));
						}
					}
				}
			}
		}
	}
	public function particleCollide(object1:FlxTilemap, object2:Particle) {
		//trace("collision");
		if(Math.random()<0.01){
			object2.allowCollisions = FlxObject.NONE;
			object2.timer = 8;
		}
	}
	public function manageThingies()
	{
		FlxG.overlap(doors, players, manageDoors);
	}
	
	public function manageDoors(door:Door,entity:Player)
	{
		var otherDoor:Door = getDoorById(door.relatedDoor);
		if (otherDoor != null && entity.interacting)
		{
			entity.x = otherDoor.x;
			entity.y = otherDoor.y - 10;
			soundManager.playSound("door");
		}
		
	}
	
	public function getDoorById(id:Int):Door
	{
		
		for (i in 0 ... doors.length)
		{
			if (cast(doors._members[i], Door).isId(id))
			{
				return (cast(doors._members[i], Door));
			}
		}
		
		return null;
	}
	#if flash
	#else
	public function generateMapCSV() {
		var fname = "assets/level.csv";
		var fout = File.write(fname, false);
		
		//create a level file
		for (i in 0...Math.round(Reg.gameHeight/16)) {
			for (j in 0...Math.round(Reg.gameWidth/16)) {
				fout.writeString("0, ");
			}
			fout.writeString("\n");
		}

		fout.close();
	}
	#end
	public function generateLevel() {
		var tileXNum:Int = Math.round(Reg.gameWidth / 16);
		var tileYNum:Int = Math.round(Reg.gameHeight / 16);
		var tileStartX:Int = Math.round((tileXNum / 6)) - 1;
		var tileEndX:Int = Math.round((tileXNum / 6)) * 5 + 1;
		
		var floorHeight = Math.round((tileYNum - 4) / 4);
		var floorCount = -2;
		
		var trapX:Int;
		var trapY:Int;
		var floorNum:Int = Std.random(4);
		
		//add walls and floors to the level
		for (i in 0...tileYNum) {
			for (j in tileStartX...tileEndX) {
				if (floorCount == (floorHeight - 1) || i == 0 || i == 1 || i == tileYNum - 1 || i == tileYNum - 2) {
						Reg._level.setTile(j, i, 1);
				} else {
					if (j == tileStartX || j == tileStartX + 1 || j == tileEndX - 2 || j == tileEndX - 1) {
						Reg._level.setTile(j, i, 1);
					} else {
						Reg._level.setTile(j, i, 0);
					}
				}
			}
			floorCount++;
			if (floorCount == floorHeight) floorCount = 0;
		}
		
		//randomly insert a trapdoor into one of the floors
		trapX = Std.random((tileEndX - tileStartX)) + 3;
		
		switch(floorNum) {
			case 0:
				trapY = 1 + floorHeight;
			case 1:
				trapY = 1 + floorHeight * 2;
			case 2:
				trapY = 1 + floorHeight * 3;
			default:
				trapY = -1;
		}
		
		for (i in 0...2) {
			for (j in 0...1) {
				Reg._level.setTile(trapX + i, trapY + j, 0);
			}
		}
	}
}