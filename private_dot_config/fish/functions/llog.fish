function llog --description "print the location to laravel's log file"
  set -l todays_log storage/logs/laravel-(date +%F).log

  if test -f $todays_log
    echo $todays_log
  else if test -f storage/logs/laravel.log
    echo storage/logs/laravel.log
  else
    echo "No Laravel log file found" > /dev/stderr
    return 1
  end
end
