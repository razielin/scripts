<?php

use PHPUnit\Framework\TestCase;

class TestBinSearch extends TestCase {
    public function testSuccessfulSearch() {
        $arr = [1,5,6,7,8,9, 15, 30, 45 , 50 , 70 , 80, 90, 100];

        foreach ($arr as $value) {
            $this->assertTrue(binSearch($arr, $value), "Coudn't found: $value but it exists in array");
        }
    }
}
