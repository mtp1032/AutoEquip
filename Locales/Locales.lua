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
	print( "Expansion Level:", expansionLevel ) -- debug print statement

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

local version = string.format("%s.%s.%s", MAJOR, MINOR, PATCH )
local expansionName = getExpansionName()

local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

AutoEquip.Locales = L

-- Common strings that don't change across locales
L["ADDON_NAME"]			= ADDON_NAME
L["VERSION"]			= version
L["EXPANSION_NAME"]		= expansionName 

local LOCALE = GetLocale()     

if LOCALE == "enUS" then

	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["USER_INFO_FRAME"]	= "User Information Messages"
	L["USER_ERROR_FRAME"] 	= "User Error Messages"
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "Left Click to display In-Game Options Menu."
	L["HELP_FRAME_TITLE"]	= string.format("Help: %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]	= string.format("%s Loaded.", L["ADDON_AND_VERSION"])

	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format( "Left click to display the %s Options Menu.", L["ADDON_NAME"] )

	L["DESCR_SUBHEADER"] = "Auto Save & Restore Your Equipment Sets"

	L["LINE1"]			= string.format("%s is intended to automatically equip an armor set", L["ADDON_NAME"])
	L["LINE2"] 			= "[usually] containing one or more Heirloom items whenever the character enters"
	L["LINE3"] 			= "a rest area (e.g, an Inn or a city). The set the character was wearing"
	L["LINE4"]			= "when entering the rest area will be restored when the character leaves."

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip is used to automatically and transparently equip\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("a specific armor set when entering a rest area. Usually\n" )
	L["OPTIONS_TEXT_LINE3"]	= string.format("this means an armor set containing one or more Heirloom items.\n")
	
	L["EQUIPMENT_SET_NOT_FOUND"]	= "ERROR: Equipment set not found. Check spelling.\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "ERROR: The %s set is missing one or more items.\n"
	L["NO_SETS_EXIST"]				= "INFO: %s has not yet defined any equipment sets."	-- @@ Replace with L["EQUIPMENT_SETS_NOT_DEFINED"]
	L["LEVEL_REQUIREMENT"]			= "INFO: %s must be level 10 or above to use the equipment manager."
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format( "ERROR: No usable equipment sets are available. This error often arises\n because an equipment set is missing one or more items.")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "INFO: %s has not yet defined any equipment sets." -- @@ Retranslate this entry
	L["LEFT_REST_AREA"]				= "INFO: LEFT Rest area. Equipped %s equipment set. "
	L["ENTERED_REST_AREA"] 			= "INFO: Entered Rest Area. Equipped %s equipment set. "
	L["FAILED_TO_EQUIP_SET"] 		= "ERROR: %s set was not equipped. "
	L["CURRENT_EQUIPPED_SET"]		= "Currently Equipped: %s\n"
end

if LOCALE == "frFR" then
	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["USER_INFO_FRAME"]	= "Messages d'info"
	L["USER_ERROR_FRAME"] 	= "Messages d'erreur utilisateur"
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "Clic gauche pour afficher le menu des options en jeu."
	L["HELP_FRAME_TITLE"]	= string.format("Aide : %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]	= string.format("%s chargé.", L["ADDON_AND_VERSION"])

	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format("Clic gauche pour afficher le menu des options %s.", L["ADDON_NAME"])

	L["DESCR_SUBHEADER"] = "Sauvegarde & restauration automatique de vos ensembles d'équipement"

	L["LINE1"]			= string.format("%s est conçu pour équiper automatiquement un ensemble d'armure", L["ADDON_NAME"])
	L["LINE2"] 			= "[généralement] contenant un ou plusieurs objets héritages lorsque le personnage entre"
	L["LINE3"] 			= "dans une zone de repos (par ex., une auberge ou une ville). L'ensemble que le personnage portait"
	L["LINE4"]			= "en entrant dans la zone de repos sera restauré lorsque le personnage la quittera."

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip est utilisé pour équiper automatiquement et de manière transparente\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("un ensemble d'armure spécifique lors de l'entrée dans une zone de repos. Généralement\n")
	L["OPTIONS_TEXT_LINE3"]	= string.format("cela signifie un ensemble d'armure contenant un ou plusieurs objets héritages.\n")

	L["EQUIPMENT_SET_NOT_FOUND"]	= "ERREUR : Ensemble d'équipement introuvable. Vérifiez l'orthographe.\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "ERREUR : L'ensemble %s est manquant un ou plusieurs objets.\n"
	L["NO_SETS_EXIST"]				= "INFO : %s n'a pas d'ensembles d'équipement."
	L["LEVEL_REQUIREMENT"]			= "INFO : %s doit être au niveau 10 ou plus pour utiliser le gestionnaire d'équipement."
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format("ERREUR : Aucun ensemble d'équipement utilisable disponible. Cette erreur survient souvent\n parce qu'un ensemble d'équipement est manquant un ou plusieurs objets.")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "ERREUR : %s n'a pas encore défini d'ensemble d'équipement."
	L["LEFT_REST_AREA"]				= "INFO : Zone de repos quittée. Ensemble d'équipement %s équipé."
	L["ENTERED_REST_AREA"] 			= "INFO : Zone de repos entrée. Ensemble d'équipement %s équipé."
	L["FAILED_TO_EQUIP_SET"] 		= "ERREUR : L'ensemble %s n'a pas été équipé."
	L["CURRENT_EQUIPPED_SET"]		= "Actuellement équipé : %s\n"
end

if LOCALE == "deDE" then

	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["USER_INFO_FRAME"]	= "Informationsmeldungen"
	L["USER_ERROR_FRAME"] 	= "Benutzer-Fehlermeldungen"
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "Linksklick, um das In-Game-Optionsmenü anzuzeigen."
	L["HELP_FRAME_TITLE"]	= string.format("Hilfe: %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]	= string.format("%s geladen.", L["ADDON_AND_VERSION"])

	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format("Linksklick, um das %s-Optionsmenü anzuzeigen.", L["ADDON_NAME"])

	L["DESCR_SUBHEADER"] = "Automatisches Speichern und Wiederherstellen Ihrer Ausrüstungssets"

	L["LINE1"]			= string.format("%s ist dazu gedacht, automatisch ein Rüstungsset anzulegen", L["ADDON_NAME"])
	L["LINE2"] 			= "[normalerweise] mit einem oder mehreren Erbstückgegenständen, wenn der Charakter eintritt"
	L["LINE3"] 			= "in eine Ruhezone (z.B. ein Gasthaus oder eine Stadt). Das Set, das der Charakter trug,"
	L["LINE4"]			= "wird beim Verlassen der Ruhezone wiederhergestellt."

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip wird verwendet, um automatisch und transparent ein\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("bestimmtes Rüstungsset beim Betreten einer Ruhezone anzulegen. Normalerweise\n")
	L["OPTIONS_TEXT_LINE3"]	= string.format("bedeutet dies ein Rüstungsset mit einem oder mehreren Erbstückgegenständen.\n")

	L["EQUIPMENT_SET_NOT_FOUND"]	= "FEHLER: Ausrüstungsset nicht gefunden. Überprüfen Sie die Rechtschreibung.\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "FEHLER: Das Set %s fehlt ein oder mehrere Gegenstände.\n"
	L["NO_SETS_EXIST"]				= "INFO: %s hat keine Ausrüstungssets."
	L["LEVEL_REQUIREMENT"]			= "INFO: %s muss mindestens Stufe 10 sein, um den Ausrüstungsmanager zu verwenden."
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format("FEHLER: Keine verfügbaren Ausrüstungssets. Dieser Fehler tritt häufig auf,\n weil einem Ausrüstungsset ein oder mehrere Gegenstände fehlen.")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "FEHLER: %s hat noch keine Ausrüstungssets definiert."
	L["LEFT_REST_AREA"]				= "INFO: Ruhezone verlassen. Ausrüstungsset %s angelegt."
	L["ENTERED_REST_AREA"] 			= "INFO: Ruhezone betreten. Ausrüstungsset %s angelegt."
	L["FAILED_TO_EQUIP_SET"] 		= "FEHLER: Das Set %s wurde nicht angelegt."
	L["CURRENT_EQUIPPED_SET"]		= "Aktuell ausgerüstet: %s\n"

end

if LOCALE == "itIT" then
	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["USER_INFO_FRAME"]	= "Messaggi Informativi"
	L["USER_ERROR_FRAME"] 	= "Messaggi di Errore Utente"
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "Clic sinistro per mostrare il Menu Opzioni in gioco."
	L["HELP_FRAME_TITLE"]	= string.format("Aiuto: %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]	= string.format("%s Caricato.", L["ADDON_AND_VERSION"])

	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format("Clic sinistro per mostrare il Menu Opzioni %s.", L["ADDON_NAME"])

	L["DESCR_SUBHEADER"] = "Salvataggio & Ripristino automatico dei set di equipaggiamento"

	L["LINE1"]			= string.format("%s è destinato a equipaggiare automaticamente un set di armature", L["ADDON_NAME"])
	L["LINE2"] 			= "[di solito] contenente uno o più oggetti cimelio quando il personaggio entra"
	L["LINE3"] 			= "in un'area di riposo (ad es. una locanda o una città). Il set che il personaggio indossava"
	L["LINE4"]			= "quando entra nell'area di riposo verrà ripristinato quando il personaggio la lascerà."

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip viene utilizzato per equipaggiare automaticamente e in modo trasparente\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("un set di armature specifico quando si entra in un'area di riposo. Di solito\n")
	L["OPTIONS_TEXT_LINE3"]	= string.format("questo significa un set di armature contenente uno o più oggetti cimelio.\n")

	L["EQUIPMENT_SET_NOT_FOUND"]	= "ERRORE: Set di equipaggiamento non trovato. Controlla l'ortografia.\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "ERRORE: Il set %s manca di uno o più oggetti.\n"
	L["NO_SETS_EXIST"]				= "INFO: %s non ha set di equipaggiamento."
	L["LEVEL_REQUIREMENT"]			= "INFO: %s deve essere di livello 10 o superiore per utilizzare il gestore dell'equipaggiamento."
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format("ERRORE: Nessun set di equipaggiamento utilizzabile disponibile. Questo errore si verifica spesso\n perché un set di equipaggiamento manca di uno o più oggetti.")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "ERRORE: %s non ha ancora definito alcun set di equipaggiamento."
	L["LEFT_REST_AREA"]				= "INFO: Uscito dall'area di riposo. Set di equipaggiamento %s equipaggiato."
	L["ENTERED_REST_AREA"] 			= "INFO: Entrato nell'area di riposo. Set di equipaggiamento %s equipaggiato."
	L["FAILED_TO_EQUIP_SET"] 		= "ERRORE: Il set %s non è stato equipaggiato."
	L["CURRENT_EQUIPPED_SET"]		= "Attualmente equipaggiato: %s\n"
end

if LOCALE == "koKR" then

	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["USER_INFO_FRAME"]	= "유저 정보 메시지"
	L["USER_ERROR_FRAME"] 	= "유저 오류 메시지"
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "게임 옵션 메뉴를 표시하려면 왼쪽 클릭하세요."
	L["HELP_FRAME_TITLE"]	= string.format("도움말: %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]	= string.format("%s 로드됨.", L["ADDON_AND_VERSION"])

	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format("%s 옵션 메뉴를 표시하려면 왼쪽 클릭하세요.", L["ADDON_NAME"])

	L["DESCR_SUBHEADER"] = "장비 세트를 자동으로 저장하고 복원"

	L["LINE1"]			= string.format("%s는 캐릭터가 진입할 때 장비 세트를 자동으로 장착하도록 설계되었습니다", L["ADDON_NAME"])
	L["LINE2"] 			= "[대개] 상속 아이템이 포함된 장비 세트를 진입할 때 장착"
	L["LINE3"] 			= "휴식 구역(예: 여관 또는 도시)에서. 캐릭터가 착용하고 있었던 장비 세트는"
	L["LINE4"]			= "휴식 구역을 떠날 때 복원됩니다."

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip은 휴식 구역에 진입할 때 자동으로 특정 장비 세트를 장착하는 데 사용됩니다.\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("이 세트는 대개 상속 아이템이 포함된 장비 세트입니다.\n")
	L["OPTIONS_TEXT_LINE3"]	= string.format("이 장비 세트는 자동으로 복원됩니다.\n")

	L["EQUIPMENT_SET_NOT_FOUND"]	= "오류: 장비 세트를 찾을 수 없습니다. 철자를 확인하세요.\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "오류: %s 세트에서 하나 이상의 항목이 누락되었습니다.\n"
	L["NO_SETS_EXIST"]				= "정보: %s에는 장비 세트가 없습니다."
	L["LEVEL_REQUIREMENT"]			= "정보: %s는 장비 관리자를 사용하려면 10레벨 이상이어야 합니다."
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format("오류: 사용할 수 있는 장비 세트가 없습니다. 이 오류는 종종 장비 세트에 하나 이상의 항목이 누락되어 발생합니다.\n")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "오류: %s는 아직 장비 세트를 정의하지 않았습니다."
	L["LEFT_REST_AREA"]				= "정보: 휴식 구역을 떠났습니다. %s 장비 세트가 장착되었습니다."
	L["ENTERED_REST_AREA"] 			= "정보: 휴식 구역에 들어갔습니다. %s 장비 세트가 장착되었습니다."
	L["FAILED_TO_EQUIP_SET"] 		= "오류: %s 세트가 장착되지 않았습니다."
	L["CURRENT_EQUIPPED_SET"]		= "현재 장착 중: %s\n"
end

if LOCALE == "ruRU" then

	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["USER_INFO_FRAME"]	= "Информационные сообщения"
	L["USER_ERROR_FRAME"] 	= "Сообщения об ошибках"
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "Щелкните левой кнопкой мыши, чтобы открыть меню настроек."
	L["HELP_FRAME_TITLE"]	= string.format("Справка: %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]	= string.format("%s загружен.", L["ADDON_AND_VERSION"])

	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format("Щелкните левой кнопкой мыши, чтобы открыть меню настроек %s.", L["ADDON_NAME"])

	L["DESCR_SUBHEADER"] = "Автосохранение и восстановление ваших наборов экипировки"

	L["LINE1"]			= string.format("%s предназначен для автоматического надевания набора брони", L["ADDON_NAME"])
	L["LINE2"] 			= "[обычно] содержащего один или несколько предметов наследия, когда персонаж входит"
	L["LINE3"] 			= "в место отдыха (например, таверна или город). Набор, который персонаж носил"
	L["LINE4"]			= "при входе в место отдыха, будет восстановлен при выходе из него."

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip используется для автоматического и прозрачного надевания\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("определённого набора брони при входе в место отдыха. Обычно\n")
	L["OPTIONS_TEXT_LINE3"]	= string.format("это означает набор брони, содержащий один или несколько предметов наследия.\n")

	L["EQUIPMENT_SET_NOT_FOUND"]	= "ОШИБКА: Набор экипировки не найден. Проверьте правильность написания.\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "ОШИБКА: В наборе %s отсутствует один или несколько предметов.\n"
	L["NO_SETS_EXIST"]				= "ИНФО: У %s нет наборов экипировки."
	L["LEVEL_REQUIREMENT"]			= "ИНФО: %s должен быть 10-го уровня или выше для использования менеджера экипировки."
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format("ОШИБКА: Нет доступных наборов экипировки. Эта ошибка часто возникает\n из-за отсутствия одного или нескольких предметов в наборе экипировки.")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "ОШИБКА: %s ещё не создал наборы экипировки."
	L["LEFT_REST_AREA"]				= "ИНФО: Место отдыха покинуто. Набор экипировки %s надет."
	L["ENTERED_REST_AREA"] 			= "ИНФО: Вошёл в место отдыха. Надет набор экипировки %s."
	L["FAILED_TO_EQUIP_SET"] 		= "ОШИБКА: Набор %s не был надет."
	L["CURRENT_EQUIPPED_SET"]		= "Текущая экипировка: %s\n"
end

if LOCALE == "esES" or LOCALE == "esMX" then

	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["USER_INFO_FRAME"]	= "Mensajes de Información"
	L["USER_ERROR_FRAME"] 	= "Mensajes de Error"
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "Clic izquierdo para mostrar el menú de opciones en el juego."
	L["HELP_FRAME_TITLE"]	= string.format("Ayuda: %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]	= string.format("%s Cargado.", L["ADDON_AND_VERSION"])

	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format("Clic izquierdo para mostrar el menú de opciones de %s.", L["ADDON_NAME"])

	L["DESCR_SUBHEADER"] = "Guardar y Restaurar Automáticamente tus Conjuntos de Equipamiento"

	L["LINE1"]			= string.format("%s está diseñado para equipar automáticamente un conjunto de armadura", L["ADDON_NAME"])
	L["LINE2"] 			= "[normalmente] que contiene uno o más objetos de herencia cuando el personaje entra"
	L["LINE3"] 			= "en un área de descanso (por ejemplo, una posada o una ciudad). El conjunto que el personaje llevaba puesto"
	L["LINE4"]			= "al entrar en el área de descanso se restaurará cuando el personaje la abandone."

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip se utiliza para equipar automáticamente y de forma transparente\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("un conjunto de armadura específico al entrar en un área de descanso. Normalmente\n")
	L["OPTIONS_TEXT_LINE3"]	= string.format("esto significa un conjunto de armadura que contiene uno o más objetos de herencia.\n")

	L["EQUIPMENT_SET_NOT_FOUND"]	= "ERROR: Conjunto de equipamiento no encontrado. Verifique la ortografía.\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "ERROR: El conjunto %s carece de uno o más objetos.\n"
	L["NO_SETS_EXIST"]				= "INFO: %s no tiene conjuntos de equipamiento."
	L["LEVEL_REQUIREMENT"]			= "INFO: %s debe ser nivel 10 o superior para utilizar el gestor de equipamiento."
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format("ERROR: No hay conjuntos de equipamiento disponibles. Este error a menudo se produce\n porque falta uno o más objetos en un conjunto de equipamiento.")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "ERROR: %s aún no ha definido ningún conjunto de equipamiento."
	L["LEFT_REST_AREA"]				= "INFO: Salió del área de descanso. Conjunto de equipamiento %s equipado."
	L["ENTERED_REST_AREA"] 			= "INFO: Entró en el área de descanso. Conjunto de equipamiento %s equipado."
	L["FAILED_TO_EQUIP_SET"] 		= "ERROR: No se equipó el conjunto %s."
	L["CURRENT_EQUIPPED_SET"]		= "Equipado actualmente: %s\n"
end

if LOCALE == "zhTW" then

	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["USER_INFO_FRAME"]	= "用戶信息消息"
	L["USER_ERROR_FRAME"] 	= "用戶錯誤消息"
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "左鍵單擊以顯示遊戲內選項菜單。"
	L["HELP_FRAME_TITLE"]	= string.format("幫助：%s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]	= string.format("%s 已加載。", L["ADDON_AND_VERSION"])

	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format("左鍵單擊以顯示%s選項菜單。", L["ADDON_NAME"])

	L["DESCR_SUBHEADER"] = "自動保存和恢復您的裝備設置"

	L["LINE1"]			= string.format("%s旨在自動裝備一套裝甲", L["ADDON_NAME"])
	L["LINE2"] 			= "[通常]包含一個或多個繼承物品，當角色進入"
	L["LINE3"] 			= "一個休息區（例如，旅館或城市）。角色進入休息區時穿著的裝備"
	L["LINE4"]			= "將在角色離開時恢復。"

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip 用於在進入休息區時自動透明地裝備\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("特定的裝甲套裝。通常這意味著一套包含一個或多個繼承物品的裝甲。\n")

	L["EQUIPMENT_SET_NOT_FOUND"]	= "錯誤：未找到裝備設置。請檢查拼寫。\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "錯誤：%s 套裝缺少一個或多個物品。\n"
	L["NO_SETS_EXIST"]				= "信息：%s 沒有裝備設置。"
	L["LEVEL_REQUIREMENT"]			= "信息：%s 必須達到 10 級或以上才能使用裝備管理器。"
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format("錯誤：無可用的裝備設置。這個錯誤通常是由於裝備設置中缺少一個或多個物品而引起的。\n")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "錯誤：%s 尚未定義任何裝備設置。"
	L["LEFT_REST_AREA"]				= "信息：離開休息區。裝備了 %s 裝備設置。"
	L["ENTERED_REST_AREA"] 			= "信息：進入休息區。裝備了 %s 裝備設置。"
	L["FAILED_TO_EQUIP_SET"] 		= "錯誤：%s 套裝未裝備。"
	L["CURRENT_EQUIPPED_SET"]		= "當前裝備：%s\n"
end

if LOCALE == "zhCN" then

	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["USER_INFO_FRAME"]	= "用户信息消息"
	L["USER_ERROR_FRAME"] 	= "用户错误消息"
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "左键单击以显示游戏内选项菜单。"
	L["HELP_FRAME_TITLE"]	= string.format("帮助：%s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]	= string.format("%s 已加载。", L["ADDON_AND_VERSION"])

	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format("左键单击以显示%s选项菜单。", L["ADDON_NAME"])

	L["DESCR_SUBHEADER"] = "自动保存和恢复您的装备设置"

	L["LINE1"]			= string.format("%s旨在自动装备一套盔甲", L["ADDON_NAME"])
	L["LINE2"] 			= "[通常]包含一个或多个继承物品，当角色进入"
	L["LINE3"] 			= "一个休息区（例如，旅馆或城市）。角色进入休息区时穿着的装备"
	L["LINE4"]			= "将在角色离开时恢复。"

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip 用于在进入休息区时自动透明地装备\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("特定的盔甲套装。通常这意味着一套包含一个或多个继承物品的盔甲。\n")

	L["EQUIPMENT_SET_NOT_FOUND"]	= "错误：未找到装备设置。请检查拼写。\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "错误：%s 套装缺少一个或多个物品。\n"
	L["NO_SETS_EXIST"]				= "信息：%s 没有装备设置。"
	L["LEVEL_REQUIREMENT"]			= "信息：%s 必须达到 10 级或以上才能使用装备管理器。"
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format("错误：无可用的装备设置。这个错误通常是由于装备设置中缺少一个或多个物品而引起的。\n")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "错误：%s 尚未定义任何装备设置。"
	L["LEFT_REST_AREA"]				= "信息：离开休息区。装备了 %s 装备设置。"
	L["ENTERED_REST_AREA"] 			= "信息：进入休息区。装备了 %s 装备设置。"
	L["FAILED_TO_EQUIP_SET"] 		= "错误：%s 套装未装备。"
	L["CURRENT_EQUIPPED_SET"]		= "当前装备：%s\n"
end

if LOCALE == "svSE" then

	L["ADDON_AND_VERSION"] 	= string.format("%s v%s (%s)", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )

	L["USER_INFO_FRAME"]	= "Användarinformationsmeddelanden"
	L["USER_ERROR_FRAME"] 	= "Användarfelmeddelanden"
	L["LEFT_CLICK_FOR_OPTIONS_MENU"] 	= "Vänsterklicka för att visa alternativmenyn i spelet."
	L["HELP_FRAME_TITLE"]	= string.format("Hjälp: %s", L["ADDON_AND_VERSION"])
	L["ADDON_LOADED_MSG"]	= string.format("%s laddad.", L["ADDON_AND_VERSION"])

	L["LEFTCLICK_FOR_OPTIONS_MENU"]	= string.format("Vänsterklicka för att visa %s-alternativmenyn.", L["ADDON_NAME"])

	L["DESCR_SUBHEADER"] = "Spara och återställ dina utrustningsset automatiskt"

	L["LINE1"]			= string.format("%s är avsedd att automatiskt utrusta en uppsättning rustning", L["ADDON_NAME"])
	L["LINE2"] 			= "[vanligtvis] innehållande en eller flera arvegodsartiklar när karaktären går in"
	L["LINE3"] 			= "i ett viloområde (t.ex. en värdshus eller stad). Setet karaktären bar"
	L["LINE4"]			= "vid inresan till viloområdet kommer att återställas när karaktären lämnar."

	L["OPTIONS_TEXT_LINE1"] = string.format("AutoEquip används för att automatiskt och transparent utrusta\n")
	L["OPTIONS_TEXT_LINE2"] = string.format("en specifik rustningsuppsättning när du går in i ett viloområde. Vanligtvis\n")
	L["OPTIONS_TEXT_LINE3"]	= string.format("innebär detta en rustningsuppsättning som innehåller en eller flera arvegodsartiklar.\n")

	L["EQUIPMENT_SET_NOT_FOUND"]	= "FEL: Utrustningssetet hittades inte. Kontrollera stavningen.\n"
	L["EQUIPSET_MISSING_ITEMS"] 	= "FEL: Setet %s saknar en eller flera objekt.\n"
	L["NO_SETS_EXIST"]				= "INFO: %s har inga utrustningsset."
	L["LEVEL_REQUIREMENT"]			= "INFO: %s måste vara nivå 10 eller högre för att använda utrustningshanteraren."
	L["EQUIPMENT_SETS_UNAVAILABLE"] = string.format("FEL: Inga användbara utrustningsset är tillgängliga. Detta fel uppstår ofta\n eftersom ett utrustningsset saknar en eller flera objekt.")
	L["EQUIPMENT_SETS_NOT_DEFINED"] = "FEL: %s har ännu inte definierat några utrustningsset."
	L["LEFT_REST_AREA"]				= "INFO: Viloområde lämnat. Utrustningsset %s utrustat."
	L["ENTERED_REST_AREA"] 			= "INFO: Gick in i viloområde. Utrustningsset %s utrustat."
	L["FAILED_TO_EQUIP_SET"] 		= "FEL: Setet %s utrustades inte."
	L["CURRENT_EQUIPPED_SET"]		= "För närvarande utrustad: %s\n"
end
