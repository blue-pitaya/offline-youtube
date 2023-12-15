#!/usr/bin/perl

use strict;
use warnings;

system "which yt-dlp" and die "Err: yt-dlp is not installed or not in PATH.";

my $subs_filename = "subs.conf"; 
my $video_resolution = 720;

sub try_get_channel_name {
  my $url = shift or die "Err: No url provided.";
  $url =~ /@(.+?)(\s|\/|$)/;
  return $1;
}

# TODO: check if yt-dlp exists

my $home = $ENV{HOME} or die 'Err: $HOME is not defined';
my $root_dir = "$home/Videos/youtube";
system "mkdir -p $ENV{HOME}/Videos/youtube" and die("Err: cannot make root dir.");

print "Root dir for youtube videos is: $root_dir\n";

my $subs_file = "$root_dir/$subs_filename";
die "Error: $subs_file dont exists in root dir" unless (-e $subs_file);

sub fetch_all {
  open my $fh, "<", $subs_file or die("Err: cant open subs file.");
  while (my $line = <$fh>) {
    chomp $line;
    # Skip comments
    if ($line =~ /^#/) {
      next;
    }

    my $channel_name = try_get_channel_name($line);
    unless ($channel_name) {
      print "Err: couldnt get channel name from line: $line\n";
      next;
    }
    my $url = $line;
    my $channel_dir = "$root_dir/$channel_name";
    my $archive_path = "$channel_dir/.yt-dlp-download-archive";

    if (-e $channel_dir) {
      system "yt-dlp -f bestvideo+bestaudio -S 'res:$video_resolution' --embed-metadata --embed-subs --embed-thumbnail --download-archive \"$archive_path\" -P \"$channel_dir\" \"$url\"";
    } else {
      system "mkdir -p $channel_dir";
      if ($?) {
        print "Err: couldnt create dir $channel_dir\n";
        next;
      }
      # Don't fetch new videos, only mark all as fetched
      print "Fetch video ids of channel $channel_name and marking them as watched.\n";
      system "yt-dlp --get-id --flat-playlist \"$url\" --download-archive \"$archive_path\"| sed 's/^/youtube /' > $archive_path";
    }
  }
  close $fh;
}

fetch_all();
