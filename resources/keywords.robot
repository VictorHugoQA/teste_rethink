*** Settings ***
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           ../libs/data_generator.py
Library           json

*** Variables ***
${BASE_URL}       https://points-app-backend.vercel.app

*** Keywords ***

Limpar Logs Anteriores
    Remove File    output.xml
    Remove File    log.html
    Remove File    report.html

Logar Requisicao e Resposta Completa
    [Arguments]    ${metodo}    ${endpoint}    ${headers}    ${body_enviado}    ${response}
    ${body_json}=         Evaluate    json.dumps(${body_enviado}, indent=4, ensure_ascii=False)    json
    ${response_json}=     Evaluate    json.dumps(${response.json()}, indent=4, ensure_ascii=False)    json

    Log To Console    \n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Log To Console    📨 [REQUISIÇÃO] ${metodo} ${endpoint}
    Log To Console    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Log To Console    Headers:\n${headers}
    Log To Console    Body:\n${body_json}
    Log To Console    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Log To Console    ✅ [RESPOSTA] Status Code: ${response.status_code}
    Log To Console    Body:\n${response_json}
    Log To Console    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n

Gerar Dados De Cadastro
    ${cpf}=    Generate Cpf
    ${nome}=   Generate Name
    ${email}=  Generate Email    ${nome}
    ${senha}=  Set Variable    Senha@123
    Set Suite Variable    ${cpf}
    Set Suite Variable    ${nome}
    Set Suite Variable    ${email}
    Set Suite Variable    ${senha}

Fazer Requisição De Cadastro
    ${endpoint}=    Set Variable    /cadastro
    Create Session    cadastro    ${BASE_URL}
    &{body}=    Create Dictionary
    ...    cpf=${cpf}
    ...    full_name=${nome}
    ...    email=${email}
    ...    password=${senha}
    ...    confirmPassword=${senha}
    &{headers}=    Create Dictionary    Content-Type=application/json    accept=application/json

    ${response}=   POST On Session      cadastro    ${endpoint}    json=${body}    headers=${headers}
    Logar Requisicao e Resposta Completa    POST    ${endpoint}    ${headers}    ${body}    ${response}

    ${json}=       Set Variable         ${response.json()}
    Should Be Equal As Integers    ${response.status_code}    201
    Should Be Equal As Strings     ${json['message']}         Cadastro realizado com sucesso.
    Should Not Be Empty            ${json['confirmToken']}
    Set Suite Variable             ${confirmToken}            ${json['confirmToken']}

Confirmar Email Com Token
    ${endpoint}=    Set Variable    /confirm-email?token=${confirmToken}
    Create Session    confirmacao    ${BASE_URL}
    &{headers}=       Create Dictionary    accept=text/plain

    ${response}=      GET On Session    confirmacao    ${endpoint}    headers=${headers}

    Log To Console    \n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Log To Console    📩 [RESPOSTA CONFIRMAÇÃO EMAIL]
    Log To Console    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Log To Console    Status Code: ${response.status_code}
    Log To Console    Body:\n${response.text}
    Log To Console    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n

    ${body}=          Set Variable       ${response.text}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal As Strings     ${body}    E-mail confirmado com sucesso.

Fazer Requisição De Login
    ${endpoint}=    Set Variable    /login
    Create Session    login    ${BASE_URL}
    &{body}=    Create Dictionary
    ...    email=${email}
    ...    password=${senha}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    accept=application/json

    ${response}=    POST On Session    login    ${endpoint}    json=${body}    headers=${headers}
    Logar Requisicao e Resposta Completa    POST    ${endpoint}    ${headers}    ${body}    ${response}

    ${status}=      Set Variable       ${response.status_code}
    ${json}=        Set Variable       ${response.json()}
    Should Be Equal As Integers    ${status}    200
    Should Not Be Empty            ${json['token']}
    Set Global Variable            ${login_token}    ${json['token']}
    Log To Console    \n🔐 [INFO] Token de login: ${json['token']}

Enviar Pontos Para Outro Usuario
    [Arguments]    ${cpf_destinatario}    ${quantidade}=100
    ${endpoint}=    Set Variable    /points/send
    Create Session    envio    ${BASE_URL}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    accept=application/json
    ...    Authorization=Bearer ${login_token}
    &{body}=    Create Dictionary
    ...    recipientCpf=${cpf_destinatario}
    ...    amount=${quantidade}

    ${response}=    POST On Session    envio    ${endpoint}    json=${body}    headers=${headers}
    Logar Requisicao e Resposta Completa    POST    ${endpoint}    ${headers}    ${body}    ${response}

    ${json}=        Set Variable       ${response.json()}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal As Strings     ${json['message']}         Pontos enviados com sucesso.
    Log To Console    \n💸 [INFO] Pontos enviados com sucesso para CPF: ${cpf_destinatario}

Deletar Conta
    ${endpoint}=    Set Variable    /account
    Create Session    deletar    ${BASE_URL}
    &{headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    accept=application/json
    ...    Authorization=Bearer ${login_token}
    &{body}=    Create Dictionary
    ...    password=${senha}

    ${response}=    DELETE On Session    deletar    ${endpoint}    json=${body}    headers=${headers}
    Logar Requisicao e Resposta Completa    DELETE    ${endpoint}    ${headers}    ${body}    ${response}

    ${json}=        Set Variable         ${response.json()}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal As Strings     ${json['message']}         Conta marcada como deletada.
    Log To Console    \n🗑️ [INFO] Conta deletada com sucesso.

Consultar Extrato De Pontos
    ${endpoint}=    Set Variable    /points/extrato
    Create Session    extrato    ${BASE_URL}
    &{headers}=    Create Dictionary
    ...    accept=application/json
    ...    Authorization=Bearer ${login_token}

    ${response}=    GET On Session    extrato    ${endpoint}    headers=${headers}
    ${json}=        Set Variable    ${response.json()}

    Logar Requisicao e Resposta Completa    GET    ${endpoint}    ${headers}    {}    ${response}

    Should Be Equal As Integers    ${response.status_code}    200

    ${tamanho}=    Get Length    ${json}
    Should Not Be Equal As Integers    ${tamanho}    0    msg=❌ Nenhum registro retornado no extrato

    ${tem_amount_100}=    Set Variable    False
    FOR    ${item}    IN    @{json}
        ${amount}=    Get From Dictionary    ${item}    amount
        Run Keyword If    '${amount}' == '100'    Set Test Variable    ${tem_amount_100}    True
    END

    Should Be True    ${tem_amount_100}    msg=❌ Nenhum registro com amount = 100 encontrado no extrato

    # Validar campos obrigatórios no primeiro item
    ${primeiro}=    Get From List    ${json}    0
    Dictionary Should Contain Key    ${primeiro}    id
    Dictionary Should Contain Key    ${primeiro}    from_user
    Dictionary Should Contain Key    ${primeiro}    to_user
    Dictionary Should Contain Key    ${primeiro}    amount
    Dictionary Should Contain Key    ${primeiro}    created_at


Depositar Pontos Na Caixinha
    Create Session    points    ${BASE_URL}
    &{headers}=    Create Dictionary
    ...    accept=application/json
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${login_token}

    &{body}=    Create Dictionary
    ...    "amount"=30

    Log To Console    Corpo JSON enviado: ${body}

    TRY
        ${response}=    POST On Session    points    /caixinha/deposit    json=${body}    headers=${headers}
        Logar Requisicao e Resposta Completa    POST    /caixinha/deposit    ${headers}    ${body}    ${response}
        Should Be Equal As Integers    ${response.status_code}    200
        ${json}=    Set Variable    ${response.json()}
        Should Be Equal As Strings    ${json['message']}    Depósito na caixinha realizado.
    EXCEPT    HTTPError
        Log To Console    \n❌ Erro HTTP: ${response.status_code}
        Log To Console    Resposta bruta do erro: ${response.text}
        Fail    Falha na requisição de depósito (HTTP 400): ${response.text}
    END

