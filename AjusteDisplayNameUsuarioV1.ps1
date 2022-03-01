<#  
  .Descrição
  Atualiza Display Name de um usuário do AD
  
  .Como utilizar  
   AjusteDisplayNameUsuarioV1 -ArquivoCSV c:\temp\usuarios.csv   

  .Exemplo de CSV
  "usuario"
  "teste1.conta"
  "teste2.conta"

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
            $usuario = Get-ADuser -Identity $u.usuario -Properties DisplayName -ErrorAction Stop #Pega info do usuario
            Write-Host ">> A conta $($usuario.SamAccountName) existe com o DisplayName $($usuario.DisplayName)" -BackgroundColor DarkGray
			
			$novoDisplayName = $usuario.DisplayName+" - Sua Empresa" #
			
			#Começa a bagaça....
			Write-Host ">> Adicionando novo DisplayName como $($novoDisplayName)" -BackgroundColor DarkGreen
			#Set-ADuser -Identity $u.usuario -DisplayName $novoDisplayName
        } #Try
        catch {
            Write-Host "Erro, a conta $($u.usuario) nao existe" -BackgroundColor DarkRed
        }
    }

} #Process
