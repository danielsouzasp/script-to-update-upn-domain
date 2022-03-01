# .\AjusteSMTPGruposV1.ps1 -ArquivoCSV .\grupos.csv
#O arquivo CSV só precisa do campo "SamAccountName" 
#requires -Version 3   
[CmdletBinding()]
param(  
    [Parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$true)]
    [alias('ArquivoCSV')]
    [String]$Path) #param
Begin {  
    Import-Module ActiveDirectory
} #Begin

Process {
    $grupos = Import-Csv -Path $Path
	
	if (!$grupos){Write-Host "Arquivo CSV invalido" -BackgroundColor DarkRed} #Se o arquivo não tiver a variável
	
    Foreach ($g in $grupos) {
        Try {
            $grupo = Get-ADGroup -Identity $g.SamAccountName -Properties mail  -ErrorAction Stop #Pega o campo Name do CSV
            Write-Host ">> Processando o grupo $($grupo.SamAccountName) com e-mail $($grupo.mail)" -BackgroundColor DarkGray
			
			$loginMail = $grupo.mail.split('@')[0] #pegando o login do endereço de e-mail
			
			$novoMail = $loginMail+"@dominio2.com.br" #cria novo SMTP baseado no e-mail atual
			
			#Começa a bagaça....
			Write-Host ">> Adicionando novo email principal $($novoMail)" -BackgroundColor DarkGreen
			Set-ADGroup -Identity $grupo.SamAccountName  -Replace @{mail=$novoMail}
        } #Try
        catch {
            Write-Host "Erro ao processar o grupo $($g.SamAccountName)" -BackgroundColor DarkRed
        }
    } 
    

} #Process
