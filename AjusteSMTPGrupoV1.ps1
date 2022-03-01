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
            $grupo = Get-ADGroup -Identity $g.SamAccountName -Properties mail -ErrorAction Stop #Pega o campo Name do CSV
            Write-Host ">> Processando o grupo $($grupo.SamAccountName) com e-mail $($grupo.mail)" -BackgroundColor DarkGray
			
			$loginEmail = $grupo.mail.split('@')[0] #pegando o login do endereço de e-mail
			
			$atualSMTP = "SMTP:"+$grupo.mail #SMTP atual baseado no email
			$aliasSMTP = "smtp:"+$grupo.mail #Passa pra minúsculo
			$novoSMTP = "SMTP:"+$loginEmail+"@dominio1.com.br" #cria novo SMTP baseado no e-mail atual
			
			#Começa a bagaça....
			Write-Host ">> Removendo o SMTP principal $($atualSMTP)" -BackgroundColor DarkMagenta
			Set-ADGroup -Identity $grupo.SamAccountName -Remove @{ProxyAddresses=$atualSMTP} 
			Write-Host ">> Readicionando $($aliasSMTP) como secundário" -BackgroundColor DarkBlue
            Set-ADGroup -Identity $grupo.SamAccountName -Add @{Proxyaddresses=$aliasSMTP}
			Write-Host ">> Adicionando novo SMTP principal $($novoSMTP)" -BackgroundColor DarkGreen
			Set-ADGroup -Identity $grupo.SamAccountName -Add @{Proxyaddresses=$novoSMTP}
        } #Try
        catch {
            Write-Host "Erro ao processar o grupo $($g.SamAccountName)" -BackgroundColor DarkRed
        }
    } 
    

} #Process
