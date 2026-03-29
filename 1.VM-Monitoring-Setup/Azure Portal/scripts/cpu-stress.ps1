param(
  [int]$Threads = 1,           # 1 vCPU -> usar 1 hilo
  [int]$DurationSeconds = 300  # 5 minutos = 300s
)

$scriptBlock = {
    param($stopTime)
    while ((Get-Date) -lt $stopTime) {
        # operación matemática intensiva para consumir CPU
        for ($i=0; $i -lt 10000; $i++) {
            $x = [math]::Sqrt((Get-Random -Minimum 1 -Maximum 1000000) * (Get-Random -Minimum 1 -Maximum 1000000))
        }
    }
}

$stopTime = (Get-Date).AddSeconds($DurationSeconds)
$jobs = @()
for ($i=1; $i -le $Threads; $i++) {
    $jobs += Start-Job -ScriptBlock $scriptBlock -ArgumentList $stopTime
}

Write-Output "Carga iniciada: $Threads hilo(s) por $DurationSeconds segundos. Jobs: $($jobs.Count)"
$jobs | Wait-Job
Write-Output "Carga finalizada."
