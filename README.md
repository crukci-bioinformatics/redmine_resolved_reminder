# Redmine Resolved Reminder

For bug fixes and feature requests, the traditional work flow is to implement
the change, then set the issue's status to "resolved" and assign it to the
original requestor.  The requestor tests the change, and (assuming he or she
is happy with the resolution) closes the issue.  Unfortunately it is easy
for issues to get lost in "resolved" status, and never be tested and closed.

This plugin sends email to users who have issues assigned to them with
status of "resolved", to remind them to test and close them.  It is intended
to be run via a CRON job on, say, a weekly basis.

## Usage

The command to run the reminder program is:

  > resolved_reminder [-t|--test] [-v|--version]

where the `-t` or `--test` option runs in test mode, sending no emails but
writing to standard out what would be sent, and `-v` or `--version` reports
the version of the gem.

### NOTA BENE

This gem accesses the Redmine database, obviously.  The path to the Redmine
application is hard-coded in .../lib/redmineResolvedReminder/constants.rb, so
if (when) Redmine is upgraded, this path will need to change accordingly.
