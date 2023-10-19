# Root directory for content
my $youtube_home = "$ENV{HOME}/Videos/youtube";
`mkdir -p $youtube_home`;
# Metadata files path for this script
my $metadata_dir = "$youtube_home/.meta";
`mkdir -p $metadata_dir`;
# Urls to channels to subscribe
my $subs_file = "$metadata_dir/.subscriptions";
`touch $subs_file`;

sub get_channel_name {
  my $url = shift or die;
  $url =~ s/.+\/@?//;
  return $url;
}

my $cmd = shift or die("Invalid command.");
for ($cmd) {
  # Subscribe to new channel, pass URL to channel withouts any additional params
  if (/^add/) {
    my $channel_url = shift or die("Channel url required.");

    my $current_subs = `cat $subs_file`;
    die("Channel already subbed!") if ($current_subs =~ /$channel_url/);

    open my $fh, ">", $subs_file or die("Could not open subscriptions file. $!");
    printf $fh $current_subs.$channel_url."\n";
    close $fh;

    printf "Channel $channel_url added to $subs_file\n";
  } 
  # Marks every video in all channels as watched
  elsif (/^mark-all-watched/) {
    printf "Marking all as watched.\n";
    my $urls_str = `cat $subs_file`;
    my @urls = split /\n/ , $urls_str;
    my $tmp_file = "$metadata_dir/.tmp";

    for my $url (@urls) {
      system "touch $tmp_file" and die();

      my $channel_name = get_channel_name($url);
      system "yt-dlp --flat-playlist -i --print-to-file url $tmp_file $url" and die("Yt-dlp err. $!");

      my @tmp_content = `cat $tmp_file`;
      my $result = "";
      my $vid_id = "";
      for (@tmp_content) {
        $_ =~ /(.{11})$/;
        $vid_id = $1;
        $result .= "youtube $vid_id\n";
      }

      my $archive_file = "$metadata_dir/.$channel_name";
      system "touch $archive_file" and die($!);
      open my $fh, ">", $archive_file or die("Could not open archive file. $!");
      printf $fh $result;
      close $fh;

      system "rm $tmp_file" and die();
    }
  }
  # Download new videos
  elsif (/^fetch/) {
    printf "Fetching new videos.\n";
    my @urls = `cat $subs_file`;
    for (@urls) { 
      chomp;
      my $channel_name = get_channel_name($_);
      my $archive_file = "$metadata_dir/.$channel_name"; # DUP
      my $channel_dir = "$youtube_home/$channel_name";

      system "yt-dlp -f bestvideo+bestaudio --embed-metadata --embed-subs --embed-thumbnail --write-comments --download-archive $archive_file -P $channel_dir $_";
    }
  }
}
