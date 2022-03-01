<#  
  .Descrição
  Atualizar o SIP do Proxyaddresses baseado no campo mail usando como parâmetro um arquivo CSV com o login do usuário
  
  .Como utilizar  
   AjusteSIP-v1 -CSVFile c:\temp\usuarios.csv   

  .Exemplo de CSV
  "SamAccountName","email"
  "teste6.conta","teste6.conta@dominio1.com.br"
  "teste7.conta","teste7.conta@dominio1.com.br"

  .Exemplo de saída
  
 
  #> 

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
    $usuarios = Import-Csv -Path $Path
	
	if (!$usuarios){Write-Host "Arquivo CSV invalido" -BackgroundColor DarkRed} #Se o arquivo não tiver a variável
	
    Foreach ($u in $usuarios) {
        Try {
            $usuario = Get-ADuser -Identity $u.usuario -Properties mail -ErrorAction Stop #Pega info do usuario
            Write-Host ">> A conta $($usuario.SamAccountName) existe, processando ajustes do SIP no Proxyaddresses" -BackgroundColor DarkGray
			
			$loginEmail = $usuario.mail.split('@')[0] #Usuario atual do campo mail antes do @
						
			$atualSIP = "SIP:"+$usuario.mail #SIP atual baseado no email
			$aliasSIP = "SIP:"+$usuario.mail #Passa pra minúsculo
			$novoSIP = "SIP:"+$loginEmail+"@dominio2.com.br" #cria novo SIP baseado no e-mail atual
			
			#Começa a bagaça....
			Write-Host ">> Removendo SIP atual $($atualSIP)" -BackgroundColor DarkGreen
			Set-ADuser -Identity $u.usuario -Remove @{ProxyAddresses=$atualSIP} 
			Write-Host ">> Adicionando novo SIP $($novoSIP)" -BackgroundColor DarkGreen
			Set-ADuser -Identity $u.usuario -Add @{Proxyaddresses=$novoSIP}
        } #Try
        catch {
            Write-Host "Erro, a conta $($u.usuario) nao existe" -BackgroundColor DarkRed
        }
    }

} #Process
