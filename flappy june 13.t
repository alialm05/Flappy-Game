%ALI ALMAAMOURI MADE THIS%
import GUI
setscreen ("graphics:1440;1080")

var font1, font2, font3 : int
font1 := Font.New ("FredokaOne:24:Bold")
font2 := Font.New ("FredokaOne:18:Bold")

var stremin, stremout : int
open : stremin, "Highscores.txt", get

var Highscore : real := 0

var x, y, but : int
var leftSide, rightSide : int
leftSide := 0
rightSide := 1440

var MadeObst : boolean := false
var ObstWidth : int := 50
var obstClearance : int := 200

var X_Array : flexible array 0 .. 10 of int
var Y_Array : flexible array 0 .. 10 of int
var S_Array : flexible array 0 .. 10 of boolean
var H_Array : flexible array 0 .. 10 of int
var chars : array char of boolean

var flySpeed : real := 0.2

var plrYPos : int := round (maxy / 2)
var plrXPos : int := round (maxx / 4)
var plrSize : int := 25

var currJumpHeight : real := 0
var jumped : boolean := false
var CanJump : boolean := true
var died : boolean := false
var jumpedTime : int := 0
var obstMadeTime : int := 1000
var flyIncreaseTime : int := Time.Elapsed

var up : int := 0
var Pos_i : int := 0

var startPos : int := maxx + 100
var ObstHeight : int := 250


for i : 0 .. upper (S_Array)
    S_Array (i) := false
end for

var timeInc : int := 0
var jumpedCooldown : int := 100
var obstMadeCooldown : int := 1000
var flyIncreaseCooldown : int := 10000

%drawfillbox (0, 0, maxx, maxy, 78)

process playMusic ()
    loop
	Music.PlayFile ("8-bit-arcade.mp3")
    end loop
end playMusic
fork playMusic ()

var name : string

put " \n "
Font.Draw ("Enter Your Full Name", 30, maxy - 25, font2, black)
delay (99)

get name : *


var allscores : flexible array 0 .. 1 of string
var allNames : flexible array 0 .. 1 of string
loop
    var dataLine : string
    exit when eof (stremin)
    get : stremin, dataLine
    var colon : int := 0

    new allscores, upper (allscores) + 1
    allscores (upper (allscores)) := dataLine

    for i : 1 .. length (dataLine)
	if dataLine (i) = ":" then
	    colon := i
	    exit
	end if
    end for

    if colon = 0 then
	exit
    end if

    new allNames, upper (allNames) + 1
    allNames (upper (allNames)) := dataLine (1 .. colon - 1)

    if Str.Lower (dataLine (1 .. colon - 1)) = Str.Lower (name) then
	Highscore := strreal (dataLine (colon + length ("highscore = ") .. length (dataLine)))
    end if
end loop


close : stremin

procedure saveGame ()
    open : stremout, "Highscores.txt", put

    if upper (allNames) > 0 then
	for i : 1 .. upper (allNames)
	    if name = allNames(i) then
		
	    end if
	end for
    else

    end if

    loop
	var dataLine : string
	exit when eof (stremin)
	get : stremin, dataLine
	var colon : int := 0

	for i : 1 .. length (dataLine)
	    if dataLine (i) = ":" then
		colon := i
		exit
	    end if
	end for

	if colon = 0 then
	    exit
	end if
	if Str.Lower (dataLine (1 .. colon)) = Str.Lower (name) then
	    put : stremout, (dataLine (colon + length ("highscore = ") .. length (dataLine) - 3)) + realstr (Highscore, 1)
	    exit
	else
	    put : stremout, name + ": highscore = " + realstr (Highscore, 1)
	    exit
	end if
    end loop
    quit
end saveGame


var saveBut : int := GUI.CreateButtonFull (maxx - 150, maxy - 50, 0, "Save Highscore", saveGame, 45, '~', false)

process buttonD
    loop
	exit when GUI.ProcessEvent
    end loop
end buttonD
fork buttonD

delay (999)
setscreen ("offscreenonly")

var timer : real := 0
var start : real := 0
% start game loop
function gameStart () : int
    loop
	% check if player died, if died start a new game
	if not died then

	    timer := Time.Elapsed - start

	    drawfillbox (0, 0, maxx, maxy, 78)
	    Font.Draw (realstr (round (timer / 100) / 10, 1), 10, maxy - 50, font1, white)
	    Font.Draw ("Highscore: " + realstr (Highscore, 1), 10, maxy - 150, font2, white)

	    % detect if space bar is pressed, sets the jumped variable to true
	    Input.KeyDown (chars)
	    if chars (' ') then
		if not jumped then
		    jumped := true
		    jumpedTime := Time.Elapsed
		end if
	    end if

	    % if the jumped variable is true, the plr Y position is increased
	    if jumped then
		currJumpHeight += 1 / 5
		plrYPos := min (plrYPos + max (0, round (7 - currJumpHeight)), maxy - plrSize)
	    else % else, the player moves down due to gravity
		if timeInc mod 2 = 0 then
		    plrYPos -= 2
		else
		    plrYPos -= 3
		end if
	    end if

	    %PLAYER
	    %draws the player
	    drawfilloval (plrXPos, plrYPos, plrSize, plrSize, red)

	    timeInc := timeInc + 1
	    if not MadeObst then
		X_Array (Pos_i) := startPos
		Y_Array (Pos_i) := 0
		S_Array (Pos_i) := true

		if Pos_i > 0 then
		    randint (ObstHeight, max (round ((H_Array (Pos_i - 1) / 100)) - 2, 4), min (round ((H_Array (Pos_i - 1) / 100)) + 2, 8))
		else
		    randint (ObstHeight, 4, 8)
		end if

		ObstHeight *= 100
		H_Array (Pos_i) := ObstHeight

		if Pos_i = 15 then
		    Pos_i := 0
		else
		    Pos_i := (Pos_i + 1) mod (upper (X_Array) + 1)
		end if
		MadeObst := true
		obstMadeTime := Time.Elapsed
	    else
	    end if


	    % check for obstacles touching
	    for i : 0 .. upper (X_Array)
		if S_Array (i) then
		    %bottom obst
		    drawfillbox (X_Array (i), Y_Array (i), X_Array (i) + ObstWidth, H_Array (i), green)
		    %upper obst
		    drawfillbox (X_Array (i), maxy, X_Array (i) + ObstWidth, H_Array (i) + obstClearance, green)

		    X_Array (i) -= 3

		    if (plrXPos + (plrSize)) >= X_Array (i) and (plrXPos - (plrSize)) <= X_Array (i) + ObstWidth then
			if (plrYPos - (plrSize - (plrSize / 2))) <= H_Array (i) or (plrYPos + (plrSize - (plrSize / 2))) >= H_Array (i) + obstClearance then
			    died := true
			end if
		    end if

		end if
	    end for


	    %% check player died
	    if died or plrYPos - (plrSize * 2) <= plrSize * 2 then
		died := true
	    end if


	    saveBut := GUI.CreateButtonFull (maxx - 150, maxy - 50, 0, "Save Highscore", saveGame, 45, '~', false)

	    View.Update ()
	    delay (round (1 / flySpeed))
	    cls


	    if Time.Elapsed - flyIncreaseTime >= flyIncreaseCooldown then
		flyIncreaseTime := Time.Elapsed
		flySpeed += 0.05
	    end if

	    if Time.Elapsed - obstMadeTime >= obstMadeCooldown then
		MadeObst := false
	    end if

	    if Time.Elapsed - jumpedTime >= jumpedCooldown then
		jumped := false
		currJumpHeight := 0
	    end if


	else
	    Music.PlayFileStop
	    died := false
	    new X_Array, 15
	    new Y_Array, 15
	    new S_Array, 15
	    new H_Array, 15
	    for i : 0 .. upper (S_Array)
		S_Array (i) := false
	    end for
	    flyIncreaseTime := Time.Elapsed
	    flySpeed := 0.2
	    start := Time.Elapsed
	    plrYPos := round (maxy * 0.75)

	    if timer >= Highscore then
		Highscore := round (timer / 100) / 10
	    end if

	end if
    end loop

end gameStart

var g : int := gameStart ()

