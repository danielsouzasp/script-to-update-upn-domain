<#  
  .Descrição
  Valida se o SMTP principal no ProxyAddresses está igual ao endereço de e-mail principal
  
  .Como utilizar  
   ValidarSMTPv1 -CSVFile c:\temp\usuarios.csv

  .Exemplo de CSV
  usuario
  teste1.conta
  teste2.conta

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
            $usuario = Get-ADuser -Identity $u.usuario -Properties ProxyAddresses, mail -ErrorAction Stop #Pega info do usuario

			Write-Host "######################### Validando a conta $($usuario.SamAccountName) #########################" -BackgroundColor DarkGray
			
			$loginEmail = $usuario.mail.split('@')[0] #Usuario atual do campo mail antes do @
			Write-Host ">> SamAccountName:" -BackgroundColor DarkGray -NoNewline
			Write-Host " $($usuario.SamAccountName) " -BackgroundColor DarkMagenta -NoNewline
			Write-Host "Login do e-mail:" -BackgroundColor DarkGray -NoNewline
			Write-Host " $($loginEmail)" -BackgroundColor DarkMagenta
			Write-Host ">> Campo e-mail:" -BackgroundColor DarkGray -NoNewline
			Write-Host " $($usuario.mail)" -BackgroundColor DarkMagenta 
			Write-Host ">> ProxyAddresses:" -BackgroundColor DarkGray -NoNewline
			Write-Host " $($usuario.ProxyAddresses)" -BackgroundColor DarkMagenta
			
			$atualSMTP = "SMTP:"+$usuario.mail #SMTP atual baseado no email
			Write-Host ">> Procurando o SMTP principal:" -BackgroundColor DarkGray -NoNewline 
			Write-Host " $($atualSMTP)" -BackgroundColor DarkMagenta
			
			if($usuario.ProxyAddresses){ #Se o ProxyAddresses for válido(não vazio)
			
			  if($usuario.ProxyAddresses -clike $atualSMTP){ #Se o SMTP principal esperado está no ProxyAddresses #clike é CaseSensitive
			  Write-Host ">> Resultado: o SMTP principal da conta $($usuario.SamAccountName) esta de acordo com o e-mail"	-BackgroundColor DarkGreen
			  } else { 
			      Write-Host ">> Resultado: o SMTP principal da conta $($usuario.SamAccountName) esta divergente do e-mail" -BackgroundColor DarkRed
				  #Write-Output $usuario.SamAccountName >> C:\usuario-com-erro.txt
			    }#else	
				 
			} else { #Senão, sigifica que o ProxyAddresses está vazio
				Write-Host ">> Resultado: o ProxyAddresses da conta $($usuario.SamAccountName) esta vazio" -BackgroundColor DarkBlue
				
			  }#else
			
        } #Try
        catch {
            Write-Host "Erro encontrado ao processar a conta $($u.usuario)" -BackgroundColor DarkRed
        }
    }

} #Process
