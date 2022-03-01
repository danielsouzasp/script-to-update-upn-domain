<#  
 .Descrição
 Atualiza o domínio das contas no Office 365
  
 .Como utilizar 
 1. Conectar no Office365 com conta admin: Connect-MsolService  
 2. AjusteDominioOffice365v1 -CSVFile c:\temp\usuarios.csv   

 .Exemplo de CSV
 emailatual
 teste1@dominio1.com.br
 teste2@dominio1.com.br
 teste3@dominio1.com.br

  #> 

#requires -Version 3   
[CmdletBinding()]
param(  
    [Parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$true)]
    [alias('ArquivoCSV')]
    [String]$Path) #param
Begin {  
    Import-Module MSOnline #módulo do O365
} #Begin

Process {
    $usuarios = Import-Csv -Path $Path
	
	#Connect-MsolService #Solicitar credenciais
	
	if (!$usuarios){Write-Host "Arquivo CSV invalido" -BackgroundColor DarkRed} #Se o arquivo não tiver a variável
	
    Foreach ($u in $usuarios) {
        Try {
			$usuario = Get-MsolUser -UserPrincipalName $u.emailatual -ErrorAction Stop | Select-Object UserPrincipalName #Consulta usuario no O365
			
            Write-Host "Conta $($u.emailatual) encontrada no Office365" -BackgroundColor DarkGreen
			
			$loginEmail = $u.emailatual.split('@')[0] #Usuario atual do campo mail antes do @
			$novoEmail = $loginEmail+"@dominio2.com.vc"
			
			Write-Host "Alterando $($u.emailatual) para $($novoEmail)" -BackgroundColor DarkBlue		
			Set-MsolUserPrincipalName -UserPrincipalName $u.emailatual -NewUserPrincipalName $novoEmail
			
        } #Try
        catch {
            Write-Host "Erro ao processar a conta $($u.emailatual)" -BackgroundColor DarkRed
        }
    }

} #Process
