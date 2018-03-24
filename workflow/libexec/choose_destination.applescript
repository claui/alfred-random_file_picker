set originalDestinationPath to ¬
	system attribute "destination_folder"

if (originalDestinationPath is missing value) ¬
	or (length of originalDestinationPath is 0) then
	tell application "System Events"
		set defaultLocation to path to (home folder of user domain)
	end tell
else
	set defaultLocation to ¬
		my alias (POSIX file originalDestinationPath)
end if

try
	set newDestinationPath to choose folder ¬
		with prompt ¬
			"Select folder to which random files are to be copied:"¬
		default location defaultLocation

	POSIX path of newDestinationPath
on error errorText number errorNumber
	originalDestinationPath
end try
