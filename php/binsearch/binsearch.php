<?php

$arr = [1,5,6,7,8,9, 15, 30, 45 , 50 , 70 , 80, 90, 100];

var_dump(binSearch($arr, 6));


function binSearch(array $arr, $search) {
//    for ($i = count($arr) / 2; $arr[$i] !== $search; ) {
//        if ()
//    }
    $last = count($arr) - 1;
    $i = (int)round($last / 2);

    if ($arr[$i] === $search)
        return true;

    while ($i >= 0 || $i <= $last) {
        if ($arr[$i] > $search) {
            $i = (int)($i / 2);
        } else {
            $i = (int)(($i + $last) / 2);
        }
        if ($arr[$i] === $search)
            return true;
    }

    return false;

//    if ($arr[$i] > $search) {
//        while ($i > 0) {
//            $i = (int)($i / 2);
//            if ($arr[$i] === $search)
//                return true;
//        }
//        return false;
//    } else {
//        while ($i < $last) {
//            $i = (int)(($i + $last) / 2);
//            if ($arr[$i] === $search)
//                return true;
//        }
//        return false;
//    }


//    while ($arr[$i] !== $search) {
//        if ($i <= 0 || $i >= $last)
//            return false;
//
//        if ($search < $arr[$i]) {
//            $i = (int)($i / 2);
//        } else {
//            $i = (int)(($i + $last) / 2);
//        }
//    }
//    return true;
}

function avg(array $arr) {
    return array_sum($arr) / count($arr);
}