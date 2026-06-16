param(
    [Parameter(Mandatory)]
    [string]$Version,

    [string]$Name = "SpawnAnimsCobblemonCompat",
    [string]$SrcPath = (Join-Path $PSScriptRoot "src")
)

@('build', 'dist') | ForEach-Object {
    Remove-Item -Path (Join-Path $PSScriptRoot $_) -Recurse -Force -ErrorAction Ignore
}

$digup = Join-Path $SrcPath "digup"
$poof = Join-Path $SrcPath "poof"

function Format-Template {
    param(
        [Parameter(Mandatory)]
        [string]$TemplatePath,

        [Parameter(Mandatory)]
        [string]$OutputPath,

        [Parameter(Mandatory)]
        [hashtable]$Variables
    )
    $Content = Get-Content -Path $TemplatePath -Raw
    foreach ($Key in $Variables.Keys) {
        $Value = [string]$Variables[$Key]
        # Supports {{version}}
        #$Content = $Content.Replace("{{$Key}}", $Value)

        # Supports ${version}
        $Content = $Content.Replace('${' + $Key + '}', $Value)
    }
    $OutDir = Split-Path -Parent $OutputPath
    if ($OutDir) {
        New-Item -ItemType Directory -Force $OutDir | Out-Null
    }
    Set-Content -Path $OutputPath -Value $Content -Encoding UTF8 -Force
}

# Build out the template variables
@("Poof", "Digup") | ForEach-Object {
    $variant = $_

    Format-Template <# Datapack #> `
        -TemplatePath "meta/pack.mcmeta" -OutputPath "build/$variant/pack.mcmeta" `
        -Variables @{
            version = $Version
            variant = $variant
            pack_format = "15"
            max_pack_format = "48"
        }

    Format-Template <# Neoforge #> `
        -TemplatePath "meta/META-INF/neoforge.mods.toml" -OutputPath "build/$variant/META-INF/neoforge.mods.toml" `
        -Variables @{
            version = $Version
            variant = $variant
        }

    Format-Template <# Fabric #> `
        -TemplatePath "meta/fabric.mod.json" -OutputPath "build/$variant/fabric.mod.json" `
        -Variables @{
            version = $Version
            variant = $variant
        }

    Copy-Item -Path (Join-Path $PSScriptRoot "meta/pack.png") -Destination (Join-Path $PSScriptRoot "build/$variant/pack.png") -Force -ErrorAction Stop
}

# Copy repo files to the build directories
foreach ($path in @($digup, $poof)) {
    $files = Get-ChildItem -Path $path -Recurse -File
    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($path.Length).TrimStart('\', '/')
        $destPath = Join-Path "build" (Join-Path (Split-Path -Leaf $path) $relativePath)

        $destDir = Split-Path -Parent $destPath
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null

        Copy-Item -Path $file.FullName -Destination $destPath -Force
    }

    $repofiles = @("LICENSE", "README.md")
    foreach ($repofile in $repofiles) {
        $srcFile = Join-Path $PSScriptRoot $repofile
        if (Test-Path $srcFile) {
            $destFile = Join-Path "build" (Join-Path (Split-Path -Leaf $path) $repofile)
            Copy-Item -Path $srcFile -Destination $destFile -Force
        }
    }
}

function Compress-Directory {
    param(
        [Parameter(Mandatory)]
        [string]$SourceDir,

        [Parameter(Mandatory)]
        [string]$OutputDir # w/ extension (.jar/.zip)
    )
    try { [System.IO.Compression.ZipFile] | out-null } catch { Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop }
    if (Test-Path $OutputDir) {
        Remove-Item $OutputDir -Force
    }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDir, $OutputDir)
    return Get-Item -Path $OutputDir -Force
}

New-Item -ItemType Directory -Path "dist" -Force | Out-Null

# package mods
$poofMod = Compress-Directory -SourceDir "build/poof" -OutputDir "dist/$Name-poof_$Version+mod.jar"
$digupMod = Compress-Directory -SourceDir "build/digup" -OutputDir "dist/$Name-digup_$Version+mod.jar"

# package datapacks
$poofDatapack = Compress-Directory -SourceDir "build/poof" -OutputDir "dist/$Name-poof_$Version.zip"
$digupDatapack = Compress-Directory -SourceDir "build/digup" -OutputDir "dist/$Name-digup_$Version.zip"

return @(
    $digupMod,
    $poofMod,
    $poofDatapack,
    $digupDatapack
)
