#!/usr/bin/env php
<?php

require 'vendor/autoload.php';

use Illuminate\Support\Arr;

$horizonConfig = require 'config/horizon.php';

$queues = array_unique(
    Arr::flatten([
        data_get($horizonConfig, 'defaults.*.queue'),
        data_get($horizonConfig, 'environments.*.*.queue'),
    ])
);

if (count($queues) === 0) {
    echo "No Horizon queue configuration found. Clearing without specifying queue.\n";
    system("php artisan horizon:clear");
} else {
    foreach ($queues as $queue) {
        system("php artisan horizon:clear --queue={$queue}");
    }
}
