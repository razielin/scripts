<?php

if ($argc < 2) {
    error_log("error: missing youtube URL");
    echo "usage: " . basename(__FILE__) . " https://www.youtube.com/watch?v=...\n";
    exit(1);
}

$ytUrl = $argv[1];

echo "Reading tracklist from stdin...\n";

$audioFile = downloadAudioFromYoutubeVideo($ytUrl);

$tracks = readTracks('php://stdin');
foreach ($tracks as $track) {
    cutAudio($audioFile, $track->name . '.mp3', $track->startTime, $track->endTime);
}


//cutAudio($inFile, 'Go 2 - Play Loud.mp3', '01:07:26', '01:07:55');
//if (contains($name, '-')) {
//    [$artistName, $trackName] = array_map('trim', explode('-', $name));
//}


function trackTime(string $track): string {
    preg_match('(\d+:\d+(:\d+)?)', $track, $match);
    return $match[0];
}

function trackName(string $track): string {
    preg_match('(\d+:\d+(:\d+)? (.+))', $track, $match);
    return $match[2];
}

function contains(string $needle, string $haystack): bool {
    return strpos($haystack, $needle) !== false;
}


function cutAudio(string $inFile, string $outFile, string $fromTime, ?string $toTime) {
    $inFile = escapeshellarg($inFile);
    $outFile = escapeshellarg($outFile);
    $endTime = $toTime ? "-to $toTime" : '';
    doExec("ffmpeg -hide_banner -y -i $inFile -ss $fromTime $endTime -acodec copy $outFile");
//    doExec("mp3cut -o $outFile -t $fromTime$endTime $inFile");
}


function doExec(string $command) {
    echo $command . PHP_EOL;
    passthru($command, $ret);
    if ($ret !== 0) {
        exit(1);
    }
}

function execCommand($cmd) {
    $proc = proc_open($cmd,[
        1 => ['pipe','w'],
        2 => ['pipe','w'],
    ],$pipes);
//    $stdout = stream_get_contents($pipes[1]);
    $stderr = stream_get_contents($pipes[2]);
    fclose($pipes[1]);
    fclose($pipes[2]);
    $statusCode = proc_close($proc);
    if ($statusCode != 0) {
        throw new \RuntimeException("Exec command error:\n$stderr\n");
    }
}

/**
 * @param $file
 * @return Track[]
 */
function readTracks($file): array {
    /** @var Track[] $res */
    $res = [];
    $lines = array_filter(explode("\n", file_get_contents($file)));
    foreach ($lines as $line) {
        $res[] = readTrack($line);
    }
    foreach ($res as $i => $track) {
        setTrackEndTimeFromNextTrack($track, $res[$i + 1] ?? null);
    }
    return $res;
}

function readTrack(string $line): Track {
    $track = new Track();
    $track->name = trim(trackName($line));
    $track->startTime = trim(trackTime($line));
    return $track;
}

function setTrackEndTimeFromNextTrack(Track $track, ?Track $nextTrack): void {
    if ($nextTrack) {
        $track->endTime = $nextTrack->startTime;
    }
}

function downloadAudioFromYoutubeVideo(string $url) {
    $url = escapeshellarg($url);
    $filename = uniqid('track_download', false);
    register_shutdown_function(static function () use ($filename) {
        array_map('unlink', glob("$filename.*"));
    });
    doExec("youtube-dl --output '$filename.%(ext)s' --extract-audio --audio-quality 0 --audio-format mp3 $url");
//    echo $filename . '.mp3' . PHP_EOL;
    return $filename . '.mp3';
}

class Track {
    public $startTime;
    public $endTime;
    public $name;
}