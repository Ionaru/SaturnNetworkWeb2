<?php
$modpack = $_GET['modpack'];
$arrContextOptions = array(
    'ssl' => array(
        'verify_peer' => false,
        'verify_peer_name' => false,
    ));
$APILink = 'https://solder.saturnserver.org/index.php/api/';
$modpackLink = $APILink . 'modpack/' . $modpack;
$modsLink = $APILink . 'mod/';
$getAPI = file_get_contents($modpackLink, false, stream_context_create($arrContextOptions));
$modpackJson = json_decode($getAPI);
$latestVersion = $modpackJson->{'latest'};
$getVersionAPI = file_get_contents($modpackLink . '/' . $latestVersion, false, stream_context_create($arrContextOptions));
$versionJson = json_decode($getVersionAPI);
$MCVersion = $versionJson->{'minecraft'};
$versionString = $MCVersion . '_';
$x = 0;
echo '<p>Latest version: ' . $latestVersion . ' for Minecraft ' . $MCVersion . '</p>';
echo '<table class="table table-hover table-responsive table-condensed sortable" style="width:100%; table-layout: fixed;">';
echo '<thead>';
echo '<tr>';
echo '<th class="text-left">Mod Name</th>';
echo '<th class="text-left">Author</th>';
echo '<th class="text-left">Version</th>';
echo '<th class="text-right">Link</th>';
echo '</tr>';
echo '<tbody>';
$mods = $versionJson->{'mods'};
$modNames = array();
$modVersions = array();
$prettyNames = array();
$authors = array();
$links = array();
foreach ($mods as $mod) {
    $getModAPI = file_get_contents($modsLink . $mod->{'name'}, false, stream_context_create($arrContextOptions));
    $modVersion = str_replace($versionString, '', $mod->{'version'});
    $modJson = json_decode($getModAPI);
    $prettyName = $modJson->{'pretty_name'};
    $author = $modJson->{'author'};
    $modLink = $modJson->{'link'};
    echo '<tr>';
    echo '<td class="text-left">' . $prettyName . '</td>';
    echo '<td class="text-left">' . $author . '</td>';
    echo '<td class="text-left">' . $modVersion . '</td>';
    switch (!false) {
        case strpos($modLink, 'minecraftforum'):
            $linkType = 'Minecraft Forum';
            break;
        case strpos($modLink, 'curseforge'):
            $linkType = 'Curse';
            break;
        case strpos($modLink, 'curse.com'):
            $linkType = 'Curse';
            break;
        case strpos($modLink, 'github'):
            $linkType = 'GitHub';
            break;
        case strpos($modLink, 'forum.industrial'):
            $linkType = 'IC2 Forum';
            break;
        default:
            $linkType = 'Mod Website';
            break;
    }
    echo '<td class="text-right"><a class="btn btn-primary btn-xs" href="' . $modLink . '" target="_blank" rel="external"><i class="fa fa-external-link"></i> ' . $linkType . '</a></td>';
    echo '</tr>';
}
echo '<tbody>';
echo '</thead>';
echo '</table>';