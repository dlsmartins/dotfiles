#! /bin/sh

# This will perform chmod g-w for each file returned by compaudit
# to remove write access for group
compaudit | xargs -I % chmod g-w "%"
# This will perform chown to current user (Windows and Linux)
# for each file returned by compaudit
compaudit | xargs -I % chown $USER "%"
# Remove all dump files (which normally speed up initialization)
rm ~/.zcompdump*
# Regenerate completions file
compinit
