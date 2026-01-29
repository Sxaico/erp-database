# --- Configuración ---
# Nombre del archivo de salida que se creará en el directorio raíz.
$outputFile = "output.txt"

# Lista de directorios que se ignorarán por completo.
$excludedDirs = @(
    'pgdata',
    'appsmith-stacks',
    'node_modules',
    '__pycache__',
    '.vite',
    '.git',      # Se añade .git por si es un repositorio.
    'dist',      # Se añade dist por si hay builds.
    'build'
)

# Lista de extensiones de archivo que se ignorarán.
$excludedExtensions = @(
    '.log',
    '.lock',
    '.svg',
    '.png',
    '.jpg',
    '.jpeg',
    '.gif',
    '.ico'
    '.txt'
)


# --- Comienzo del Script ---

# Limpiar el archivo de salida si ya existe.
if (Test-Path $outputFile) {
    Clear-Content $outputFile
}

Write-Host "Generando listado de archivos en '$outputFile'..."

# Obtener la ruta completa del directorio actual para crear rutas relativas.
$rootPath = (Get-Location).Path
if (-not $rootPath.EndsWith('\')) {
    $rootPath += '\'
}
$rootPathLength = $rootPath.Length

# Obtener todos los archivos de forma recursiva.
Get-ChildItem -Path . -Recurse -File | ForEach-Object {
    $file = $_
    $shouldExclude = $false

    # 1. Comprobar si el archivo está en un directorio excluido.
    foreach ($dir in $excludedDirs) {
        if ($file.FullName -like "*\$dir\*") {
            $shouldExclude = $true
            break
        }
    }

    # 2. Comprobar si la extensión del archivo está excluida (si no fue ya excluido por directorio).
    if (-not $shouldExclude) {
        if ($excludedExtensions -contains $file.Extension) {
            $shouldExclude = $true
        }
    }

    # 3. Excluir el propio archivo de salida.
    if ($file.Name -eq $outputFile) {
        $shouldExclude = $true
    }

    # Si el archivo no debe ser excluido, procesarlo.
    if (-not $shouldExclude) {
        # Obtener la ruta relativa del archivo.
        $relativePath = $file.FullName.Substring($rootPathLength)

        Write-Host "Procesando: $relativePath"

        # Leer el contenido del archivo. Se añade un try-catch por si es un archivo binario.
        $content = ""
        try {
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
        } catch {
            $content = "### ERROR: No se pudo leer el contenido del archivo (posiblemente binario). ###"
        }

        # Crear el bloque de texto con el formato solicitado.
        $outputBlock = @"
$relativePath

$content

---
"@

        # Añadir el bloque al archivo de salida.
        Add-Content -Path $outputFile -Value $outputBlock
    }
}

Write-Host "¡Proceso completado! El archivo '$outputFile' ha sido creado con éxito."