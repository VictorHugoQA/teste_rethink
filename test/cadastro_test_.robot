*** Settings ***
Resource    ../resources/keywords.robot
Suite Setup       Gerar Dados De Cadastro

*** Test Cases ***
Limpar logs anterior
    Limpar Logs Anteriores
Confirmar Email Com Sucesso
    Gerar Dados De Cadastro
    Fazer Requisição De Cadastro
    Confirmar Email Com Token
    Set Suite Variable    ${cpf_destinatario}    ${cpf}
Login Com Sucesso
    Fazer Requisição De Login
Enviar pontos para Usuario
   Enviar Pontos Para Outro Usuario    ${cpf_destinatario}
Consulta extrato de pontos 
    Consultar Extrato De Pontos
Depositar pontos na caixinha 
     Depositar Pontos Na Caixinha
Deletar Conta Com Sucesso
    Deletar Conta
