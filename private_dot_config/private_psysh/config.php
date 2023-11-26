<?php

if (is_dir($_SERVER['HOME'] . '/.composer/vendor/spatie/invade/')) {
    require_once $_SERVER['HOME'] . '/.composer/vendor/spatie/invade/src/Invader.php';
    require_once $_SERVER['HOME'] . '/.composer/vendor/spatie/invade/src/functions.php';
}

return [
    'eraseDuplicates' => true,
];
