#!/usr/bin/env php
<?php

use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Artisan;

require 'vendor/autoload.php';
(require 'bootstrap/app.php')->make(Kernel::class)->bootstrap();

$queues = collect([
    data_get(config('horizon'), 'defaults.*.queue'),
    data_get(config('horizon'), 'environments.*.*.queue'),
])->flatten()->filter()->unique();

if ($queues->isEmpty()) {
    echo "No Horizon queue configuration found. Clearing without specifying queue.\n";

    Artisan::call('horizon:clear', ['--ansi' => true]);
    echo Artisan::output();
} else {
    foreach ($queues as $queue) {
        Artisan::call('horizon:clear', ['--queue' => $queue, '--ansi' => true]);
        echo Artisan::output();
    }
}
