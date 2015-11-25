<?php

$catpath = "sshjump";
$mainlist = "sshjump/device_categories";
$data = file($mainlist);

echo '<html><body>';
echo 'Select device category: <form method="get">';
echo '<select onchange="submit()" name="sshcat">';
echo '<option value=""></option>';
// output data
foreach($data as $datakey => $line) {

  // skip empty rows
  if (trim($line) == '') continue;
  if (preg_match("/#/", trim($line))) continue;
  $line = trim($line, "\n");
    echo '<option value="'.$catpath.'/'.$line.'">'.$line.'</option>';
  }
echo '</select>';
echo '&nbsp; <a href="./">clear</a>';
echo '</form>';


// Database file, i.e. file with real data
$data_file = $_GET["sshcat"];

// Database definition file. You have to describe database format in this file.
// See flatfile.inc.php header for sample.
$structure_file = 'sshjump.def';

// Fields delimiter
$delimiter = '|';

// Number of header lines to skip. This is needed if you have some heder saved in the 
// database file, like comment or description
$skip_lines = 0;

// run flatfile manager
include ('flatfile.inc.php');

?>
