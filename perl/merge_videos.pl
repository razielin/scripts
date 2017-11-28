#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
local $SIG{INT} = &print_help;

my $outputFile = pop @ARGV;
my $inputFiles = join(' -i ', @ARGV);

# ffmpeg -i video1 -i video2 -filter_complex "[0:v]setpts=PTS-STARTPTS, pad=iw*2:ih[bg];[1:v]setpts=PTS-STARTPTS[fg]; [bg][fg]overlay=w" result.mp4
my $CMD = qq(ffmpeg -i $inputFiles -filter_complex "[0:v]setpts=PTS-STARTPTS, pad=iw*2:ih[bg];[1:v]setpts=PTS-STARTPTS[fg]; [bg][fg]overlay=w" $outputFile);
print $CMD;
system($CMD);


sub print_help {
    print "     Merge multiple videos into one with side-by-side composition\n";
    print "     Usage: $0 video1 video2 ... output_video.mp4\n";
}