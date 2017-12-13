<?php

$arr = [1,5,6,7,8,9, 15, 30, 45 , 50 , 70 , 80, 90, 100];

var_dump(binSearch($arr, 80));


function binSearch(array $arr, $search) {
//    for ($i = count($arr) / 2; $arr[$i] !== $search; ) {
//        if ()
//    }
    $last = count($arr) - 1;
    $i = (int)round($last / 2);

    while ($arr[$i] !== $search) {
        if ($i <= 0 || $i > $last)
            return false;

        if ($search < $arr[$i]) {
            $i = (int)($i / 2);
        } else {
            $i = min($i * 2, $last);
        }
    }
    return true;
}

function avg(array $arr) {
    return array_sum($arr) / count($arr);
}