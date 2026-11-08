$ErrorActionPreference = 'Stop'

$rootDirectory = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$rootPrefix = [IO.Path]::GetFullPath($rootDirectory).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
$listener = [Net.HttpListener]::new()
$listener.Prefixes.Add('http://127.0.0.1:4173/')
$listener.Start()

Write-Host 'DiskNode local website ready at http://localhost:4173/'

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()

        if ($context.Request.HttpMethod -notin @('GET', 'HEAD')) {
            $context.Response.StatusCode = 405
            $context.Response.Close()
            continue
        }

        $relativePath = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath).TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($relativePath)) {
            $relativePath = 'index.html'
        }

        $relativePath = $relativePath.Replace('/', [IO.Path]::DirectorySeparatorChar)
        $filePath = [IO.Path]::GetFullPath((Join-Path $rootDirectory $relativePath))
        if (-not $filePath.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
            $context.Response.StatusCode = 403
            $context.Response.Close()
            continue
        }

        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
            $context.Response.StatusCode = 404
            $context.Response.Close()
            continue
        }

        $contentType = switch ([IO.Path]::GetExtension($filePath).ToLowerInvariant()) {
            '.css' { 'text/css; charset=utf-8' }
            '.html' { 'text/html; charset=utf-8' }
            '.ico' { 'image/x-icon' }
            '.jpeg' { 'image/jpeg' }
            '.jpg' { 'image/jpeg' }
            '.js' { 'text/javascript; charset=utf-8' }
            '.json' { 'application/json; charset=utf-8' }
            '.pdf' { 'application/pdf' }
            '.png' { 'image/png' }
            '.svg' { 'image/svg+xml' }
            '.txt' { 'text/plain; charset=utf-8' }
            '.webp' { 'image/webp' }
            default { 'application/octet-stream' }
        }

        $bytes = [IO.File]::ReadAllBytes($filePath)
        $context.Response.ContentType = $contentType
        $context.Response.ContentLength64 = $bytes.Length
        if ($context.Request.HttpMethod -eq 'GET') {
            $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        $context.Response.Close()
    }
}
finally {
    $listener.Stop()
    $listener.Close()
    Write-Host 'DiskNode local website stopped.'
}
