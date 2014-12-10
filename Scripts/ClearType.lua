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
	[15]="Ragequit"
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
-- Stageaward based cleartypes do not work if player "clears" midway through the song (by holding enter during gameplay etc.) 
-- and will just result in "Clear" 
local function clearTypes(stageaward,grade,playcount,misscount,returntype)
	stageaward = stageaward or 0;
	grade = grade or 0;
	playcount = playcount or 0;
	misscount = misscount or 0;

	local cleartype =  typetable[12];
	local scleartype = stypetable[12];
	local clearcolor=  typecolors[12];

	if grade == -1 then
		if playcount == 0 then
			cleartype =  typetable[12]; -- no play
			scleartype =  stypetable[12]; -- no play
			clearcolor = typecolors[12];
		end;
	else
		if grade == 'Grade_Failed' then -- failed
			cleartype =  typetable[11];
			scleartype =  stypetable[11];
			clearcolor = typecolors[11];
		elseif stageaward == 'StageAward_SingleDigitW2'then -- SDP
			cleartype =  typetable[3];
			scleartype =  stypetable[3];
			clearcolor = typecolors[3];
		elseif stageaward == 'StageAward_SingleDigitW3' then -- SDG
			cleartype =  typetable[6];
			scleartype =  stypetable[6];
			clearcolor = typecolors[6];
		elseif stageaward == 'StageAward_OneW2' then -- whiteflag
			cleartype =  typetable[2];
			scleartype =  stypetable[2];
			clearcolor = typecolors[2];
		elseif stageaward == 'StageAward_OneW3' then -- blackflag
			cleartype =  typetable[5];
			scleartype =  stypetable[5];
			clearcolor = typecolors[5];
		elseif stageaward == 'StageAward_FullComboW1' or grade == 'Grade_Tier01' then -- MFC
			cleartype =  typetable[1];
			scleartype =  stypetable[1];
			clearcolor = typecolors[1];
		elseif stageaward == 'StageAward_FullComboW2' or grade == 'Grade_Tier02'then -- PFC
			cleartype =  typetable[4];
			scleartype =  stypetable[4];
			clearcolor = typecolors[4];
		elseif stageaward == 'StageAward_FullComboW3' then -- FC
			cleartype =  typetable[7];
			scleartype =  stypetable[7];
			clearcolor = typecolors[7];
		else
			if misscount == 1 then 
				cleartype =  typetable[8];
				scleartype = stypetable[8];
				clearcolor = typecolors[8]; -- missflag
			else
				cleartype =  typetable[10];
				scleartype = stypetable[10];
				clearcolor = typecolors[10]; -- Clear
			end;
		end;
	end;
	if returntype == 0 then
		return cleartype;
	elseif returntype == 2 then
		return scleartype;
	else
		return clearcolor;
	end;
end;

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