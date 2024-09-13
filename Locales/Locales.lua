----------------------------------------------------------------------------------------
-- Locales.lua
-- AUTHOR: mtpeterson1948 at gmail dot com
-- ORIGINAL DATE: 26 April, 2023
----------------------------------------------------------------------------------------
local ADDON_NAME, AutoEquip = ...

AutoEquip = AutoEquip or {}
AutoEquip.Locales = {}
local locale = AutoEquip.Locales

local EMPTY_STR = ""
local SUCCESS	= true
local FAILURE	= false

local function getExpansionName( )
    local expansionLevel = GetExpansionLevel()
    local expansionNames = { -- Use numeric keys to map expansion levels to names
        [0] = "Classic (Vanilla)",
        [1] = "Classic (Burning Crusade)",
        [2] = "Classic (WotLK)",
        [3] = "Classic (Cataclysm)",
        [4] = "Classic (Mists of Pandaria)",
        [5] = "Classic (Warlords of Draenor)",
        [6] = "Classic (Legion)",
        [7] = "Classic (Battle for Azeroth)",
        [8] = "Shadowlands",
        [9] = "Dragon Flight",
        [10] = "The War Within"
    }
    return expansionNames[expansionLevel]
end

-- Form a string representing the library's version number.
local MAJOR = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MAJOR")
local MINOR = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MINOR")
local PATCH = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-PATCH")

local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

AutoEquip.Locales = L 

-- Common strings that don't change across locales
local version = string.format("%s.%s.%s", MAJOR, MINOR, PATCH )
local expansionName = getExpansionName()

L["ADDON_NAME"]			= ADDON_NAME
L["VERSION"]			= version
L["EXPANSION_NAME"]		= expansionName 
L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", ADDON_NAME, version, expansionName )

local LOCALE = GetLocale()   

if LOCALE == "enUS" then 

	L["INFO_MSG_FRAME"]				= "Information Messages"
	L["ERROR_MSG_FRAME"] 			= "Error Messages"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "Left Click to display In-Game Options Menu."
	L["TITLE_HELP_MSG_FRAME"]		= string.format("Help Menu\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("Error Notification\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("Messages\n(%s)", L["ADDON_AND_VERSION"] )	
	
	L["ADDON_LOADED_MSG"]			= string.format("%s Loaded.", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "Left click to display the %s Options Menu.", L["ADDON_NAME"] )

	L["DESCR_SUBHEADER"] = "%s: An Addon to Save & Restore Resting Armor Sets"
	L["LINE1"]			= string.format("%s is intended to automatically equip an armor set [usually]\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("containing one or more Heirloom items when the character enters\n")
	L["LINE3"] 			= string.format("a rest area (e.g, an Inn or a city). The set the character was wearing\n")
	L["LINE4"]			= string.format("when entering the rest area will be restored when the character leaves.\n\n")
	L["LINE6"]			= string.format("Slash Commands\n")
	L["LINE7"]			= string.format("/auto - Displays this help frame.\n")
	L["LINE8"] 			= string.format("/auto help - Also, displays this help frame.\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - Enables and disables debug tracing.\n")

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip is used to automatically and transparently equip\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("a specific armor set when entering a rest area. Usually\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("this means an armor set containing one or more Heirloom items.\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("NOTE: When/if you create a new set, you will need to logout or\n")
	L["OPTIONS_TEXT_LINE5"] = string.format("reload (/reload) for the sets icon to become visible to %s.\n", ADDON_NAME )

	L["LOGIN_MESSAGE"] 				= "[%s] At Login %s was equipped with %s (Id %d)."
	L["DEBUGGING_ENABLED"]  		= "[%s] Debugging Now Enabled."
	L["DEBUGGING_DISABLED"] 		= "[%s] Debugging Now Disabled"
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s switched to %s set (Id %d)."
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] Player not equipped with a defined set."
	L["LEFT_REST_AREA"]				= "%s Left Rest area. Equipped  the %s set. "
	L["ENTERED_REST_AREA"] 			= "%s Entered Rest Area. Equipped the %s set. "

	L["FAILED_TO_EQUIP_SET"] 		= "ERROR: Failed to equip %s set. "
	L["SET_DOES_NOT_EXIST"]			= "ERROR: Specified set (%s) does not exist."
	L["EQUIPSET_MISSING_ITEMS"] 	= "ERROR: The %s set is XXX missing one or more items.\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "ERROR: The %s set is unusable.\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "ERROR: %s's equipment sets are unusable."

	L["NO_EQUIPMENT_SETS_DEFINED"]  = "ERROR: %s has no equipment sets defined." -- @@ Retranslate this entry
	L["LEVEL_REQUIREMENT"]			= "INFO: %s must be level 10 or above to use the equipment manager."
	L["CURRENT_EQUIPPED_SET"]		= "INFO: Currently Equipped: %s\n"

end

if LOCALE == "frFR" then
	L["INFO_MSG_FRAME"]				= "Messages d'information"
	L["ERROR_MSG_FRAME"] 			= "Messages d'erreur"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "Clic gauche pour afficher le menu des options en jeu."
	L["TITLE_HELP_MSG_FRAME"]		= string.format("Menu d'aide\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("Notification d'erreur\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("Messages\n(%s)", L["ADDON_AND_VERSION"] )	
		
	L["ADDON_LOADED_MSG"]			= string.format("%s chargé.", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "Clic gauche pour afficher le menu des options de %s.", L["ADDON_NAME"] )
	
	L["DESCR_SUBHEADER"] = "%s: Un addon pour sauvegarder et restaurer les ensembles d'armure de repos"
	L["LINE1"]			= string.format("%s est conçu pour équiper automatiquement un ensemble d'armure [généralement]\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("contenant un ou plusieurs objets d'héritage lorsque le personnage entre\n")
	L["LINE3"] 			= string.format("dans une zone de repos (par ex., une auberge ou une ville). L'ensemble que portait le personnage\n")
	L["LINE4"]			= string.format("en entrant dans la zone de repos sera restauré lorsqu'il en sortira.\n\n")
	L["LINE6"]			= string.format("Commandes Slash\n")
	L["LINE7"]			= string.format("/auto - Affiche cette fenêtre d'aide.\n")
	L["LINE8"] 			= string.format("/auto help - Affiche également cette fenêtre d'aide.\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - Active ou désactive le suivi de débogage.\n")
	
	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip est utilisé pour équiper automatiquement et en toute transparence\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("un ensemble d'armure spécifique lors de l'entrée dans une zone de repos. Généralement\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("cela signifie un ensemble d'armure contenant un ou plusieurs objets d'héritage.\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("REMARQUE : Si vous créez un nouvel ensemble, vous devrez vous déconnecter ou\n")
	L["OPTIONS_TEXT_LINE5"] = string.format("recharger (/reload) pour que l'icône de l'ensemble devienne visible pour %s.\n", ADDON_NAME )
	
	L["LOGIN_MESSAGE"] 				= "[%s] À la connexion, %s a équipé %s (Id %d)."
	L["DEBUGGING_ENABLED"]  		= "[%s] Débogage activé."
	L["DEBUGGING_DISABLED"] 		= "[%s] Débogage désactivé."
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s a changé pour l'ensemble %s (Id %d)."
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] Le joueur n'a pas d'ensemble d'équipement défini."
	L["LEFT_REST_AREA"]				= "%s a quitté la zone de repos. Équipement de l'ensemble %s."
	L["ENTERED_REST_AREA"] 			= "%s est entré dans la zone de repos. Équipement de l'ensemble %s."
	
	L["FAILED_TO_EQUIP_SET"] 		= "ERREUR : Échec de l'équipement de l'ensemble %s."
	L["SET_DOES_NOT_EXIST"]			= "ERREUR : L'ensemble spécifié (%s) n'existe pas."
	L["EQUIPSET_MISSING_ITEMS"] 	= "ERREUR : L'ensemble %s est incomplet.\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "ERREUR : L'ensemble %s est inutilisable.\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "ERREUR : Les ensembles d'équipement de %s sont inutilisables."
	
	L["NO_EQUIPMENT_SETS_DEFINED"]  = "ERREUR : %s n'a pas d'ensemble d'équipement défini."
	L["LEVEL_REQUIREMENT"]			= "INFO : %s doit être au niveau 10 ou supérieur pour utiliser le gestionnaire d'équipement."
	L["CURRENT_EQUIPPED_SET"]		= "INFO : Ensemble actuellement équipé : %s\n"
end

if LOCALE == "deDE" then
	L["INFO_MSG_FRAME"]				= "Informationsnachrichten"
	L["ERROR_MSG_FRAME"] 			= "Fehlermeldungen"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "Linksklick, um das Optionsmenü im Spiel anzuzeigen."
	L["TITLE_HELP_MSG_FRAME"]		= string.format("Hilfemenü\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("Fehlermeldung\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("Nachrichten\n(%s)", L["ADDON_AND_VERSION"] )	
		
	L["ADDON_LOADED_MSG"]			= string.format("%s geladen.", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "Linksklick, um das %s-Optionsmenü anzuzeigen.", L["ADDON_NAME"] )
	
	L["DESCR_SUBHEADER"] = "%s: Ein Addon zum Speichern und Wiederherstellen von Rüstungssets für Ruhephasen"
	L["LINE1"]			= string.format("%s ist dazu gedacht, automatisch ein Rüstungsset anzulegen [normalerweise]\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("das ein oder mehrere Erbstücke enthält, wenn der Charakter\n")
	L["LINE3"] 			= string.format("eine Ruhezone betritt (z.B. ein Gasthaus oder eine Stadt). Das Set, das der Charakter\n")
	L["LINE4"]			= string.format("beim Betreten der Ruhezone trug, wird beim Verlassen wiederhergestellt.\n\n")
	L["LINE6"]			= string.format("Slash-Befehle\n")
	L["LINE7"]			= string.format("/auto - Zeigt dieses Hilfefenster an.\n")
	L["LINE8"] 			= string.format("/auto help - Zeigt ebenfalls dieses Hilfefenster an.\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - Aktiviert oder deaktiviert die Debugverfolgung.\n")
	
	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip wird verwendet, um automatisch und transparent\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("ein bestimmtes Rüstungsset beim Betreten einer Ruhezone anzulegen. Normalerweise\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("bedeutet dies ein Rüstungsset, das ein oder mehrere Erbstücke enthält.\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("HINWEIS: Wenn Sie ein neues Set erstellen, müssen Sie sich abmelden oder\n")
	L["OPTIONS_TEXT_LINE5"] = string.format("/reload verwenden, damit das Set-Symbol für %s sichtbar wird.\n", ADDON_NAME )
	
	L["LOGIN_MESSAGE"] 				= "[%s] Beim Login wurde %s mit %s (Id %d) ausgestattet."
	L["DEBUGGING_ENABLED"]  		= "[%s] Debugging jetzt aktiviert."
	L["DEBUGGING_DISABLED"] 		= "[%s] Debugging jetzt deaktiviert."
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s hat auf das Set %s (Id %d) gewechselt."
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] Spieler hat kein definiertes Set ausgerüstet."
	L["LEFT_REST_AREA"]				= "%s hat die Ruhezone verlassen. Set %s wurde angelegt."
	L["ENTERED_REST_AREA"] 			= "%s hat die Ruhezone betreten. Set %s wurde angelegt."
	
	L["FAILED_TO_EQUIP_SET"] 		= "FEHLER: Ausrüsten des %s-Sets fehlgeschlagen."
	L["SET_DOES_NOT_EXIST"]			= "FEHLER: Angegebenes Set (%s) existiert nicht."
	L["EQUIPSET_MISSING_ITEMS"] 	= "FEHLER: Das Set %s fehlt ein oder mehrere Gegenstände.\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "FEHLER: Das Set %s ist nicht nutzbar.\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "FEHLER: Die Ausrüstungssets von %s sind nicht nutzbar."
	
	L["NO_EQUIPMENT_SETS_DEFINED"]  = "FEHLER: %s hat keine Ausrüstungssets definiert."
	L["LEVEL_REQUIREMENT"]			= "INFO: %s muss mindestens Stufe 10 sein, um den Ausrüstungsmanager zu verwenden."
	L["CURRENT_EQUIPPED_SET"]		= "INFO: Derzeit ausgerüstetes Set: %s\n"
	
end

if LOCALE == "itIT" then
	L["INFO_MSG_FRAME"]				= "Messaggi di informazioni"
	L["ERROR_MSG_FRAME"] 			= "Messaggi di errore"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "Clic sinistro per visualizzare il menu delle opzioni in gioco."
	L["TITLE_HELP_MSG_FRAME"]		= string.format("Menu di aiuto\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("Notifica di errore\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("Messaggi\n(%s)", L["ADDON_AND_VERSION"] )	
		
	L["ADDON_LOADED_MSG"]			= string.format("%s caricato.", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "Clic sinistro per visualizzare il menu delle opzioni di %s.", L["ADDON_NAME"] )
	
	L["DESCR_SUBHEADER"] = "%s: Un addon per salvare e ripristinare i set di armature di riposo"
	L["LINE1"]			= string.format("%s è progettato per equipaggiare automaticamente un set di armature [di solito]\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("che contiene uno o più oggetti cimelio quando il personaggio entra\n")
	L["LINE3"] 			= string.format("in un'area di riposo (ad esempio, una locanda o una città). Il set che il personaggio stava\n")
	L["LINE4"]			= string.format("indossando quando è entrato nell'area di riposo verrà ripristinato all'uscita.\n\n")
	L["LINE6"]			= string.format("Comandi Slash\n")
	L["LINE7"]			= string.format("/auto - Visualizza questa finestra di aiuto.\n")
	L["LINE8"] 			= string.format("/auto help - Visualizza anche questa finestra di aiuto.\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - Abilita o disabilita la traccia di debug.\n")
	
	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip viene utilizzato per equipaggiare automaticamente e in modo trasparente\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("un set specifico di armature quando si entra in un'area di riposo. Di solito\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("questo significa un set di armature che contiene uno o più oggetti cimelio.\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("NOTA: Se crei un nuovo set, dovrai disconnetterti o\n")
	L["OPTIONS_TEXT_LINE5"] = string.format("ricaricare (/reload) per rendere visibile l'icona del set a %s.\n", ADDON_NAME )
	
	L["LOGIN_MESSAGE"] 				= "[%s] Al login, %s è stato equipaggiato con %s (Id %d)."
	L["DEBUGGING_ENABLED"]  		= "[%s] Debugging abilitato."
	L["DEBUGGING_DISABLED"] 		= "[%s] Debugging disabilitato."
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s ha cambiato al set %s (Id %d)."
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] Il giocatore non ha un set definito equipaggiato."
	L["LEFT_REST_AREA"]				= "%s ha lasciato l'area di riposo. Equipaggiato il set %s."
	L["ENTERED_REST_AREA"] 			= "%s è entrato nell'area di riposo. Equipaggiato il set %s."
	
	L["FAILED_TO_EQUIP_SET"] 		= "ERRORE: Fallito l'equipaggiamento del set %s."
	L["SET_DOES_NOT_EXIST"]			= "ERRORE: Il set specificato (%s) non esiste."
	L["EQUIPSET_MISSING_ITEMS"] 	= "ERRORE: Il set %s manca di uno o più oggetti.\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "ERRORE: Il set %s non è utilizzabile.\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "ERRORE: I set di equipaggiamento di %s non sono utilizzabili."
	
	L["NO_EQUIPMENT_SETS_DEFINED"]  = "ERRORE: %s non ha set di equipaggiamento definiti."
	L["LEVEL_REQUIREMENT"]			= "INFO: %s deve essere di livello 10 o superiore per utilizzare il gestore degli equipaggiamenti."
	L["CURRENT_EQUIPPED_SET"]		= "INFO: Set attualmente equipaggiato: %s\n"
end

if LOCALE == "koKR" then
	L["INFO_MSG_FRAME"]				= "정보 메시지"
	L["ERROR_MSG_FRAME"] 			= "오류 메시지"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "게임 옵션 메뉴를 표시하려면 왼쪽 클릭하세요."
	L["TITLE_HELP_MSG_FRAME"]		= string.format("도움말 메뉴\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("오류 알림\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("메시지\n(%s)", L["ADDON_AND_VERSION"] )	
		
	L["ADDON_LOADED_MSG"]			= string.format("%s 로드되었습니다.", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "%s 옵션 메뉴를 표시하려면 왼쪽 클릭하세요.", L["ADDON_NAME"] )
	
	L["DESCR_SUBHEADER"] = "%s: 휴식 중 착용한 장비 세트를 저장 및 복원하는 애드온"
	L["LINE1"]			= string.format("%s는 캐릭터가 휴식 구역에 들어갈 때 자동으로 장비 세트를 착용하도록\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("설계되었습니다. 일반적으로 상속 장비를 포함하는 세트를 장착합니다.\n")
	L["LINE3"] 			= string.format("캐릭터가 휴식 구역에 들어갈 때 착용한 장비는\n")
	L["LINE4"]			= string.format("구역을 나올 때 복원됩니다.\n\n")
	L["LINE6"]			= string.format("슬래시 명령어\n")
	L["LINE7"]			= string.format("/auto - 이 도움말 창을 표시합니다.\n")
	L["LINE8"] 			= string.format("/auto help - 이 도움말 창도 표시합니다.\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - 디버그 추적을 활성화 또는 비활성화합니다.\n")
	
	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip은 휴식 구역에 들어갈 때 특정 장비 세트를\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("자동으로 투명하게 착용하도록 사용됩니다. 일반적으로\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("상속 장비를 포함하는 장비 세트를 의미합니다.\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("참고: 새 세트를 만들면 %s에 아이콘이 표시되려면\n", ADDON_NAME )
	L["OPTIONS_TEXT_LINE5"] = string.format("로그아웃하거나 /reload 명령어로 재시작해야 합니다.\n")
	
	L["LOGIN_MESSAGE"] 				= "[%s] 로그인 시 %s이(가) %s (Id %d)를 착용했습니다."
	L["DEBUGGING_ENABLED"]  		= "[%s] 디버깅이 활성화되었습니다."
	L["DEBUGGING_DISABLED"] 		= "[%s] 디버깅이 비활성화되었습니다."
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s이(가) %s 세트 (Id %d)로 전환되었습니다."
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] 플레이어가 정의된 세트를 착용하지 않았습니다."
	L["LEFT_REST_AREA"]				= "%s이(가) 휴식 구역을 떠났습니다. %s 장비 세트를 착용했습니다."
	L["ENTERED_REST_AREA"] 			= "%s이(가) 휴식 구역에 들어갔습니다. %s 장비 세트를 착용했습니다."
	
	L["FAILED_TO_EQUIP_SET"] 		= "오류: %s 세트 장착에 실패했습니다."
	L["SET_DOES_NOT_EXIST"]			= "오류: 지정된 세트 (%s)가 존재하지 않습니다."
	L["EQUIPSET_MISSING_ITEMS"] 	= "오류: %s 세트에 일부 아이템이 없습니다.\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "오류: %s 세트는 사용할 수 없습니다.\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "오류: %s의 장비 세트를 사용할 수 없습니다."
	
	L["NO_EQUIPMENT_SETS_DEFINED"]  = "오류: %s은(는) 정의된 장비 세트가 없습니다."
	L["LEVEL_REQUIREMENT"]			= "정보: %s은(는) 장비 관리자를 사용하려면 10레벨 이상이어야 합니다."
	L["CURRENT_EQUIPPED_SET"]		= "정보: 현재 착용한 세트: %s\n"
	
end

if LOCALE == "ruRU" then
	L["INFO_MSG_FRAME"]				= "Информационные сообщения"
	L["ERROR_MSG_FRAME"] 			= "Сообщения об ошибках"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "ЛКМ для отображения меню настроек в игре."
	L["TITLE_HELP_MSG_FRAME"]		= string.format("Меню помощи\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("Уведомление об ошибке\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("Сообщения\n(%s)", L["ADDON_AND_VERSION"] )	
		
	L["ADDON_LOADED_MSG"]			= string.format("%s загружен.", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "ЛКМ для отображения меню настроек %s.", L["ADDON_NAME"] )
	
	L["DESCR_SUBHEADER"] = "%s: Аддон для сохранения и восстановления комплектов брони для отдыха"
	L["LINE1"]			= string.format("%s предназначен для автоматической смены комплекта брони [обычно]\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("включающего один или несколько наследуемых предметов, когда персонаж входит\n")
	L["LINE3"] 			= string.format("в зону отдыха (например, таверну или город). Комплект, который был на персонаже\n")
	L["LINE4"]			= string.format("при входе в зону отдыха, будет восстановлен при выходе.\n\n")
	L["LINE6"]			= string.format("Команды слэш\n")
	L["LINE7"]			= string.format("/auto - Показывает это окно помощи.\n")
	L["LINE8"] 			= string.format("/auto help - Также показывает это окно помощи.\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - Включает и выключает отладку.\n")
	
	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip используется для автоматического и прозрачного надевания\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("определенного комплекта брони при входе в зону отдыха. Обычно это\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("комплект брони, включающий один или несколько наследуемых предметов.\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("ПРИМЕЧАНИЕ: Если вы создаете новый комплект, вам нужно выйти из игры или\n")
	L["OPTIONS_TEXT_LINE5"] = string.format("перезагрузиться (/reload), чтобы значок комплекта стал видимым для %s.\n", ADDON_NAME )
	
	L["LOGIN_MESSAGE"] 				= "[%s] При входе %s был экипирован с %s (Id %d)."
	L["DEBUGGING_ENABLED"]  		= "[%s] Отладка включена."
	L["DEBUGGING_DISABLED"] 		= "[%s] Отладка отключена."
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s сменил комплект на %s (Id %d)."
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] Игрок не экипирован определенным комплектом."
	L["LEFT_REST_AREA"]				= "%s покинул зону отдыха. Экипирован комплект %s."
	L["ENTERED_REST_AREA"] 			= "%s вошел в зону отдыха. Экипирован комплект %s."
	
	L["FAILED_TO_EQUIP_SET"] 		= "ОШИБКА: Не удалось экипировать комплект %s."
	L["SET_DOES_NOT_EXIST"]			= "ОШИБКА: Указанный комплект (%s) не существует."
	L["EQUIPSET_MISSING_ITEMS"] 	= "ОШИБКА: В комплекте %s отсутствует один или несколько предметов.\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "ОШИБКА: Комплект %s не может быть использован.\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "ОШИБКА: Комплекты экипировки %s не могут быть использованы."
	
	L["NO_EQUIPMENT_SETS_DEFINED"]  = "ОШИБКА: %s не имеет определенных комплектов экипировки."
	L["LEVEL_REQUIREMENT"]			= "ИНФО: %s должен быть уровнем 10 или выше, чтобы использовать менеджер экипировки."
	L["CURRENT_EQUIPPED_SET"]		= "ИНФО: Текущий экипированный комплект: %s\n"
	end

if LOCALE == "esES" or LOCALE == "esMX" then
	L["INFO_MSG_FRAME"]				= "Mensajes de información"
	L["ERROR_MSG_FRAME"] 			= "Mensajes de error"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "Haz clic izquierdo para mostrar el menú de opciones del juego."
	L["TITLE_HELP_MSG_FRAME"]		= string.format("Menú de ayuda\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("Notificación de error\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("Mensajes\n(%s)", L["ADDON_AND_VERSION"] )	
		
	L["ADDON_LOADED_MSG"]			= string.format("%s cargado.", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "Haz clic izquierdo para mostrar el menú de opciones de %s.", L["ADDON_NAME"] )
	
	L["DESCR_SUBHEADER"] = "%s: Un addon para guardar y restaurar conjuntos de armaduras de descanso"
	L["LINE1"]			= string.format("%s está diseñado para equipar automáticamente un conjunto de armaduras [normalmente]\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("que contiene uno o más objetos de herencia cuando el personaje entra\n")
	L["LINE3"] 			= string.format("en una zona de descanso (por ejemplo, una posada o una ciudad). El conjunto que el personaje llevaba\n")
	L["LINE4"]			= string.format("cuando entró en la zona de descanso será restaurado al salir.\n\n")
	L["LINE6"]			= string.format("Comandos de barra inclinada\n")
	L["LINE7"]			= string.format("/auto - Muestra esta ventana de ayuda.\n")
	L["LINE8"] 			= string.format("/auto help - También muestra esta ventana de ayuda.\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - Habilita o deshabilita la depuración.\n")
	
	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip se utiliza para equipar automáticamente y de manera transparente\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("un conjunto de armaduras específico al entrar en una zona de descanso. Normalmente\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("esto significa un conjunto de armaduras que contiene uno o más objetos de herencia.\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("NOTA: Si creas un nuevo conjunto, tendrás que cerrar sesión o\n")
	L["OPTIONS_TEXT_LINE5"] = string.format("recargar (/reload) para que el icono del conjunto sea visible para %s.\n", ADDON_NAME )
	
	L["LOGIN_MESSAGE"] 				= "[%s] Al iniciar sesión, %s fue equipado con %s (Id %d)."
	L["DEBUGGING_ENABLED"]  		= "[%s] Depuración habilitada."
	L["DEBUGGING_DISABLED"] 		= "[%s] Depuración deshabilitada."
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s cambió al conjunto %s (Id %d)."
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] El jugador no tiene un conjunto definido equipado."
	L["LEFT_REST_AREA"]				= "%s salió de la zona de descanso. Equipado el conjunto %s."
	L["ENTERED_REST_AREA"] 			= "%s entró en la zona de descanso. Equipado el conjunto %s."
	
	L["FAILED_TO_EQUIP_SET"] 		= "ERROR: Falló el equipamiento del conjunto %s."
	L["SET_DOES_NOT_EXIST"]			= "ERROR: El conjunto especificado (%s) no existe."
	L["EQUIPSET_MISSING_ITEMS"] 	= "ERROR: Al conjunto %s le falta uno o más elementos.\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "ERROR: El conjunto %s no se puede usar.\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "ERROR: Los conjuntos de equipamiento de %s no se pueden usar."
	
	L["NO_EQUIPMENT_SETS_DEFINED"]  = "ERROR: %s no tiene conjuntos de equipamiento definidos."
	L["LEVEL_REQUIREMENT"]			= "INFO: %s debe ser de nivel 10 o superior para usar el gestor de equipamiento."
	L["CURRENT_EQUIPPED_SET"]		= "INFO: Conjunto equipado actualmente: %s\n"
	
end

if LOCALE == "zhTW" then
	L["INFO_MSG_FRAME"]				= "資訊訊息"
	L["ERROR_MSG_FRAME"] 			= "錯誤訊息"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "左鍵點擊顯示遊戲內的選項選單。"
	L["TITLE_HELP_MSG_FRAME"]		= string.format("幫助選單\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("錯誤通知\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("訊息\n(%s)", L["ADDON_AND_VERSION"] )	
		
	L["ADDON_LOADED_MSG"]			= string.format("%s 已加載。", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "左鍵點擊以顯示 %s 選項選單。", L["ADDON_NAME"] )
	
	L["DESCR_SUBHEADER"] = "%s: 一個用於保存和恢復休息時穿戴的裝備模組"
	L["LINE1"]			= string.format("%s 旨在自動裝備一套包含傳家寶的裝備套裝，當角色進入\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("休息區（例如旅店或城市）時，會自動裝備。\n")
	L["LINE3"] 			= string.format("角色進入休息區時穿戴的套裝將在離開時恢復。\n\n")
	L["LINE6"]			= string.format("斜線命令\n")
	L["LINE7"]			= string.format("/auto - 顯示此幫助介面。\n")
	L["LINE8"] 			= string.format("/auto help - 也顯示此幫助介面。\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - 啟用或停用除錯跟蹤。\n")
	
	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip 用於自動並透明地裝備\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("一套特定的裝備套裝，當進入休息區時。\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("通常是包含傳家寶的裝備套裝。\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("注意：如果創建了新套裝，您需要重新登入或\n")
	L["OPTIONS_TEXT_LINE5"] = string.format("重載（/reload），以便套裝圖示能在 %s 上可見。\n", ADDON_NAME )
	
	L["LOGIN_MESSAGE"] 				= "[%s] 登入時 %s 穿戴了 %s（ID %d）。"
	L["DEBUGGING_ENABLED"]  		= "[%s] 已啟用除錯模式。"
	L["DEBUGGING_DISABLED"] 		= "[%s] 已停用除錯模式。"
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s 已切換至 %s 套裝（ID %d）。"
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] 玩家未裝備已定義的套裝。"
	L["LEFT_REST_AREA"]				= "%s 已離開休息區。已裝備 %s 套裝。"
	L["ENTERED_REST_AREA"] 			= "%s 進入休息區。已裝備 %s 套裝。"
	
	L["FAILED_TO_EQUIP_SET"] 		= "錯誤：無法裝備 %s 套裝。"
	L["SET_DOES_NOT_EXIST"]			= "錯誤：指定的套裝（%s）不存在。"
	L["EQUIPSET_MISSING_ITEMS"] 	= "錯誤：%s 套裝缺少一個或多個物品。\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "錯誤：%s 套裝不可用。\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "錯誤：%s 的裝備套裝無法使用。"
	
	L["NO_EQUIPMENT_SETS_DEFINED"]  = "錯誤：%s 未定義任何裝備套裝。"
	L["LEVEL_REQUIREMENT"]			= "信息：%s 必須達到10級或以上才能使用裝備管理器。"
	L["CURRENT_EQUIPPED_SET"]		= "信息：當前裝備套裝：%s\n"
end

if LOCALE == "zhCN" then
	L["INFO_MSG_FRAME"]				= "信息消息"
	L["ERROR_MSG_FRAME"] 			= "错误消息"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "左键单击以显示游戏内选项菜单。"
	L["TITLE_HELP_MSG_FRAME"]		= string.format("帮助菜单\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("错误通知\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("消息\n(%s)", L["ADDON_AND_VERSION"] )	
		
	L["ADDON_LOADED_MSG"]			= string.format("%s 已加载。", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "左键单击以显示 %s 选项菜单。", L["ADDON_NAME"] )
	
	L["DESCR_SUBHEADER"] = "%s: 一个用于保存和恢复休息时装备的插件"
	L["LINE1"]			= string.format("%s 旨在自动装备一套包含传家宝的装备，当角色进入\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("休息区（例如旅店或城市）时，自动装备。\n")
	L["LINE3"] 			= string.format("角色进入休息区时穿戴的装备将在离开时恢复。\n\n")
	L["LINE6"]			= string.format("斜杠命令\n")
	L["LINE7"]			= string.format("/auto - 显示此帮助界面。\n")
	L["LINE8"] 			= string.format("/auto help - 也显示此帮助界面。\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - 启用或禁用调试跟踪。\n")
	
	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip 用于在进入休息区时自动且透明地装备\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("特定的装备套装。通常情况下，这意味着装备包含传家宝的套装。\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("包含传家宝的装备。\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("注意：如果创建了新的套装，您需要重新登录或\n")
	L["OPTIONS_TEXT_LINE5"] = string.format("重载（/reload），以使套装图标能显示在 %s 上。\n", ADDON_NAME )
	
	L["LOGIN_MESSAGE"] 				= "[%s] 登录时 %s 装备了 %s（ID %d）。"
	L["DEBUGGING_ENABLED"]  		= "[%s] 已启用调试模式。"
	L["DEBUGGING_DISABLED"] 		= "[%s] 已禁用调试模式。"
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s 切换到了 %s 套装（ID %d）。"
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] 玩家未装备已定义的套装。"
	L["LEFT_REST_AREA"]				= "%s 离开了休息区。已装备 %s 套装。"
	L["ENTERED_REST_AREA"] 			= "%s 进入了休息区。已装备 %s 套装。"
	
	L["FAILED_TO_EQUIP_SET"] 		= "错误：无法装备 %s 套装。"
	L["SET_DOES_NOT_EXIST"]			= "错误：指定的套装（%s）不存在。"
	L["EQUIPSET_MISSING_ITEMS"] 	= "错误：%s 套装缺少一个或多个物品。\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "错误：%s 套装不可用。\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "错误：%s 的装备套装无法使用。"
	
	L["NO_EQUIPMENT_SETS_DEFINED"]  = "错误：%s 未定义任何装备套装。"
	L["LEVEL_REQUIREMENT"]			= "信息：%s 必须达到10级或以上才能使用装备管理器。"
	L["CURRENT_EQUIPPED_SET"]		= "信息：当前装备套装：%s\n"
	
end

if LOCALE == "noNO" then
	L["INFO_MSG_FRAME"]				= "Informasjonsmeldinger"
	L["ERROR_MSG_FRAME"] 			= "Feilmeldinger"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "Venstreklikk for å vise innstillingsmenyen i spillet."
	L["TITLE_HELP_MSG_FRAME"]		= string.format("Hjelpemeny\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("Feilmelding\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("Meldinger\n(%s)", L["ADDON_AND_VERSION"] )	
		
	L["ADDON_LOADED_MSG"]			= string.format("%s lastet inn.", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "Venstreklikk for å vise %s-innstillingsmenyen.", L["ADDON_NAME"] )
	
	L["DESCR_SUBHEADER"] = "%s: En tillegg for å lagre og gjenopprette hvilende utstyrssett"
	L["LINE1"]			= string.format("%s er ment for å automatisk utstyre et sett [vanligvis]\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("som inneholder ett eller flere arvestykker når karakteren går inn i\n")
	L["LINE3"] 			= string.format("et hvilested (f.eks. et vertshus eller en by). Settet som karakteren hadde på\n")
	L["LINE4"]			= string.format("da de gikk inn i hvilestedet, vil bli gjenopprettet når de forlater det.\n\n")
	L["LINE6"]			= string.format("Skråstrek-kommandoer\n")
	L["LINE7"]			= string.format("/auto - Viser denne hjelpevinduet.\n")
	L["LINE8"] 			= string.format("/auto help - Viser også denne hjelpevinduet.\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - Aktiverer og deaktiverer feilsøkingssporing.\n")
	
	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip brukes for automatisk og transparent utstyring\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("av et bestemt utstyrssett når man går inn i et hvilested. Vanligvis\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("betyr dette et sett som inneholder ett eller flere arvestykker.\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("MERK: Hvis du lager et nytt sett, må du logge ut eller\n")
	L["OPTIONS_TEXT_LINE5"] = string.format("laste inn på nytt (/reload) for at settikonet skal bli synlig for %s.\n", ADDON_NAME )
	
	L["LOGIN_MESSAGE"] 				= "[%s] Ved innlogging var %s utstyrt med %s (Id %d)."
	L["DEBUGGING_ENABLED"]  		= "[%s] Feilsøking er nå aktivert."
	L["DEBUGGING_DISABLED"] 		= "[%s] Feilsøking er nå deaktivert."
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s byttet til %s-settet (Id %d)."
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] Spilleren har ikke utstyrt et definert sett."
	L["LEFT_REST_AREA"]				= "%s forlot hvilestedet. Utstyrt %s-utstyrsettet."
	L["ENTERED_REST_AREA"] 			= "%s kom inn i hvilestedet. Utstyrt %s-utstyrsettet."
	
	L["FAILED_TO_EQUIP_SET"] 		= "FEIL: Klarte ikke å utstyre %s-settet."
	L["SET_DOES_NOT_EXIST"]			= "FEIL: Det angitte settet (%s) eksisterer ikke."
	L["EQUIPSET_MISSING_ITEMS"] 	= "FEIL: %s-settet mangler ett eller flere gjenstander.\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "FEIL: %s-settet er ikke brukbart.\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "FEIL: %s sine utstyrssett er ikke brukbare."
	
	L["NO_EQUIPMENT_SETS_DEFINED"]  = "FEIL: %s har ingen definerte utstyrssett."
	L["LEVEL_REQUIREMENT"]			= "INFO: %s må være nivå 10 eller høyere for å bruke utstyrshåndtereren."
	L["CURRENT_EQUIPPED_SET"]		= "INFO: Nåværende utstyrt sett: %s\n"
	
end
if LOCALE == "klKL" then
	L["INFO_MSG_FRAME"]				= "De' QIn"
	L["ERROR_MSG_FRAME"] 			= "Qagh QIn"
	L["LEFTCLICK_OPTIONS_MENU"] 	= "DaHjaj DuHmey SeHlaw 'angmeH nIH ghop qeng."
	L["TITLE_HELP_MSG_FRAME"]		= string.format("QaH pat\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_ERROR_MSG_FRAME"]		= string.format("Qagh QIn pat\n(%s)", L["ADDON_AND_VERSION"] )
	L["TITLE_INFO_MSG_FRAME"]		= string.format("QInmey\n(%s)", L["ADDON_AND_VERSION"] )	
		
	L["ADDON_LOADED_MSG"]			= string.format("%s lu' chu'lu'.", L["ADDON_AND_VERSION"])
	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "DaHjaj DuHmey SeHlaw 'angmeH nIH ghop qeng, %s.", L["ADDON_NAME"] )
	
	L["DESCR_SUBHEADER"] = "%s: taS Daj 'e' laD 'ej qa'meH qetlh"
	L["LINE1"]			= string.format("%s Daj 'ej chenmoHmeH Qutluch [motlh]\n", L["ADDON_NAME"])
	L["LINE2"] 			= string.format("ghorgh loD qaStaHvIS qa' ghom.\n")
	L["LINE3"] 			= string.format("tlhoywIjDaq ghojHa'ghach\n")
	L["LINE4"]			= string.format("qatlh ghoSmeH yuvpu'.\n\n")
	L["LINE6"]			= string.format("yItlh tlhob\n")
	L["LINE7"]			= string.format("/auto - QaH pat 'ang.\n")
	L["LINE8"] 			= string.format("/auto help - QaH pat 'ang je.\n")
	L["LINE9"] 			= string.format("/auto debug enable|disable - HIp 'ej mIwHommey qel.\n")
	
	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip lo'lu'pu' 'ej qaStaHvIS qutluch\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("motlh chenmoH qaStaHvIS ghaytan.\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("Hegh Hegh yIqoychu'.\n\n")
	L["OPTIONS_TEXT_LINE4"] = string.format("ghu'vam chu': bIghor SoQ lo'ghach qeq cha'logh\n")
	L["OPTIONS_TEXT_LINE5"] = string.format("nIH ghop qeng pagh 'ang qaStaHvIS %s.\n", ADDON_NAME )
	
	L["LOGIN_MESSAGE"] 				= "[%s] tlhIngan ghap chu'lu'. %s QutluchDaq %s (Id %d)."
	L["DEBUGGING_ENABLED"]  		= "[%s] taS lutlIjDaq 'e' qa'chu'."
	L["DEBUGGING_DISABLED"] 		= "[%s] taS lutlIjDaq 'e' qa'be'."
	L["PLAYER_SWITCHED_SETS"] 		= "[%s] %s tlhopDaq je'lu'. %s."
	L["PLAYER_NOT_EQUIPPED"]		= "[%s] wa' vIje'be'lu'."
	L["LEFT_REST_AREA"]				= "%s chob qaStaHvIS tlhaplu'. QutluchDaq %s."
	L["ENTERED_REST_AREA"] 			= "%s chob 'el. QutluchDaq %s."
	
	L["FAILED_TO_EQUIP_SET"] 		= "Qagh: Qutluch %s laDlaHbe'."
	L["SET_DOES_NOT_EXIST"]			= "Qagh: Qutluch 'oHta'be' (%s)."
	L["EQUIPSET_MISSING_ITEMS"] 	= "Qagh: Qutluch %s pong yIQaw'pu'.\n"
	L["EQUIPMENT_SETS_UNUSABLE"] 	= "Qagh: Qutluch %s laDlaHbe'laH.\n"
	L["CANNOT_USE_EQUIPMENT_SETS"] 	= "Qagh: %s Qutluch laDlaHbe'."
	
	L["NO_EQUIPMENT_SETS_DEFINED"]  = "Qagh: %s Qutluch laDbe'lu'pu'."
	L["LEVEL_REQUIREMENT"]			= "De': %s ghob ghaytan yItlh ghIq."
	L["CURRENT_EQUIPPED_SET"]		= "De': Qutluch Dajbogh: %s\n"	
end