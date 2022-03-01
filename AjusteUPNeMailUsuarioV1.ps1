<#  
  .Descrição
  Atualiza o UserPrincipalName e campo Mail para @dominio2.com.br
  
  .Como utilizar  
   AjusteUPNeMailUsuarioV1.ps1 -ArquivoCSV c:\temp\usuarios.csv   

  .Exemplo de CSV
  usuario
  teste1.dominio1
  teste2.dominio1
  teste3.dominio1  
 
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
            Write-Host ">> A conta $($usuario.SamAccountName) existe, processando ajustes..." -BackgroundColor DarkGray
			
			$loginEmail = $usuario.mail.split('@')[0] #Usuario atual do campo mail antes do @
			
			$novoMail = $loginEmail+"@dominio2.com.br" #Altera o domínio para dominio2.com.br
			$novoUPN = $usuario.SamAccountName+"@dominio2.com.br" #Altera o domínio para dominio2.com.br
			
			
			#Começa a bagaça....
			Write-Host ">> Atualizando o mail para $($novoMail)" -BackgroundColor DarkMagenta
			Set-ADuser -Identity $u.usuario -EmailAddress $novoMail
			Write-Host ">> Atualizando UPN para $($novoMail)" -BackgroundColor DarkBlue
            Set-ADuser -Identity $u.usuario -UserPrincipalName $novoUPN

        } #Try
        catch {
            Write-Host "Erro, a conta $($u.usuario) nao existe" -BackgroundColor DarkRed
        }
    }

} #Process
