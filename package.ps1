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
@("poof", "digup") | ForEach-Object {
    $variantKey = $_
    $variantName = (Get-Culture).TextInfo.ToTitleCase($variantKey)

    Format-Template <# Datapack #> `
        -TemplatePath "meta/pack.mcmeta" -OutputPath "build/$variantKey/pack.mcmeta" `
        -Variables @{
            version = $Version
            variant = $variantName
            pack_format = "15"
            max_pack_format = "48"
        }

    Format-Template <# Neoforge #> `
        -TemplatePath "meta/META-INF/neoforge.mods.toml" -OutputPath "build/$variantKey/META-INF/neoforge.mods.toml" `
        -Variables @{
            version = $Version
            variant = $variantName
        }

    Format-Template <# Fabric #> `
        -TemplatePath "meta/fabric.mod.json" -OutputPath "build/$variantKey/fabric.mod.json" `
        -Variables @{
            version = $Version
            variant = $variantName
        }

    Copy-Item -Force `
        -Path (Join-Path $PSScriptRoot "meta/pack.png") `
        -Destination (Join-Path $PSScriptRoot "build/$variantKey/pack.png")

    # copy shared files
    $shared = Join-Path $PSScriptRoot "shared"
    $SharedFiles = Get-ChildItem -Path $shared # all top level copied as is
    foreach ($file in $SharedFiles) {
        Copy-Item -Path $file.FullName -Destination (Join-Path "build/$variantKey/data" $file.Name) -Force -Recurse
    }
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
        Remove-Item $OutputDir -Force -ErrorAction Stop
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
