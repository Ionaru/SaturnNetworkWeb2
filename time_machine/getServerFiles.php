<?php
function getServerDownloads($modpackName, $prettyModpackName)
{
    echo '<div class="container"><hr><h3 class="text-center">' . $prettyModpackName . ' Server Downloads</h3>';
    if (isset($_SERVER['HTTP_USER_AGENT'])) {
        $agent = $_SERVER['HTTP_USER_AGENT'];
        if (strlen(strstr($agent, 'Firefox')) > 0) {
            echo '<p class="text-center">When asked for a password, just click OK</p>';
        }
    }
    echo '<br><table class="table table-hover" style="width:100%" data-sort-name="id" data-sort-order="desc">';
    echo '<thead><tr><th>Version</th><th>Package size</th><th class="text-right">Download</th></tr>';
    $ftp = ftp_connect('85.25.237.10');
    ftp_login($ftp, 'serverfiles', '');
    $files = ftp_nlist($ftp, $modpackName . '/');
    $versionNrs = array();
    foreach ($files as $version) {
        $versionNr = substr(strrchr($version, '_'), 1);
        $versionNr = substr($versionNr, 0, -4);
        $versionNrs[] = $versionNr;
    }
    arsort($versionNrs, SORT_NATURAL);
    $c = 0;
    foreach ($versionNrs as $versionNr) {
        $fileLink = $modpackName . '/' . $modpackName . '_Server_' . $versionNr . '.zip';
        if ($c === 0) {
            echo '<tr class="success">';
            echo '<td>' . $versionNr . ' - Latest</td>';
        } else {
            echo '<tr>';
            echo '<td>' . $versionNr . '</td>';
        }
        $sizeBytes = ftp_size($ftp, $fileLink);
        $sizeKiloBytes = $sizeBytes / 1024;
        $sizeMegaBytes = $sizeKiloBytes / 1024;
        echo '<td>' . round($sizeMegaBytes, 2) . ' MB</td>';
        echo '<td class="text-right">
              <a class="btn btn-primary btn-xs" href="ftp://serverfiles@85.25.237.10/' . $fileLink . '">
              <i class="fa fa-download"></i> Forge Server</a></td>';
        echo '</tr>';
        $c++;
    }
    if (count($versionNrs) === 0) {
        echo '<tr>';
        echo '<td></td>';
        echo '<td>No server files found.</td>';
        echo '<td></td>';
        echo '</tr>';
    }
    ftp_close($ftp);
    echo '<p class="text-right">Tip: check out these amazing projects to improve your server!<br>
<a href="https://tcpr.ca/downloads/mcpc" class="btn btn-default btn-xs"><i class="fa fa-external-link"></i> MCPC+ (up to 1.7.2)</a> 
<a href="https://gitlab.prok.pw/KCauldron/KCauldron" class="btn btn-default btn-xs"><i class="fa fa-external-link"></i> KCauldron (1.7.10)</a> 
<a href="https://www.spongepowered.org/" class="btn btn-default btn-xs"><i class="fa fa-external-link"></i> Sponge (1.8 and up)</a></p></thead></table></div>';
}