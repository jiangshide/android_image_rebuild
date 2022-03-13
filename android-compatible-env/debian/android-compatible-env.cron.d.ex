#
# Regular cron jobs for the android-compatible-env package
#
0 4	* * *	root	[ -x /usr/bin/android-compatible-env_maintenance ] && /usr/bin/android-compatible-env_maintenance
