Contents
DialogueQuestDeveloperManual 2
DialogueQuestfornon-coders 2
InstallationandSetup 2
TheDataDirectory . . . . . . . . . . . . . . . . . . . . . . . . . . 3
Exporting 3
Examples 3
WritingDialogue 3
CreatingCharacters 4
ExportingCharacters 4
SeeAlso 4
CreatingDialogue 4
PlayingDialogue 5
Scenesetup . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 5
Startingthedialogue . . . . . . . . . . . . . . . . . . . . . . . . 5
Stoppingthedialogue . . . . . . . . . . . . . . . . . . . . . . . . 5
Settings 6
SettingsOptions . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
Alsosee. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
ExtendingDialogueQuest 6
Theming 6
SeeAlso . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
CustomStatements 7
CustomLogic 8
TheFlagssystem 9
Alsosee. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 9
DialogueQuestsignals 9
Theerrorsignal. . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
DQSignals . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
Seealso. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 10
1
DialogueQuestDeveloperManual
DialogueQuestfornon-coders
DialogueQuest features a standalone program called Dialogue-
QuestTester that allows running dialogues without a Godot
environment.
InstallationandSetup
TherecommendedwaytoinstallDialogueQuestisvidaGodot’sbuiltin
AssetLibrary.
Howeverifyouwanttogetthelatestfeatures,youshouldinstallvia
therepositoryassuch:
OnLinux/Mac:
1 cd my_godot_project
git clone https://github.com/hohfchns/DialogueQuest
3 mkdir -p addons/
mv ./DialogueQuest/addons/DialogueQuest ./addons
5 rm -rf DialogueQuest
Orinoneline:git clone https://github.com/hohfchns/DialogueQuest
&& mkdir -p addons/ && mv ./DialogueQuest/addons/DialogueQuest
./addons && rm -rf DialogueQuest
OnWindows:
InyourGodotproject:
• Clonetherepository
• Makedirectorycalledaddons
• MovethefolderDialogueQuest\addons\DialogueQuest inside
addons
• Deletetheclonedrepository
OpenyourGodotproject,gotoProject -> Project Settings ->
Plugins andenableDialogueQuest
Reloadtheproject.
2
Notice - During the setup process, Godot will show errors due to the
plugin not yet being enabled. Until the plugin is enabled and the
project is reloaded, you can safely ignore any errors.
The exception to the above are errors that prevent enabling the addon.
TheDataDirectory
Go to Project -> Project Settings -> General and search for
Dialogue Quest,thensetData Directory toafolderwhereyouwill
storeDialogueQuestfiles(characters,dialogues,etc.)
Thisfolderisbydefaultsettores://dialogue_quest/
Thisfolderiswhereyouwillbestoringyourcharactersanddialogues
Exporting
Whenexportingyourgame, itisvitaltoinclude.dqd filesinyour
build,aswellasthepluginconfigurationfile.
• GotoProject -> Export
• Selecttheplatformyouare exportingto(Linux/Windows/We-
b/etc.)
• SelecttheResources tab
• Under Filters to export non-resource files/folders,
add*.dqd,*.conf
Examples
ToseeabasicexampleofDialogueQuest,seetheexamples folderof
therepository.
AmoreadvancedexamplewouldbetheDialogueQuestTesterappli-
cation.
WritingDialogue
WritingdialogueisdoneintheDQD formatandisexplainedindetail
intheUser Manual.
ThismanualisforusageandextensionofDialogueQuestwithina
Godotproject.
Forimplementingthedialogue,seeCreatingDialogue
3
CreatingCharacters
Beforewestartingcreatingdialogues,weneedtoknowhowtocreate
characters.
Creatingcharactersisquitesimple,simplycreateanewDQCharacter
ResourceinyourDataDirectory,andDialogueQuestwillautomati-
callybeabletofindanduseit.
Whencreatingacharacters,youmustprovideacharacter_id.This
ishowthecharacterwillbereferredtoinDQD.
ExportingCharacters
DialogueQuestallowsforexportingyourcharacterstofilesthatcan
thenbeimportedinDialogueQuestTesteroranotherGodotproject
usingDialogueQuest.
ExportedDialogueQuestcharactersaresavedinthe.dqc format.
Note - Exported characters are not Godot resources. Their only
functionality is exporting and importing.
Toexport,gototheDialogueQuest tabintheGodoteditor,select
yourcharacters,andclickExport.Youwillthenbepromptedforthe
directorytosavethecharactersin.
Toimport,gototheDialogueQuest tabintheGodoteditor,andpress
Import,thenselectallrelevant.dqc characterfiles.
SeeAlso
DialogueQuestTester
CreatingDialogue
Tocreateadialogue,simplycreateanew.dqd file.
Ifyouputthefileinyourdatadirectory,youwillnothavetospecify
afullpathforit.SeeStartingtheDialogue
4
PlayingDialogue
Scenesetup
Toplaydialogue,youshouldsetupyoursceneasfollows:
...
2 CanvasLayer
DQDialoguePlayer
4 DQDialogueBox
DQChoiceMenu
6...
ClickontheDQDialoguePlayer andprovideitwiththeDQDialogueBox,
aswellasDQChoiceMenu.
AlsocreateaDQDialoguePlayerSettings forit.Itisrecommended
tosavethisresourceasafileinyourproject.
You can also do this setup through code, however make sure the
DQDialoguePlayer nodesetupbeforeitisaddedtothescene.
Whensettingupthescene,makesureyouinstantiatethescenefor
eachcomponent,ratherthaninstantiatingthescriptobject.
Thescenescanbefoundatthefollowingpaths:
prefabs/systems/dqd/dialogue_player.tscn
2 prefabs/ui/dialogue/components/dialogue_box/dialogue_box.tscn
prefabs/ui/dialogue/components/choice_menu/choice_menu.tscn
Startingthedialogue
In order to start the dialogue, use the DQDialoguePlayer.play()
method.
dialogue_player.play("my_dialogue_name")
2 # These are also valid ways to provide the dialogue
# dialogue_player.play("my_dialogue_name.dqd")
4 #
dialogue_player.play("res://dialogue_quest/my_dialogue_name.dqd")
Takenote-Ifyour.dqd fileisnotinyourdatadirectory,youwill
havetoprovidethefullfilepath.
Stoppingthedialogue
Ifyouwanttostopthedialogueearly,youcancalltheDQDialoguePlayer.stop()
methodwhichwillendthedialogueearly.
5
Settings
Settingsaresavedinthe.dialogue_quest_settings.conf file.
WhenrunningfromtheGodotEditor,thesettingswillbedecidedby
theProjectSettings.
SettingsOptions
• data_directory
– Thedatadirectoryisexplainedinthedatadirectorysection.
• say_by_name
– Ifenabled,thesay statementwillbeoptional,andwillau-
tomaticallybeusedifthestatmentisavalidcharacterID.
Thismaysavetimeforwriters,andisenabledbydefault.
Alsosee
datadirectory
Theusermanualentryonthesay statement
ExtendingDialogueQuest
Theming
DialogueQuestusesmostlyGodot’snativeThemesystemfordesigning
howtheinterfacelooks.
YoucancreateanewThemeandimportthesettingsfromthedefault
DialogueQuesttheme,orcreateonecompletelyfromscratchasthe
defaultthemeisquitesmall.
ThemainwayofcustomizingdialoguecomponentsinDialogueQuest
issimplycreatinganinheritedscene,andchangingithoweveryou
like.
SomenodessuchasDQDialogueBox havesettings objects,forex-
ampleDQDialogueBoxSettings,whichprovidessomecommoncus-
tomizations.
SeeAlso
Theme
Usingthethemeeditor
6
CustomStatements
DialogueQuestallowsyoutoaddcustomstatementstoDQD andextend
thefeaturesetofDqdParser
Todoso,dothefollowing:
## my_node_or_autoload.gd
4 var statement: String
2
8
class SectionMySection extends DQDqdParser.DqdSection:
6 func solve_flags() -> void:
pass
func _ready() -> void:
10 DQDqdParser.statements.append(
DQDqdParser.Statement.new("my_statement",
_my_statement_func)
12 )
14 ## Returns SectionPipeline on success
## Returns DQDqdParser.DqdError on failure
16 static func _my_statement_func(pipeline:
PackedStringArray):
if pipeline.size() <= 2:
18 var error := DQDqdParser.DqdError.new("Error!
Cannot parse statement my_statement, please
provide at least 2 arguments.")
return error
20
22 var sec := SectionMySection.new()
sec.statement = pipeline[1] + pipeline[2]
return sec
FirstwecreateanewsectionclasswhichextendsDQDqdParser.DqdSection,
thiscanbeeitheralocalydefinedclassliketheexample,oranew
scriptwithclass_name definition.
Wecangiveitthesolve_flags() methodwhichwilldefinehowthe
${flag} syntaxworksinDQD.
Now we need to create our parser function, in this case
_my_statement_func.Notethatthestatic isoptional,howeverthe
restofthesignatureiscritical.
ThefunctionmusttakeinanargumentoftypePackedStringArray,
andmustreturneitheranobjectofclassinheritingDqdSection indi-
7
catingitissuccessful,orDqdError indicatingithasfailed.
Thepipeline argumentisanarrayofeverypipe-seperatedargument
inthelinethestatementwasfoundin.
Note that: - It contains the statement itself (always, at index
0) - It contains whitespace, you can use the helper functions
DQScriptingHelper.remove_whitespace,DQScriptingHelper.trim_whitespace,
DQScriptingHelper.trim_whitespace_prefix,DQScriptingHelper.trim_whitespace_suffi
Lastly we must add a new DQDqdParser.Statement object to
DQDqdParser.statements.
TheDQDqdParser.Statement constructortakes2arguments:-The
statement itself, the word that will be referred to in DQD. - The
callbackfunctionthatwillbeusedtoparsethethestatement.
Rightnow,yourstatementisparsed,howeveritcannotactuallydo
anythinguntilyouimplementit’slogic.SeeCustomLogic
CustomLogic
ThelogicofDialogueQuestishandledintheDQDialoguePlayer class.
Inordertoaddcustomlogic,youmustcreateanewclassextending
DQDialoguePlayer.
Onceyoudo,youcanhandleyourcustomstatementlikeso:
## my_dialogue_player.gd
2 extends DQDialoguePlayer
4 func _ready() -> void:
self.section_handlers.append(
6 SectionHandler.new(SectionMySection,
_handle_my_section),
)
8
10
super._ready()
12 func _handle_my_section(section: SectionMySection) ->
void:
# Here you have access to all parts of the
DQDialoguePlayer
14 print("This section doesn't do anything yet... It's
statement is %s" section.statement)
8
To add a handler, we must add a SectionHandler object to the
section_handlers array.
TheconstructorofSectionHandler takestwoparameters, aclass
(objectoftypeGDScript),andaCallable.
When the parser returns the class you provided, the function you
providedwillbecalledwiththeparser’sreturnedobject.
Now we need to create our handler function, in this case
_handle_my_section.
Thefunctionmusttakeinanargumentofyoursectionclass,inthis
caseSectionMySection.Itdoesnotreturnanything.
TheFlagssystem
Flagsareglobalvariablesthatcanbeaccessedfrombothcodeand
dialogue.
Anexample:
TheyareaccessibleviatheglobalDQFlags instanceDialogueQuest.Flags
2 DialogueQuest.Flags.raise("flag1")
4 DialogueQuest.Flags.set_flag("flag2", 2)
6 DialogueQuest.Flags.set_flag("flag3", "a third flag")
8 # Outputs 2
print(DialogueQuest.Flags.get("flag2"))
10
# Outputs'A third flag'
12 print(DialogueQuest.Flags.get("flag3"))
Alsosee
Theusermanualentryontheflag statement
DialogueQuestsignals
ThereareafewimportantsignalsinDialogueQuest:
9
Theerrorsignal
DialogueQuestusesassert statementsforit’scriticalerrors,which
willpausethegamewhenrunningintheeditor,howeverwillnotdo
soinareleasebuild.
ForthepurposeofhandlingerrorsinreleasebuildsaswellasGUI,
DialogueQuestemitstheDialogueQuest.error(message: String)
signalwhenanerroroccures.
DQSignals
Other main signals are available via the DQSignals instance
DialogueQuest.Signals
Thesignalsare:
• dialogue_started(dialogue_id:String)
• dialogue_ended(dialogue_id:String)
• dialogue_signal(params:Array)
– Emittedviathesignal statmentindialogue.
• choice_made(choice:String)
– Emittedwhenaplayermakesachoiceduringdialogue.
Seealso
Thesignal statementintheusermanual.
Thechoice statementintheusermanual.
10