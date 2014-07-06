-- this file is outdated now, I think.
-- colors for each theme should live somewhere else because I'm nutty like that.

themeColors = {
	judgecolor = {
		[1] = color('#eebb00'),
		[2] = color('#eebb00'),
		[3] = color('#eebb00'),
		[4] = color('#66ccff'),
		[5] = color("#e61e25"),
		[6] = color("#e61e25"),
		[7] = color("#c97bff"),
		[8] = color("#c97bff"),
		[9] = color("#ed0972")
	},

 	lifecolor = {
		[1] = color('#eebb00'),
		[2] = color('#66ccff'),
		[3] = color("#e61e25"),
		[4] = color("#e61e25"),
		[5] = color("#c97bff"),
		[6] = color("#c97bff"),
		[7] = color("#ed0972")
	},

	Player = {
		P1 = color("ffffff"),
		P2 = HSV(195,0.8,1),
	},
	Difficulty = {
		Beginner	= color("#ff32f8"),			-- light cyan
		Easy		= color("#2cff00"),			-- green
		Medium		= color("#ddaa00"),			-- yellow
		Hard		= color("#e61e25"),			-- red
		Challenge	= color("#66ccff"),			-- light blue
		Edit		= color("0.8,0.8,0.8,1"),	-- gray
		Couple		= color("#ed0972"),			-- hot pink
		Routine		= color("#ff9a00"),			-- orange

		Difficulty_Beginner	= color("#c97bff"),		-- purple
		Difficulty_Easy		= color("#099948"),		-- green
		Difficulty_Medium	= color("#ddaa00"),		-- yellow
		Difficulty_Hard		= color("#e61e25"),		-- red
		Difficulty_Challenge	= color("#66ccff"),	-- light blue
		Difficulty_Edit 	= color("0.8,0.8,0.8,1"),	-- gray
		Difficulty_Couple	= color("#ed0972"),			-- hot pink
		Difficulty_Routine	= color("#ff9a00"),			-- orange
	},
	Grade = {
		Grade_Tier01	= color("#66ccff"), -- AAAA
		Grade_Tier02	= color("#eebb00"), -- AAA
		Grade_Tier03	= color("#66cc66"), -- AA
		Grade_Tier04	= color("#da5757"), -- A
		Grade_Tier05	= color("#5b78bb"), -- B
		Grade_Tier06	= color("#c97bff"), -- C
		Grade_Tier07	= color("#8c6239"), -- D
		Grade_Failed	= color("0.8,0.8,0.8,1"), -- F
		Grade_None		= color("#666666"), -- no play
	}
};

-- temporary:
function StageToColor( stage )
	return color("#FFFFFF");
end

-- specific functions
function LifeColor (lifediff)
	return themeColors.lifecolor[lifediff] or color("#ffffff")
end;

function JudgeColor (judgediff)
	return themeColors.judgecolor[judgediff] or color("#ffffff")
end;

function PlayerColor(pn)
	return themeColors.Player[ ToEnumShortString(pn) ];
end;

function CustomGradeColor (grade)
	return themeColors.Grade[grade] or color("ffffcc");
end;

function CustomDifficultyToColor(diff)
	return themeColors.Difficulty[diff] or color("1,0,0,1");
end;

-- judgment colors
local tnsColors = {
	TapNoteScore_W1 = HSV(48,0.2,1),
	TapNoteScore_W2 = HSV(48,0.8,0.95),
	TapNoteScore_W3 = HSV(160,0.9,0.8),
	TapNoteScore_W4 = HSV(200,0.9,1),
	TapNoteScore_W5 = HSV(320,0.9,1),
	TapNoteScore_Miss = HSV(0,0.8,0.8),
};
function TapNoteScoreToColor(tns) return tnsColors[tns]; end;