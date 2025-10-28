--[[
    GM9Megascript.lua
    A port of the original GM9Script to Lua

    By 'The Sun God: Nika'
    Original script is by annson24

    Credits:
    - d0k3
    - 8bitwonder
    - windows_server_2003
    - SvenDaHacker64
    - MyLegGuy
    - nemillois
    - AnalogMan151
    - TurdPooCharger
    - (And many more that is not listed here)
]]

-- (( VARIABLES )) --

-- The big table variable
local GM9Megascript = {}

-- Other variables for the script that are needed
GM9Megascript.Helpers = {}
GM9Megascript.Menus = {}
GM9Megascript.ErrorMenus = {}

GM9Megascript.Processes = {}

GM9Megascript.BackupOptions = {}
GM9Megascript.RestoreOptions = {}

-- Menu display on the top screen
local PREVIEW_MODE_TEXT = {
    BEGINNING = "GODMODE9 ALL-IN-ONE MEGASCRIPT\nby annson24 & The Sun God: Nika\n \n",
    CREDITS = "Credits:\nd0k3\n8bitwonder\nwindows_server_2003\nSvenDaHacker64\nMyLegGuy\nemillois\nAnalogMan151\nTurdPooCharger\netc.",
    BACKUP = "Backup Options",
    SYSNAND_BACKUP = "Backup Options\n>SysNAND Backup",
    EMUNAND_BACKUP = "Backup Options\n>EmuNAND Backup",
    RESTORE = "Restore Options",
    SYSNAND_RESTORE_FULL = "Restore Options\n>SysNAND Restore (Full)",
    SYSNAND_RESTORE_SAFE = "Restore Options\n>SysNAND Restore (Safe)",
    EMUNAND_RESTORE = "Restore Options\n>EmuNAND Restore",
}
local PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.CREDITS

-- Menu table IDs
local GM9MENULIST = {
    MAIN = 1,
    BACKUP_OPTIONS = 2,
    SYSNAND_BACKUP = 3,
    EMUNAND_BACKUP = 4,
    ERROR_SYSNAND_BACKUP = 5,
    ERROR_EMUNAND_BACKUP = 6,
    RESTORE_OPTIONS = 7,
    SYSNAND_RESTORE_FULL = 8,
    SYSNAND_RESTORE_SAFE = 9,
    EMUNAND_RESTORE = 10,
    ERROR_SYSNAND_RESTORE_SAFE = 11,
    ERROR_SYSNAND_RESTORE_FULL = 12,
    ERROR_EMUNAND_RESTORE = 13,
    NO_MENU_CREATED = 99999,
}

-- Current menu
local GM9CURRENTMENU = 0

-- GM9IN folder
local GM9IN = "0:/gm9/in"

-----------------

-- (( PRE-STARTERS )) --

-- Create the GM9IN folder if it doesn't exist
if not fs.exists(GM9IN) then
    fs.mkdir(GM9IN)
end

-----------------

-- (( HELPERS )) --

-- Helper to make a menu with options that run a specific function from whatever option is selected
function GM9Megascript.Helpers.MakeMenu(title, options, optionFunctions, menuID)
    -- Specify the menu ID
    GM9CURRENTMENU = menuID
    -- Ask the user with the options
    local selectAsk = ui.ask_selection(title, options)
    -- Check for "B = Cancel", and return to the previous menu if done so
    if selectAsk == nil then
        GM9Megascript.menuList[GM9CURRENTMENU].functionToRun()
    end
    -- Create the ask number
    local selectName = ""
    -- If asked, get the answer number
    if selectAsk then
        selectName = options[selectAsk]
    end

    -- Run the specifed script from the options
    optionFunctions[selectAsk]()
end

-- Helper to draw text centered on the top screen
function GM9Megascript.Helpers.DrawTopScreenTextCenter(text)
    -- Clear the text first
    ui.clear()
    -- Now draw the text in the center of the screen
    ui.show_text(text)
end

-- Helper to create a full menu by using a simple function
function GM9Megascript.Helpers.MakeFullMenu(inTable)
    if inTable.topText == nil then
        inTable.topText = "Error: No menu created.\n \nPress A to exit the script."
    end
    if inTable.menuSelections == nil then
        inTable.menuSelections = {
            "Exit Script",
        }
    end
    if inTable.selectionFunctions == nil then
        inTable.selectionFunctions = {
            GM9Megascript.ExitScript,
        }
    end
    if inTable.menuID == nil then
        inTable.menuID = 99999
    end
    if inTable.optionText == nil then
        inTable.optionText = "Choose an option."
    end
    -- Draw the preview mode text on top of the screen
    GM9Megascript.Helpers.DrawTopScreenTextCenter(inTable.topText)
    -- Ask and execute a function specfied via an option
    GM9Megascript.Helpers.MakeMenu(inTable.optionText, inTable.menuSelections, inTable.selectionFunctions, inTable.menuID)
end

-----------------

-- (( MENUS )) --

-- [ EXIT SCRIPT ] --
function GM9Megascript.ExitScript()
    -- Returning to the GodMode9 main menu.
    return
end









-- [[[ SysNAND BACKUP PROCESS ]]] --
function GM9Megascript.Processes.SysNANDBackup()
    -- Draw top screen text
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.SYSNAND_BACKUP
    GM9Megascript.Helpers.DrawTopScreenTextCenter(PREVIEW_MODE)

    -- Find out if the SysNAND has an empty ID to copy through, and use a blank nonexistant file for the backup
    local SYSNAND_BACKUP_NAME = fs.find_not(GM9OUT.."/"..util.get_datestamp().."_"..sys.serial.."_sysnand_??.bin")

    -- Go ahead and back it up
    local hasError = fs.copy("S:/nand_minsize.bin", SYSNAND_BACKUP_NAME)

    -- If success, let the user know
    if hasError == nil then
        ui.echo("Backup created successfully!\n \nBackup location:\n"..SYSNAND_BACKUP_NAME)
        GM9Megascript.Menus.BackupOptions()
    else
        -- If failed, let the user know the error ID and that it failed to copy
        ui.echo("Backup failed to copy...\n \nError: "..tostring(hasError))
        GM9Megascript.ErrorMenus.SysNANDBackup()
    end
end

-- [[ SysNAND BACKUP ]] --
function GM9Megascript.BackupOptions.SysNAND()
    -- Draw top screen text
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.SYSNAND_BACKUP
    GM9Megascript.Helpers.DrawTopScreenTextCenter(PREVIEW_MODE)

    if not ui.ask("Create a SysNAND backup in "..GM9OUT.."?\n \nPlease make sure you have enough space.\nAt least 1.3GB of free space is recommended.\n") then
        GM9Megascript.Menus.BackupOptions()
    else
        GM9Megascript.Processes.SysNANDBackup()
    end
end





-- [[[ EmuNAND BACKUP PROCESS ]]] --
function GM9Megascript.Processes.EmuNANDBackup()
    -- Draw top screen text
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.EMUNAND_BACKUP
    GM9Megascript.Helpers.DrawTopScreenTextCenter(PREVIEW_MODE)

    -- Before we do anything, check if EmuNAND actually exists
    if not fs.exists("E:/") then
        -- Don't backup anything if EmuNAND is a no-go
        ui.echo("There's no EmuNAND. Aborted.")
        GM9Megascript.Menus.BackupOptions()
    end

    -- Find out if the EmuNAND has an empty ID to copy through, and use a blank nonexistant file for the backup
    local EMUNAND_BACKUP_NAME = fs.find_not(GM9OUT.."/"..util.get_datestamp().."_"..sys.serial.."_emunand_??.bin")

    -- Go ahead and back it up
    local hasError = fs.copy("E:/nand_minsize.bin", EMUNAND_BACKUP_NAME)

    -- If success, let the user know
    if hasError == nil then
        ui.echo("Backup created successfully!\n \nBackup location:\n"..EMUNAND_BACKUP_NAME)
        GM9Megascript.Menus.BackupOptions()
    else
        -- If failed, let the user know the error ID and that it failed to copy
        ui.echo("Backup failed to copy...\n \nError: "..tostring(hasError))
        GM9Megascript.ErrorMenus.EmuNANDBackup()
    end
end

-- [[ EmuNAND BACKUP ]] --
function GM9Megascript.BackupOptions.EmuNAND()
    -- Draw top screen text
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.EMUNAND_BACKUP
    GM9Megascript.Helpers.DrawTopScreenTextCenter(PREVIEW_MODE)

    if not ui.ask("Create a EmuNAND backup in "..GM9OUT.."?\n \nPlease make sure you have enough space.\nAt least 1.3GB of free space is recommended.\n") then
        GM9Megascript.Menus.BackupOptions()
    else
        GM9Megascript.Processes.EmuNANDBackup()
    end
end





-- [ BACKUP OPTIONS ] --
function GM9Megascript.Menus.BackupOptions()
    -- Title below
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.BACKUP
    -- Create the full menu
    GM9Megascript.Helpers.MakeFullMenu(
        {
            topText = PREVIEW_MODE,
            menuSelections = {
                "SysNAND Backup",
                "EmuNAND Backup",
                "Return to Main Menu",
            },
            selectionFunctions = {
                [1] = GM9Megascript.BackupOptions.SysNAND,
                [2] = GM9Megascript.BackupOptions.EmuNAND,
                [3] = GM9Megascript.Menus.MainMenu,
            },
            menuID = GM9MENULIST.BACKUP_OPTIONS,
        }
    )
end





-- [[[ SysNAND RESTORE (FULL) PROCESS ]]] --
function GM9Megascript.Processes.SysNANDRestoreFull()
    -- Draw top screen text
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.SYSNAND_RESTORE_FULL
    GM9Megascript.Helpers.DrawTopScreenTextCenter(PREVIEW_MODE)

    -- Now select the backup
    local NAND_BACKUP_TO_RESTORE = ""
    local USE_CUSTOM_DIR = false
    local CUSTOM_DIR = ""

    -- Ask for a custom directory, and specify a NAND backup from either answer
    if ui.ask("Would you like to use a custom directory?\n \nIf you don't want to, the \"GM9\" out\ndirectory will be used instead.") then
        CUSTOM_DIR = fs.ask_select_dir("Select directory to find NAND backups.", "0:/", {explorer = true})
        if not CUSTOM_DIR then
            ui.echo("NAND restore cancelled.")
            GM9Megascript.Menus.RestoreOptions()
        end
        NAND_BACKUP_TO_RESTORE = fs.ask_select_file("Select your NAND backup.", CUSTOM_DIR.."/*nand_??.bin")
    else
        NAND_BACKUP_TO_RESTORE = fs.ask_select_file("Select your NAND backup.", GM9OUT.."/*nand_??.bin")
    end
    -- Cancel if we don't select a backup
    if not NAND_BACKUP_TO_RESTORE then
        ui.echo("NAND restore cancelled.")
        GM9Megascript.Menus.RestoreOptions()
    end
    -- Prompt to be ready
    if ui.ask("Ready to full restore your SysNAND?\n \nIf you have any hax installed, it MAY\nbe erased if none is on the\nbackup.") == nil then
        -- Cancelled
        ui.echo("NAND restore cancelled.")
        GM9Megascript.Menus.RestoreOptions()
    else
        -- Allow to write to the NAND
        if not fs.allow("S:/", {ask_all = true}) then
            -- Permissions denied
            ui.echo("Permissions to restore the NAND denied.\n \nAborted.")
            GM9Megascript.Menus.RestoreOptions()
        end
        -- Let the user know that it needs to be mounted in order to restore
        if ui.ask("This script will need to mount the\nbackup image in order to restore\nthe NAND.\n \nMount and continue?") then
            fs.img_mount(NAND_BACKUP_TO_RESTORE)
            -- Needs to be verified
            if not fs.verify("I:/nand_minsize.bin") then
                ui.echo("This isn't a valid NAND backup.\n \nAborted.")
                GM9Megascript.Menus.RestoreOptions()
            end
            -- Now write the backup to nand.bin
            if fs.write_file("I:/nand_minsize.bin", 0, "S:/nand.bin") then
                -- Unmount
                fs.img_umount()
                -- Remove this file (Need more info)
                fs.remove("1:/data/"..sys.sys_id0.."/sysdata/00010011/00000000")
                -- Success!
                ui.echo("Successfully restored!\n \nBackup restored:\n"..NAND_BACKUP_TO_RESTORE)
                GM9Megascript.Menus.RestoreOptions()
            else
                ui.echo("An error occurred during the transfer\nprocess.\n \nPlease try again.")
                GM9Megascript.ErrorMenus.SysNANDRestoreFull()
            end
        else
            -- Image mount denied
            ui.echo("Image mount to restore the NAND denied.\n \nAborted.")
            GM9Megascript.Menus.RestoreOptions()
        end
    end
end

-- [[ SysNAND RESTORE (FULL) ]] --
function GM9Megascript.RestoreOptions.SysNANDFull()
    -- Draw top screen text
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.SYSNAND_RESTORE_FULL
    GM9Megascript.Helpers.DrawTopScreenTextCenter(PREVIEW_MODE)

    -- Let the user know it may erase their exploit if their backup doesn't have one before letting them restore their backup
    if not ui.ask("!!WARNING!!\nRestoring with this option WILL erase any\nSystem exploit depending on the backup you\nrestore!\nProceed only if you know your backup is\nsafe!\n \nContinue?\n") then
        GM9Megascript.Menus.RestoreOptions()
    else
        GM9Megascript.Processes.SysNANDRestoreFull()
    end
end





-- [[[ SysNAND RESTORE (SAFE) PROCESS ]]] --
function GM9Megascript.Processes.SysNANDRestoreSafe()
    -- Check the hax we're in
    if HAX == "" then
        ui.echo("There is no exploit found to safely\nrestore the SysNAND.\n \nTo avoid bricks, this script will abort\nthis process.")
        GM9Megascript.Menus.RestoreOptions()
    elseif HAX == "ntrboot" then
        ui.echo("ntrboot can't be used to safely\nrestore the SysNAND.\n \nTo avoid bricks, this script will abort\nthis process.")
        GM9Megascript.Menus.RestoreOptions()
    else
        local NAND_BACKUP_TO_RESTORE = ""
        -- Ask for a custom directory, and specify a NAND backup from either answer
        if ui.ask("Would you like to use a custom directory?\n \nIf you don't want to, the \"GM9\" out\ndirectory will be used instead.") then
            CUSTOM_DIR = fs.ask_select_dir("Select directory to find NAND backups.", "0:/", {explorer = true})
            if not CUSTOM_DIR then
                ui.echo("NAND restore cancelled.")
                GM9Megascript.Menus.RestoreOptions()
            end
            NAND_BACKUP_TO_RESTORE = fs.ask_select_file("Select your NAND backup.", CUSTOM_DIR.."/*nand_??.bin")
        else
            NAND_BACKUP_TO_RESTORE = fs.ask_select_file("Select your NAND backup.", GM9OUT.."/*nand_??.bin")
        end
        -- Cancel if we don't select a backup
        if not NAND_BACKUP_TO_RESTORE then
            ui.echo("NAND restore cancelled.")
            GM9Megascript.Menus.RestoreOptions()
        end
        -- Prompt to be ready
        if ui.ask("Ready to safe restore your SysNAND?") == nil then
            -- Cancelled
            ui.echo("NAND restore cancelled.")
            GM9Megascript.Menus.RestoreOptions()
        else
            -- Allow to write to the NAND
            if not fs.allow("S:/", {ask_all = true}) then
                -- Permissions denied
                ui.echo("Permissions to restore the NAND denied.\n \nAborted.")
                GM9Megascript.Menus.RestoreOptions()
            end

            -- Let the user know that it needs to be mounted in order to restore
            if ui.ask("This script will need to mount the\nbackup image in order to restore\nthe NAND.\n \nMount and continue?") then
                fs.img_mount(NAND_BACKUP_TO_RESTORE)
            else
                -- Image mount denied
                ui.echo("Image mount to restore the NAND denied.\n \nAborted.")
                GM9Megascript.Menus.RestoreOptions()
            end

            -- Find each individual CTRNAND/TWL file
            fs.find("I:/ctrnand_full.bin")
            fs.find("I:/twln.bin")
            fs.find("I:/twlp.bin")

            -- Now copy each file if all of them are found over to each respective place
            fs.copy("I:/ctrnand_full.bin", "S:/ctrnand_full.bin")
            fs.copy("I:/twln.bin", "S:/twln.bin")
            fs.copy("I:/twlp.bin", "S:/twlp.bin")

            -- Unmount
            fs.img_umount()
            
            -- Remove this file (Need more info)
            fs.remove("1:/data/"..sys.sys_id0.."/sysdata/00010011/00000000")

            -- Success!
            ui.echo("Successfully restored!\n \nBackup restored:\n"..NAND_BACKUP_TO_RESTORE)
            GM9Megascript.Menus.RestoreOptions()
        end
    end
end

-- [[ SysNAND RESTORE (SAFE) ]] --
function GM9Megascript.RestoreOptions.SysNANDSafe()
    -- Draw top screen text
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.SYSNAND_RESTORE_SAFE
    GM9Megascript.Helpers.DrawTopScreenTextCenter(PREVIEW_MODE)

    -- Run the process
    GM9Megascript.Processes.SysNANDRestoreSafe()
end





-- [[[ EmuNAND RESTORE PROCESS ]]] --
function GM9Megascript.Processes.EmuNANDRestore()
    -- Now select the backup
    local NAND_BACKUP_TO_RESTORE = ""
    local USE_CUSTOM_DIR = false
    local CUSTOM_DIR = ""

    -- Before we do anything, check if EmuNAND actually exists
    if not fs.exists("E:/") then
        -- Don't restore anything if EmuNAND is a no-go
        ui.echo("There's no EmuNAND. Aborted.")
        GM9Megascript.Menus.RestoreOptions()
    end

    -- Ask for a custom directory, and specify a NAND backup from either answer
    if ui.ask("Would you like to use a custom directory?\n \nIf you don't want to, the \"GM9\" out\ndirectory will be used instead.") then
        CUSTOM_DIR = fs.ask_select_dir("Select directory to find NAND backups.", "0:/", {explorer = true})
        if not CUSTOM_DIR then
            ui.echo("NAND restore cancelled.")
            GM9Megascript.Menus.RestoreOptions()
        end
        NAND_BACKUP_TO_RESTORE = fs.ask_select_file("Select your NAND backup.", CUSTOM_DIR.."/*nand_??.bin")
    else
        NAND_BACKUP_TO_RESTORE = fs.ask_select_file("Select your NAND backup.", GM9OUT.."/*nand_??.bin")
    end
    -- Cancel if we don't select a backup
    if not NAND_BACKUP_TO_RESTORE then
        ui.echo("NAND restore cancelled.")
        GM9Megascript.Menus.RestoreOptions()
    end
    -- Prompt to be ready
    if ui.ask("Ready to restore your EmuNAND?") == nil then
        -- Cancelled
        ui.echo("NAND restore cancelled.")
        GM9Megascript.Menus.RestoreOptions()
    else
        -- Allow to write to the NAND
        if not fs.allow("E:/", {ask_all = true}) then
            -- Permissions denied
            ui.echo("Permissions to restore the NAND denied.\n \nAborted.")
            GM9Megascript.Menus.RestoreOptions()
        end
        -- Let the user know that it needs to be mounted in order to restore
        if ui.ask("This script will need to mount the\nbackup image in order to restore\nthe NAND.\n \nMount and continue?") then
            fs.img_mount(NAND_BACKUP_TO_RESTORE)
            -- Needs to be verified
            if not fs.verify("I:/nand_minsize.bin") then
                ui.echo("This isn't a valid NAND backup.\n \nAborted.")
                GM9Megascript.Menus.RestoreOptions()
            end
            -- Now write the backup to nand.bin
            if fs.write_file("I:/nand_minsize.bin", 0, "E:/nand.bin") then
                -- Unmount
                fs.img_umount()
                -- Remove this file (Need more info)
                fs.remove("1:/data/"..sys.sys_id0.."/sysdata/00010011/00000000")
                -- Success!
                ui.echo("Successfully restored!\n \nBackup restored:\n"..NAND_BACKUP_TO_RESTORE)
                GM9Megascript.Menus.RestoreOptions()
            else
                ui.echo("An error occurred during the transfer\nprocess.\n \nPlease try again.")
                GM9Megascript.ErrorMenus.EmuNANDRestore()
            end
        else
            -- Image mount denied
            ui.echo("Image mount to restore the NAND denied.\n \nAborted.")
            GM9Megascript.Menus.RestoreOptions()
        end
    end
end

-- [[ EmuNAND RESTORE ]] --
function GM9Megascript.RestoreOptions.EmuNAND()
    -- Draw top screen text
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.EMUNAND_RESTORE
    GM9Megascript.Helpers.DrawTopScreenTextCenter(PREVIEW_MODE)

    GM9Megascript.Processes.EmuNANDRestore()
end





-- [ RESTORE OPTIONS ] --
function GM9Megascript.Menus.RestoreOptions()
    -- Title below
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.RESTORE
    -- Create the full menu
    GM9Megascript.Helpers.MakeFullMenu(
        {
            topText = PREVIEW_MODE,
            menuSelections = {
                "SysNAND Restore (Full)",
                "SysNAND Restore (Safe)",
                "EmuNAND Restore",
                "Return to Main Menu",
            },
            selectionFunctions = {
                [1] = GM9Megascript.RestoreOptions.SysNANDFull,
                [2] = GM9Megascript.RestoreOptions.SysNANDSafe,
                [3] = GM9Megascript.RestoreOptions.EmuNAND,
                [4] = GM9Megascript.Menus.MainMenu,
            },
            menuID = GM9MENULIST.RESTORE_OPTIONS,
        }
    )
end





-- [ MAIN MENU ] --
function GM9Megascript.Menus.MainMenu()
    -- Title below
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.CREDITS
    -- Create the full menu
    GM9Megascript.Helpers.MakeFullMenu(
        {
            topText = PREVIEW_MODE,
            menuSelections = {
                "Backup Options",
                "Restore Options",
                "CTRNAND Transfer",
                "Hax Options",
                "FBI -> H&S Options",
                "Dump Options",
                "Inject Options",
                "Scripts from Plailect's Guide",
                "Miscellaneous",
                "Exit Script",
            },
            selectionFunctions = {
                [1] = GM9Megascript.Menus.BackupOptions,
                [2] = GM9Megascript.Menus.RestoreOptions,
                [3] = GM9Megascript.Menus.CTRNANDTransfer,
                [4] = GM9Megascript.Menus.HaxOptions,
                [5] = GM9Megascript.Menus.FBIHAndSOptions,
                [6] = GM9Megascript.Menus.DumpOptions,
                [7] = GM9Megascript.Menus.InjectOptions,
                [8] = GM9Megascript.Menus.PlailectsGuide,
                [9] = GM9Megascript.Menus.Miscellaneous,
                [10] = GM9Megascript.ExitScript,
            },
            menuID = GM9MENULIST.MAIN,
        }
    )
end







-- (( ERROR MENUS )) --

-- [[[ SysNAND BACKUP PROCESS: ERROR SCREEN ]]] --
function GM9Megascript.ErrorMenus.SysNANDBackup()
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.SYSNAND_BACKUP
    GM9Megascript.Helpers.MakeFullMenu(
        {
            topText = PREVIEW_MODE,
            optionText = "Process failure options:",
            menuSelections = {
                "Try Again",
                "Return to Backup Menu",
                "Return to Main Menu",
                "Exit Script",
            },
            selectionFunctions = {
                [1] = GM9Megascript.Processes.SysNANDBackup,
                [2] = GM9Megascript.Menus.BackupOptions,
                [3] = GM9Megascript.Menus.MainMenu,
                [4] = GM9Megascript.ExitScript,
            },
            menuID = GM9MENULIST.ERROR_SYSNAND_BACKUP,
        }
    )
end

-- [[[ EmuNAND BACKUP PROCESS: ERROR SCREEN ]]] --
function GM9Megascript.ErrorMenus.EmuNANDBackup()
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.EMUNAND_BACKUP
    GM9Megascript.Helpers.MakeFullMenu(
        {
            topText = PREVIEW_MODE,
            optionText = "Process failure options:",
            menuSelections = {
                "Try Again",
                "Return to Backup Menu",
                "Return to Main Menu",
                "Exit Script",
            },
            selectionFunctions = {
                [1] = GM9Megascript.Processes.EmuNANDBackup,
                [2] = GM9Megascript.Menus.BackupOptions,
                [3] = GM9Megascript.Menus.MainMenu,
                [4] = GM9Megascript.ExitScript,
            },
            menuID = GM9MENULIST.ERROR_EMUNAND_BACKUP,
        }
    )
end

-- [[[ EmuNAND BACKUP PROCESS: ERROR SCREEN ]]] --
function GM9Megascript.ErrorMenus.SysNANDRestoreFull()
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.SYSNAND_RESTORE_FULL
    GM9Megascript.Helpers.MakeFullMenu(
        {
            topText = PREVIEW_MODE,
            optionText = "Process failure options:",
            menuSelections = {
                "Try Again",
                "Return to Restore Menu",
                "Return to Main Menu",
                "Exit Script",
            },
            selectionFunctions = {
                [1] = GM9Megascript.Processes.SysNANDRestoreFull,
                [2] = GM9Megascript.Menus.RestoreOptions,
                [3] = GM9Megascript.Menus.MainMenu,
                [4] = GM9Megascript.ExitScript,
            },
            menuID = GM9MENULIST.ERROR_SYSNAND_RESTORE_FULL,
        }
    )
end

-- [[[ SysNAND RESTORE (FULL) PROCESS: ERROR SCREEN ]]] --
function GM9Megascript.ErrorMenus.SysNANDRestoreSafe()
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.SYSNAND_RESTORE_SAFE
    GM9Megascript.Helpers.MakeFullMenu(
        {
            topText = PREVIEW_MODE,
            optionText = "Process failure options:",
            menuSelections = {
                "Try Again",
                "Return to Restore Menu",
                "Return to Main Menu",
                "Exit Script",
            },
            selectionFunctions = {
                [1] = GM9Megascript.Processes.SysNANDRestoreSafe,
                [2] = GM9Megascript.Menus.RestoreOptions,
                [3] = GM9Megascript.Menus.MainMenu,
                [4] = GM9Megascript.ExitScript,
            },
            menuID = GM9MENULIST.ERROR_SYSNAND_RESTORE_SAFE,
        }
    )
end

-- [[[ EmuNAND RESTORE PROCESS: ERROR SCREEN ]]] --
function GM9Megascript.ErrorMenus.EmuNANDRestore()
    PREVIEW_MODE = PREVIEW_MODE_TEXT.BEGINNING..PREVIEW_MODE_TEXT.EMUNAND_RESTORE
    GM9Megascript.Helpers.MakeFullMenu(
        {
            topText = PREVIEW_MODE,
            optionText = "Process failure options:",
            menuSelections = {
                "Try Again",
                "Return to Restore Menu",
                "Return to Main Menu",
                "Exit Script",
            },
            selectionFunctions = {
                [1] = GM9Megascript.Processes.EmuNANDRestore,
                [2] = GM9Megascript.Menus.RestoreOptions,
                [3] = GM9Megascript.Menus.MainMenu,
                [4] = GM9Megascript.ExitScript,
            },
            menuID = GM9MENULIST.ERROR_SYSNAND_RESTORE_SAFE,
        }
    )
end

-----------------

-- (( VARIABLES )) --

-- Menu tables
GM9Megascript.menuList = {
    [GM9MENULIST.MAIN] = {
        functionToRun = GM9Megascript.Menus.MainMenu,
    },
    [GM9MENULIST.BACKUP_OPTIONS] = {
        functionToRun = GM9Megascript.Menus.BackupOptions,
    },
    [GM9MENULIST.SYSNAND_BACKUP] = {
        functionToRun = GM9Megascript.BackupOptions.SysNAND,
    },
    [GM9MENULIST.EMUNAND_BACKUP] = {
        functionToRun = GM9Megascript.BackupOptions.EmuNAND,
    },
    [GM9MENULIST.ERROR_SYSNAND_BACKUP] = {
        functionToRun = GM9Megascript.ErrorMenus.SysNANDBackup,
    },
    [GM9MENULIST.ERROR_EMUNAND_BACKUP] = {
        functionToRun = GM9Megascript.ErrorMenus.EmuNANDBackup,
    },
    [GM9MENULIST.NO_MENU_CREATED] = {
        functionToRun = GM9Megascript.Helpers.MakeFullMenu,
    },
}

-----------------

-- Run this function at the very end of the script so all function calls & variables can exist for this script
GM9Megascript.Menus.MainMenu()
