@ECHO off

set git_path=G:\github\birzhamemov
set dota_path_content=G:\SteamLibrary\steamapps\common\dota 2 beta\content\dota_addons\birzhamemov
set dota_path_game=G:\SteamLibrary\steamapps\common\dota 2 beta\game\dota_addons\birzhamemov

robocopy %git_path%\content "%dota_path_content%" /mir /move /NFL /NDL /NJH /NJS /nc /ns /np
robocopy %git_path%\game "%dota_path_game%" /mir /move /NFL /NDL /NJH /NJS /nc /ns /np

mklink /j %git_path%\content "%dota_path_content%"
mklink /j %git_path%\game "%dota_path_game%"
pause