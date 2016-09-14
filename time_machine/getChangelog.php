<?php
if(isset($_GET['modpack'])) {
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
    $modpackName = $modpackJson->{'display_name'};
    $builds = $modpackJson->{'builds'};
    arsort($builds, SORT_NATURAL);
    $builds = array_reverse($builds, true);
    $lastBuildMods = array();
    $buildNr = 1;
    $changelogDisplay = '';
    $topDisplay = '<?php include __DIR__ . \'/../head.php\';
setTitle(\'' . $modpackName . ' Changelog\') ?>
<div class="container">
    <h2>' . $modpackName . ' Changelog</h2>
    <div class="dropdown">
        <button class="btn btn-default dropdown-toggle btn-primary btn-sm" type="button" id="dropdownMenu1"
                data-toggle="dropdown" aria-haspopup="true" aria-expanded="true">
            Choose a Version
            <span class="caret"></span>
        </button>
        <ul class="dropdown-menu" aria-labelledby="dropdownMenu1">
';
    $dropdownDisplay = '';
    foreach ($builds as $build) {
        $dropdownDisplay = '<li><a href="#' . $build . '">' . $build . '</a></li>' . $dropdownDisplay;
    }
    $topDisplay .= $dropdownDisplay;
    $topDisplay .= '</ul></div><br>
        <div class="text-right">
        <a class="btn btn-success btn-sm btn-pad disabled mod_label">Added Mod <span class="badge">Version</span></a>
        <a class="btn btn-info btn-sm btn-pad disabled mod_label">Changed Mod <span class="badge">New Version</span></a>
        <a class="btn btn-danger btn-sm btn-pad disabled mod_label">Removed Mod</a>
        </div>';

    $modData = json_decode(file_get_contents($modsLink, false, stream_context_create($arrContextOptions)));
    foreach ($builds as $build) {
        $versionDisplay = '<hr><div><h3>' . $build . '</h3><a class="anchor" id="' . $build . '"></a>';
        $changelog = array();
        $changelog['added'] = array();
        $changelog['changed'] = array();
        $changelog['removed'] = array();
        $getBuildAPI = file_get_contents($modpackLink . '/' . $build, false, stream_context_create($arrContextOptions));
        $buildJson = json_decode($getBuildAPI);
        $MCVersion = $buildJson->{'minecraft'};
        $versionString = $MCVersion . '_';
        $thisBuildMods = array();
        foreach ($buildJson->{'mods'} as $mod) {
            $thisBuildMods[$modData->{'mods'}->{$mod->{'name'}}] = array();
            $thisBuildMods[$modData->{'mods'}->{$mod->{'name'}}]['version'] = str_replace($versionString, '', $mod->{'version'});
        }

        if ($buildNr === 1) {
            foreach ($thisBuildMods as $mod => $version) {
                $versionDisplay = $versionDisplay . '<a class="btn btn-success btn-sm btn-pad disabled mod_label">' . $mod . ' <span class="badge">' . $version['version'] . '</span></a>';
            }
        } else {
            foreach ($thisBuildMods as $mod => $version) {
                if (!array_key_exists($mod, $lastBuildMods)) {
                    $modname =
                    $versionDisplay = $versionDisplay . '<a class="btn btn-success btn-sm btn-pad disabled mod_label">' . $mod . ' <span class="badge">' . $version['version'] . '</span></a>';
                }
            }
            $versionDisplay .= '<br>';
            foreach ($thisBuildMods as $mod => $version) {
                if (array_key_exists($mod, $lastBuildMods) && $lastBuildMods[$mod]['version'] !== $version['version']) {
                    $versionDisplay = $versionDisplay . '<a class="btn btn-info btn-sm btn-pad disabled mod_label">' . $mod . ' <span class="badge">' . $version['version'] . '</span></a>';
                }
            }
            $versionDisplay .= '<br>';
            foreach ($lastBuildMods as $mod => $version) {
                if (!array_key_exists($mod, $thisBuildMods)) {
                    $versionDisplay = $versionDisplay . '<a class="btn btn-danger btn-sm btn-pad disabled mod_label">' . $mod . '</a>';
                }
            }
        }
        $versionDisplay .= '<br><br><a href="#" class="btn btn-primary btn-sm">Back to Top <i class="fa fa-caret-up"></i></a></div>';
        $lastBuildMods = $thisBuildMods;
        $buildNr++;
        $changelogDisplay = $versionDisplay . $changelogDisplay;
    }
    $changelogDisplay = $topDisplay . $changelogDisplay;
    $changelogDisplay .= '</div><?php include __DIR__ . \'/../footer.php\'; ?>';
    file_put_contents(__DIR__ . '/../' . $modpack . '/changelog.php', $changelogDisplay);
}