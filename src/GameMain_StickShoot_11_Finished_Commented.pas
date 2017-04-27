program StickShoot;
uses SwinGame, sgTypes, SysUtils;

type
	//Enums declared up the top
	Pew = (Pew1, Pew2, Pew3, Pew4, Pew5, Pew6); //One random sound played when bullets fired
	Hit = (Squish, Grant); //One random sound played when man hit/killed

	//Records declared
	//Records for an individual stickman
	StickMan = record
		xPos, yPos : Integer;
		ani : Sprite;
		dX, dY : Integer;
		dance : String;
		stillAlive: Boolean;
		Named : String;
	end;

	//record to define a bullet
	bullet = record
		xPos, yPos : Integer;
		ani : Sprite;
		inUse : Boolean;
		cheat : Integer;
	end;

	//record to define a turret
	turret = record
		xPos, yPos : Integer;
		bmp : Bitmap;
		bullet: bullet;
	end;

	//had to have one field for each stick figure rather than having an array of figures.
	gameData = record
		Steve : StickMan;
		Bob : StickMan;
		Pete : StickMan;
		John : StickMan;
		Frank : StickMan;
		Carl : StickMan;
		score : Integer;
		level : Integer;
		speed : Integer;
		turret : array of turret;
	end;

// Instead of deleting this, leaving this failed procedure commented out.
// procedure StickCollide(var man: StickMan; const game: gameData); Horrible Failure
// begin
// 	if SpriteCollision(man.ani, game.Steve.ani) or SpriteCollision(man.ani, game.Bob.ani) or SpriteCollision(man.ani, game.Pete.ani) or SpriteCollision(man.ani, game.John.ani) or SpriteCollision(man.ani, game.Frank.ani) or SpriteCollision(man.ani, game.Carl.ani) then
// 	begin
// 		SpriteSetDX(man.ani, ((Round(Rnd() * 10 - 5))));
// 	end;
// end;

//Returns a random D to be used for dX or dY which effects the rate which the stickmen moves.
//This can't be 0 so they won't be stationary.
function RandD(const game: gameData): Integer;
begin
	result := 0;
	while result = 0 do
	begin
		result := ((Round(Rnd(game.speed))));
	end;
end;

//Same as RandD except it can return positive or negative random number.
//Required when initialising the game.
function InitialRandD(const game: gameData): Integer;
begin
	result := 0;
	while result = 0 do
	begin
		result := RandD(game) - RandD(game);
	end;
end;

//Bounces the Stickmen when they hit the wall.
procedure BounceStickMan(var man: StickMan; const game: gameData);
begin
	if man.stillAlive then
	begin
		if SpriteX(man.ani) >= (ScreenWidth()-SpriteWidth(man.ani)) then //off the far right
		begin
			// SpriteSetDY(man.ani, ((Round(Rnd() * 10 - 5))));
			SpriteSetDX(man.ani, (-1 * RandD(game)));
			SpriteSetX(man.ani, ScreenWidth()-SpriteWidth(man.ani));
		end;
		if SpriteX(man.ani) <=0 then //off the far left
		begin
			// SpriteSetDY(man.ani, ((Round(Rnd() * 10 - 5))));
			SpriteSetDX(man.ani, RandD(game));
			SpriteSetX(man.ani, 0);
		end;
		if SpriteY(man.ani) >= ((ScreenHeight()-SpriteHeight(man.ani))*0.66) then //off the bottom
		begin
			SpriteSetDY(man.ani, (-1 * RandD(game)));
			// SpriteSetDX(man.ani, ((Round(Rnd() * 10 - 5))));
			SpriteSetY(man.ani, (ScreenHeight()-SpriteHeight(man.ani))*0.66);
		end;
		if SpriteY(man.ani) <=0 then //off the top
		begin
			SpriteSetDY(man.ani, RandD(game));
			// SpriteSetDX(man.ani, ((Round(Rnd() * 10 - 5))));
			SpriteSetY(man.ani, 0);
		end;
	end;
end;

//Goes through all the stickmen one after the other checking if they have hit the wall/need to bounce against the wall.
procedure BounceStickMen(var game: gameData);
begin
	BounceStickMan(Game.Steve, game);
	BounceStickMan(Game.Bob, game);
	BounceStickMan(Game.Pete, game);
	BounceStickMan(Game.John, game);
	BounceStickMan(Game.Frank, game);
	BounceStickMan(Game.Carl, game);
	// StickCollide(game.Steve, game);
	// StickCollide(game.Bob, game);
	// StickCollide(game.Pete, game);
	// StickCollide(game.John, game);
	// StickCollide(game.Frank, game);
	// StickCollide(game.Carl, game);
end;

//Draws the individual turret.
procedure DrawTurret(const turret: turret);
begin
	DrawSprite(turret.bullet.ani);
	DrawBitmap(turret.bmp, turret.xPos, turret.yPos);
end;

//Goes through all the turrets and draws them.
procedure DrawTurrets(var game: gameData);
var
	i: Integer;
begin
	for i := Low(game.turret) to High(game.turret) do
		DrawTurret(game.turret[i]);
end;

//Checks if the specific sprite is alive before drawing them.
procedure AliveCheck(man: Stickman);
begin
	if man.stillAlive then
		DrawSprite(man.ani);
end;

//Draws the entire game.
procedure DrawGame(var game: gameData);
var
	i: Integer;
begin
	AliveCheck(game.Steve);
  AliveCheck(game.Bob);
  AliveCheck(game.Pete);
  AliveCheck(game.John);
  AliveCheck(game.Frank);
  AliveCheck(game.Carl);
  DrawTurrets(game);
 	DrawText('Score: ' + IntToStr(game.score), ColorBlack, 0, 0);
 	DrawText('Level: ' + IntToStr(game.level), ColorBlack, 0, 10);
  RefreshScreen(60 );
  UpdateSprite(game.Steve.ani);
  UpdateSprite(game.Bob.ani);
  UpdateSprite(game.Pete.ani);
  UpdateSprite(game.John.ani);
  UpdateSprite(game.Frank.ani);
  UpdateSprite(game.Carl.ani);
  for i:= Low(game.turret) to High(game.turret) do
 		UpdateSprite(game.turret[i].bullet.ani);
end;

//Puts the individual stickman on screen the first time, setting their initial position/dX/dY/Sprites and animations.
procedure InsertStickMan(const man: StickMan);
begin
    SpriteStartAnimation(man.ani, man.dance);
		SpriteSetX(man.ani, man.xPos);
    SpriteSetY(man.ani, man.yPos);
    SpriteSetDX(man.ani, man.dX);
    SpriteSetDY(man.ani, man.dY);
end;

//Draws the bullets on screen.
procedure InsertBullet(const turret: turret);
begin
	SpriteSetX(turret.bullet.ani, turret.bullet.xPos);
	SpriteSetY(turret.bullet.ani, turret.bullet.yPos);
	SpriteSetDX(turret.bullet.ani, 0);
	SpriteSetDY(turret.bullet.ani, 0);
end;

//cycles through all the Stickmen and puts them on screen as well as the bullets for the turrets.
procedure InsertStickMen(const game: gameData);
var
	i: Integer;
begin
	InsertStickMan(game.Steve);
	InsertStickMan(game.Bob);
	InsertStickMan(game.Pete);
	InsertStickMan(game.John);
	InsertStickMan(game.Frank);
	InsertStickMan(game.Carl);
	for i := Low(game.turret) to High(game.turret) do
		InsertBullet(game.turret[i]);
end;

//Assigns dances to the stickmen depending on their name.
function AssignDance(const Guy: StickMan):String;
begin
	case guy.Named of
		'Steve'	:	result := 'Steve';
		'Bob'	:	result := 'Bob';
		'Pete'	:	result := 'Pete';
		'John'	:	result := 'John';
		'Frank'	:	result := 'Frank';
		'Carl'	:	result := 'Carl';
	end;
end;

//Creates the data for each individual stickman.
function SpawnStickMan(var Guy: StickMan; game: gameData): StickMan;
begin
	result.dance := AssignDance(Guy);
	result.ani := CreateSprite(BitmapNamed('StickDances' )  ,AnimationScriptNamed('stickShoot_Ani' ) );
	result.xPos := Rnd(ScreenWidth() - SpriteWidth(result.ani));
	result.yPos := Round(Rnd(ScreenHeight() - SpriteHeight(result.ani))*0.5);
	result.dX := InitialRandD(game);
	result.dY := InitialRandD(game);
	result.stillAlive := TRUE;
end;

//Creates the blank stickmen to begin with, then calls SpawnStickman to fill in the data for all stickmen.
procedure SpawnStickMen(var game: gameData);
begin
	game.Steve.Named := 'Steve';
	game.Steve := SpawnStickMan(game.Steve, game);
	game.Bob.Named := 'Bob';
	game.Bob := SpawnStickMan(game.Bob, game);
	game.Pete.Named := 'Pete';
	game.Pete := SpawnStickMan(game.Pete, game);
	game.John.Named := 'John';
	game.John := SpawnStickMan(game.John, game);
	game.Frank.Named := 'Frank';
	game.Frank := SpawnStickMan(game.Frank, game);
	game.Carl.Named := 'Carl';
	game.Carl := SpawnStickMan(game.Carl, game);
end;

//Calculates the x position of each turret based on how many turrets there are and which turret it is.
function CalcTurretX(i, t: Integer): Integer;
begin
	result := Round((((i+1)*(1/(t+1))*ScreenWidth))-(BitmapWidth(BitmapNamed('Tankret'))/2));
end;

//Creates data for each bullet.
function CreateBullet(i, t: Integer):Bullet;
begin
	result.ani := CreateSprite(BitmapNamed('Bullet') );
	result.xPos := CalcTurretX(i,t) + Round(BitmapWidth(BitmapNamed('Tankret'))/2);
	result.yPos := (ScreenHeight-BitmapHeight(BitmapNamed('Tankret')));
	result.InUse := FALSE;
	result.cheat := 1;
end;

//Creates data for each turret.
function SpawnTurret(i, t: Integer):turret;
begin
	result.bmp := BitmapNamed('Tankret');
	result.bullet := CreateBullet(i, t);
	result.yPos := (ScreenHeight-BitmapHeight(BitmapNamed('Tankret')));
	result.xPos := CalcTurretX(i, t);
end;

//Creates all turrets.
procedure SpawnTurrets(var game: gameData; const turrets: Integer);
var
	i: Integer;
begin
	SetLength(game.turret, turrets);
	for i := Low(game.turret) to High(game.turret) do
		game.turret[i] := SpawnTurret(i, turrets);
end;

//Frees the Sprites for when the game is closed.
procedure FreeStickMen(var game: gameData);
begin
    FreeSprite(game.Steve.ani);
    FreeSprite(game.Bob.ani);
    FreeSprite(game.Pete.ani);
    FreeSprite(game.John.ani);
    FreeSprite(game.Frank.ani);
    FreeSprite(game.Carl.ani);
end;

//Plays one of the random 'Pew' sounds.
procedure PlayPew();
var
	randomPew : Pew;
begin
	randomPew := Pew(Rnd(6));
	case randomPew of
		Pew1:	PlaySoundEffect('Pew1');
		Pew2:	PlaySoundEffect('Pew2');
		Pew3:	PlaySoundEffect('Pew3');
		Pew4:	PlaySoundEffect('Pew4');
		Pew5:	PlaySoundEffect('Pew5');
		Pew6:	PlaySoundEffect('Pew6');
	end;
end;

//Plays one of the random 'Hit' sounds.
procedure PlayHit();
var
	randomHit : Hit;
begin
	randomHit := Hit(Rnd(2));
	case randomHit of
		Squish: PlaySoundEffect('Squish');
		Grant: PlaySoundEffect('Grant');
	end;
end;

//Resets/reloads the bullet back to the starting position and removes velocity from it. Also allows it to be fired again.
procedure TurretReset(var turret: turret);
begin
	SpriteSetY(turret.bullet.ani, turret.yPos);
	SpriteSetDY(turret.bullet.ani, 0);
	turret.bullet.InUse := FALSE;
end;

//Checks if a bullet has hit a stickman.
procedure HitCheck(var man: StickMan; var turret: turret; var game: gameData);
begin
	if SpriteCollision(man.ani, turret.bullet.ani) then
	begin
		man.stillAlive := FALSE;
		TurretReset(turret);
		SpriteSetY(man.ani, -20);
		SpriteSetX(man.ani, -20);
		SpriteSetDY(man.ani, 0);
		SpriteSetDX(man.ani, 0);
		PlayHit();
		game.score += 1;
	end;
end;

//Goes through all the bullets and checks if the individual bullet has then hit any of the stickmen.
procedure UpdateGame(var game: gameData);
var
	i: Integer;
begin
	for i := Low(game.turret) to High(game.turret) do
	begin
		HitCheck(game.Steve, game.turret[i], game);
		HitCheck(game.Bob, game.turret[i], game);
		HitCheck(game.Pete, game.turret[i], game);
		HitCheck(game.John, game.turret[i], game);
		HitCheck(game.Frank, game.turret[i], game);
		HitCheck(game.Carl, game.turret[i], game);
		if SpriteY(game.turret[i].bullet.ani) <= 0 then
		begin
			TurretReset(game.turret[i]);
		end;
	end;
end;

//Handles the player input.
procedure HandleInput(var game: gameData);
var
	i: Integer;
begin
	for i := Low(game.turret) to High(game.turret) do
	begin
		if MouseClicked(LeftButton) and BitmapPointCollision(game.turret[i].bmp, game.turret[i].xPos, game.turret[i].yPos, MouseX(), MouseY()) then
		begin
			if not game.turret[i].bullet.InUse then
			begin
				game.turret[i].bullet.InUse := not game.turret[i].bullet.InUse;
				PlayPew();
				SpriteSetDY(game.turret[i].bullet.ani, -(game.speed*game.turret[i].bullet.cheat));
			end;
		end;
		if KeyDown(VK_Q) and KeyTyped(VK_W) then
			game.turret[i].bullet.cheat += 5;
		if KeyDown(VK_A) and KeyTyped(VK_S) then
			game.turret[i].bullet.cheat -= 5;
	end;
end;

//Checks if all the stickmen are still alive. If they aren't, levels up the game, respawns all the stickmen and speeds the game up.
procedure LevelUp(var game: gameData);
begin
	if not game.Steve.stillAlive and not game.Bob.stillAlive and not game.Pete.stillAlive and not game.John.stillAlive and not game.Frank.stillAlive and not game.Carl.stillAlive then
	begin
		game.speed +=1;
		SpawnStickMen(game);
		InsertStickMen(game);
		game.score += (game.speed*2);
		game.level += 1;
	end;
end;

procedure Main();
var
	MainGameData: gameData; //create a data record for all the data to fit in
begin
	MainGameData.score := 0;
	MainGameData.speed := 3; //Must be 3 or more to start.
	MainGameData.level := 1;
	OpenAudio(); //allows the usage of audio
	OpenGraphicsWindow('Test', 400, 300); //opens the 'game' window
	LoadDefaultColors(); //loads colours
	LoadResourceBundle('stickshoot_bundle.txt'); //stickshoot_bundle loads resources. Edit this file when changing sounds and sprites.
	SpawnStickMen(MainGameData);
	SpawnTurrets(MainGameData, 3); //Changes how many turrets there are available to use. Auto-scales their positions so they are always evenly positioned.
	InsertStickMen(MainGameData);
  repeat //repeatedly draws and redraws the game screen until it the window is closed
      ClearScreen(ColorWhite ); //first, clear the entire screen to white.
      ProcessEvents(); //SwinGame requires ProcessEvents to 'listen' for player inputs such as mouse or keyboard inputs
      BounceStickMen(MainGameData); //check if the stickmen have hit a wall and make them 'bounce'
      HandleInput(MainGameData); //does things according to the player inputs
      UpdateGame(MainGameData); //updates multiple aspects. Probably should have called it something different
      LevelUp(MainGameData); //checks if it needs to increase the level/respawn the Stickmen
      DrawGame(MainGameData); //Draws everything to the window/canvas
	until WindowCloseRequested();
  Delay(800); //after the window has been closed wait 0.8 seconds
  FreeStickMen(MainGameData);
  CloseAudio();
  ReleaseAllResources(); //free all resources so the game doesn't waste memory on the computer when it's closed
end;

begin
	Main();
end.
