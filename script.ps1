# This script reads the content of app_idea.md, GEMINI.md, and engineering_philosophy.md and writes it to context.md.

$app_idea = Get-Content -Path .\app_idea.md -Raw
$gemini = Get-Content -Path .\GEMINI.md -Raw
$engineering_philosophy = Get-Content -Path .\engineering_philosophy.md -Raw

$concatenated_content = $app_idea + "`n" + $gemini + "`n" + $engineering_philosophy

Set-Content -Path .\context.md -Value $concatenated_content
