var parentHUDElements = FindDotaHudElement("HUDElements");
$.GetContextPanel().SetParent(parentHUDElements);

function SetNewQuest(data) 
{
	$.GetContextPanel().FindChildTraverse("CurrentQuest").FindChildTraverse("QuestName").text = $.Localize("#" + data.quest_name)
	$.GetContextPanel().FindChildTraverse("CurrentQuest").FindChildTraverse("QuestProgressLabel").text = $.Localize("#" + data.quest_name + "_description")
	$.GetContextPanel().FindChildTraverse("CurrentQuest").FindChildTraverse("QuestProgressCountLabel").text = data.min + " / " + data.max
	var percentage = ((data.max-data.min)*100)/data.max
	$.GetContextPanel().FindChildTraverse("CurrentQuest").FindChildTraverse("QuestProgressFront").style.width =  (100 - percentage) +'%';
}

function SetQuestProgress(data) {
	$.GetContextPanel().FindChildTraverse("CurrentQuest").FindChildTraverse("QuestProgressCountLabel").text = data.min + " / " + data.max
	var percentage = ((data.max-data.min)*100)/data.max
	$.GetContextPanel().FindChildTraverse("CurrentQuest").FindChildTraverse("QuestProgressFront").style['width'] = (100 - percentage) +'%';
}

function ActivateQuest() {
	$.GetContextPanel().FindChildTraverse("CurrentQuest").style.opacity = "1"
}

GameEvents.Subscribe( 'pucci_quest_event_activate', ActivateQuest ); 
GameEvents.Subscribe( 'pucci_quest_event_set_quest', SetNewQuest ); 
GameEvents.Subscribe( 'pucci_quest_event_set_progress', SetQuestProgress ); 