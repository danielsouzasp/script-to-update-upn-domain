<#  
  .Descrição
  Remove o SMTP principal baseado no campo mail e adiciona como smtp recundário, 
  usando como parâmetro um arquivo CSV com o login e e-mail atual do usuário
  
  .Como utilizar  
   AjusteSMTPUsuarioV1 -ArquivoCSV c:\temp\usuarios.csv   

  .Exemplo de CSV
  "usuario"
  "teste1.dominio1"
  "teste2.dominio1"

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
            Write-Host ">> A conta $($usuario.SamAccountName) existe, processando ajustes de SMTP no Proxyaddresses" -BackgroundColor DarkGray
			
			$loginEmail = $usuario.mail.split('@')[0] #Usuario atual do campo mail antes do @
			
			$atualSMTP = "SMTP:"+$usuario.mail #SMTP atual baseado no email
			$aliasSMTP = "smtp:"+$usuario.mail #Passa pra minúsculo
			$novoSMTP = "SMTP:"+$loginEmail+"@dominio2.com.br" #cria novo SMTP baseado no e-mail atual
			
			#Começa a bagaça....
			Write-Host ">> Removendo SMTP principal $($atualSMTP)" -BackgroundColor DarkMagenta
			Set-ADuser -Identity $u.usuario -Remove @{ProxyAddresses=$atualSMTP} 
			Write-Host ">> Readicionando $($aliasSMTP) como secundário" -BackgroundColor DarkBlue
            Set-ADuser -Identity $u.usuario -Add @{Proxyaddresses=$aliasSMTP}
			Write-Host ">> Adicionando novo SMTP principal $($novoSMTP)" -BackgroundColor DarkGreen
			Set-ADuser -Identity $u.usuario -Add @{Proxyaddresses=$novoSMTP}
        } #Try
        catch {
            Write-Host "Erro, a conta $($u.usuario) nao existe" -BackgroundColor DarkRed
        }
    }

} #Process
