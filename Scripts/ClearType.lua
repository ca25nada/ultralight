-------------------------------------------------------------------
--Methods for generating IIDX-ish ClearType texts given the score--
-------------------------------------------------------------------

local stypetable = { -- Shorthand Versions of ClearType. Not Really used anywhere yet but who knows
	[1]="Marv F-Combo",
	[2]="Whiteflag",
	[3]="SDP",
	[4]="Perf F-Combo",
	[5]="Blackflag",
	[6]="SDG",
	[7]="F-Combo",
	[8]="Missflag",
	[9]="SDCB",
	[10]="Clear",
	[11]="Failed",
	[12]="No Play",
	[13]="-",
	[14]="Rainbowflag",
	[15]="Ragequit" -- can't implement unless there's a way to track playcounts by difficulty
};

local typetable = { -- ClearType texts
	[1]="Marvelous Full Combo",
	[2]="Whiteflag",
	[3]="Single Digit Perfects",
	[4]="Perfect Full Combo",
	[5]="Blackflag",
	[6]="Single Digit Greats",
	[7]="Full Combo",
	[8]="Missflag",
	[9]="Single Digit CBs",
	[10]="Clear",
	[11]="Failed",
	[12]="No Play",
	[13]="-",
	[14]="Rainbowflag",
	[15]="Ragequit"
};

local typecolors = {-- colors corresponding to cleartype
	[1]		= color("#66ccff"),
	[2]		= color("#dddddd"),
	[3] 	= color("#cc8800"),
	[4] 	= color("#eeaa00"),
	[5]		= color("#333333"),
	[6]		= color("#448844"),
	[7]		= color("#66cc66"),
	[8]		= color("#8c6239"),
	[9]		= color("#666666"),
	[10]	= color("#33aaff"),
	[11]	= color("#e61e25"),
	[12]	= color("#666666"),
	[13]	= color("#666666"),
	[14]	= color("#ffffff"),
	[15]	= color("#e61e25")
};

-- ClearTypes based on stage awards and grades.
-- Stageaward based cleartypes do not work if anything causes the stageaward to not show up (disqualification, score saving is off, etc.)
-- and will just result in "Clear". I migggggggggght just drop the SA usage and use raw values instead.
-- returntype = 0 -> ClearType, =1 -> ClearTypeColor, =2 -> ShortClearType
local function clearTypes(stageaward,grade,playcount,misscount,returntype)
	stageaward = stageaward or 0; -- initialize everything incase some are nil
	grade = grade or 0;
	playcount = playcount or 0;
	misscount = misscount or 0;

	clearlevel = 12; -- no play

	if grade == 0 then
		if playcount == 0 then
			clearlevel = 12;
		end;
	else
		if grade == 'Grade_Failed' then -- failed
			clearlevel = 11;
		elseif stageaward == 'StageAward_SingleDigitW2'then -- SDP
			clearlevel = 3;
		elseif stageaward == 'StageAward_SingleDigitW3' then -- SDG
			clearlevel = 6;
		elseif stageaward == 'StageAward_OneW2' then -- whiteflag
			clearlevel = 2;
		elseif stageaward == 'StageAward_OneW3' then -- blackflag
			clearlevel = 5;
		elseif stageaward == 'StageAward_FullComboW1' or grade == 'Grade_Tier01' then -- MFC
			clearlevel = 1;
		elseif stageaward == 'StageAward_FullComboW2' or grade == 'Grade_Tier02'then -- PFC
			clearlevel = 4;
		elseif stageaward == 'StageAward_FullComboW3' then -- FC
			clearlevel = 7;
		else
			if misscount == 1 then 
				clearlevel = 8; -- missflag
			else
				clearlevel = 10; -- Clear
			end;
		end;
	end;
	if returntype == 0 then
		return typetable[clearlevel];
	elseif returntype == 2 then
		return stypetable[clearlevel];
	else
		return typecolors[clearlevel];
	end;
end;

-- Returns the ClearType for Player1
function getClearTypeP1(score)
	if score == nil then
		return typetable[12];
	end;

	if song ~= nil then
		steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
		playcount = profileP1:GetSongNumTimesPlayed(song);
	end;

	if score ~= nil then
		if 1 == score:GetTapNoteScore('TapNoteScore_Miss') and 
			1 == score:GetTapNoteScore('TapNoteScore_W5') and 
			1 == score:GetTapNoteScore('TapNoteScore_W4') and 
			1 == score:GetTapNoteScore('TapNoteScore_W3') then
			return typetable[14];
		else
			stageaward = score:GetStageAward();
			grade = score:GetGrade();
			misscount = score:GetTapNoteScore('TapNoteScore_Miss')+score:GetTapNoteScore('TapNoteScore_W5')+score:GetTapNoteScore('TapNoteScore_W4');
		end;
	end;

	return clearTypes(stageaward,grade,playcount,misscount,0) or typetable[12]; 
end;

-- Returns the shorter version of ClearType for Player1
function getShortClearTypeP1(score)

	if score == nil then
		return stypetable[12];
	end;

	if song ~= nil then
		steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
		playcount = profileP1:GetSongNumTimesPlayed(song);
	end;

	if score ~= nil then
		if 1 == score:GetTapNoteScore('TapNoteScore_Miss') and 
			1 == score:GetTapNoteScore('TapNoteScore_W5') and 
			1 == score:GetTapNoteScore('TapNoteScore_W4') and 
			1 == score:GetTapNoteScore('TapNoteScore_W3') then
			return stypetable[14];
		else
			stageaward = score:GetStageAward();
			grade = score:GetGrade();
			misscount = score:GetTapNoteScore('TapNoteScore_Miss')+score:GetTapNoteScore('TapNoteScore_W5')+score:GetTapNoteScore('TapNoteScore_W4');
		end;
	end;

	return clearTypes(stageaward,grade,playcount,misscount,2) or stypetable[12];
end;

-- Returns the color corresponding to the ClearType for Player1
function getClearColorP1(score)
	if score == nil then
		return typecolors[12];
	end;

	if song ~= nil then
		steps = GAMESTATE:GetCurrentSteps(PLAYER_1);
		playcount = profileP1:GetSongNumTimesPlayed(song);
	end;

	if score ~= nil then
		if 1 == score:GetTapNoteScore('TapNoteScore_Miss') and 
			1 == score:GetTapNoteScore('TapNoteScore_W5') and 
			1 == score:GetTapNoteScore('TapNoteScore_W4') and 
			1 == score:GetTapNoteScore('TapNoteScore_W3') then
			return typecolors[14];
		else
			stageaward = score:GetStageAward();
			grade = score:GetGrade();
			misscount = score:GetTapNoteScore('TapNoteScore_Miss')+score:GetTapNoteScore('TapNoteScore_W5')+score:GetTapNoteScore('TapNoteScore_W4');
		end;
	end;

	return clearTypes(stageaward,grade,playcount,misscount,1) or typecolors[12];
end;


-- Same as above, but for player2
function getClearTypeP2(score)
	if song ~= nil then
		steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
		playcount = profileP2:GetSongNumTimesPlayed(song);
	end;

	if score ~= nil then
		if 1 == score:GetTapNoteScore('TapNoteScore_Miss') and 
			1 == score:GetTapNoteScore('TapNoteScore_W5') and 
			1 == score:GetTapNoteScore('TapNoteScore_W4') and 
			1 == score:GetTapNoteScore('TapNoteScore_W3') then
			return typetable[14];
		else
			stageaward = score:GetStageAward();
			grade = score:GetGrade();
			misscount = score:GetTapNoteScore('TapNoteScore_Miss')+score:GetTapNoteScore('TapNoteScore_W5')+score:GetTapNoteScore('TapNoteScore_W4');
		end;
	end;

	return clearTypes(stageaward,grade,playcount,misscount,0) or typecolors[12];
end;

function getShortClearTypeP2(score)

	if song ~= nil then
		steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
		playcount = profileP2:GetSongNumTimesPlayed(song);
	end;

	if score ~= nil then
		if 1 == score:GetTapNoteScore('TapNoteScore_Miss') and 
			1 == score:GetTapNoteScore('TapNoteScore_W5') and 
			1 == score:GetTapNoteScore('TapNoteScore_W4') and 
			1 == score:GetTapNoteScore('TapNoteScore_W3') then
			return stypetable[14];
		else
			stageaward = score:GetStageAward();
			grade = score:GetGrade();
			misscount = score:GetTapNoteScore('TapNoteScore_Miss')+score:GetTapNoteScore('TapNoteScore_W5')+score:GetTapNoteScore('TapNoteScore_W4');
		end;
	end;

	return clearTypes(stageaward,grade,playcount,misscount,2) or typetable[12];
end;

function getClearColorP2(score)
	if song ~= nil then
		steps = GAMESTATE:GetCurrentSteps(PLAYER_2);
		playcount = profileP2:GetSongNumTimesPlayed(song);
	end;

	if score ~= nil then
		if 1 == score:GetTapNoteScore('TapNoteScore_Miss') and 
			1 == score:GetTapNoteScore('TapNoteScore_W5') and 
			1 == score:GetTapNoteScore('TapNoteScore_W4') and 
			1 == score:GetTapNoteScore('TapNoteScore_W3') then
			return typecolors[14];
		else
			stageaward = score:GetStageAward();
			grade = score:GetGrade();
			misscount = score:GetTapNoteScore('TapNoteScore_Miss')+score:GetTapNoteScore('TapNoteScore_W5')+score:GetTapNoteScore('TapNoteScore_W4');
		end;
	end;

	return clearTypes(stageaward,grade,playcount,misscount,1) or typecolors[12];
end;


-- Methods for other uses (manually setting colors/text, etc.)

function getClearTypeText(index)
	return typetable[index];
end;

function getShortClearTypeText(index)
	return stypetable[index];
end;

function getClearTypeColor(index)
	return typecolors[index];
end;

--]]