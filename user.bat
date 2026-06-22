
@echo off
echo Teste de remoção de usuario da maquina...

powershell -NoProfile -Command "Get-CimInstance Win32_UserProfile | Select-Object LocalPath"

for %%u in (
    aluno
    Professor
) do (
    powershell -NoProfile -Command "Get-CimInstance -ClassName Win32_UserProfile | Where-Object { $_.LocalPath -like '*%%u*' } | Remove-CimInstance"
)

pause
