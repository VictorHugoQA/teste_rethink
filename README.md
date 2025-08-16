# Projeto de Testes Automatizados com Robot Framework

Bem-vindo ao repositório do projeto de automação de testes utilizando **Robot Framework**, uma solução robusta, flexível e amplamente adotada para testes de aceitação e automação.

---

## 🚀 Visão Geral

Este projeto visa garantir a qualidade e confiabilidade das aplicações por meio de testes automatizados escritos em Robot Framework, com uma arquitetura modular que facilita a manutenção e escalabilidade.

---

## 📋 Requisitos

- Python 3.6 ou superior  
- Robot Framework (instalado via `pip`)  
- (Opcional) Dependências adicionais listadas em `requirements.txt`

---

## ⚙️ Estrutura do Projeto

.
├── libs/ # Bibliotecas Python personalizadas e externas

├── keywords/ # Keywords customizadas específicas do projeto

├── resources/ # Arquivos resource (.robot, .resource) para reutilização

├── test/ # Casos de teste Robot Framework (.robot)
│
 └── cadastro_test_.robot

├── output/ # Resultados gerados: logs, reports e arquivos XML

├── .gitignore # Arquivos e pastas ignorados pelo Git

├── README.md # Documentação do projeto
└── requirements.txt # Dependências Python do projeto (opcional)


---

## 💻 Instalação e Configuração

Para garantir um ambiente limpo e consistente, recomenda-se o uso de um ambiente virtual Python:

 Crie e ative um ambiente virtual
python -m venv env
source env/bin/activate      # Linux/macOS
env\Scripts\activate         # Windows

# Instale as dependências necessárias
pip install -r requirements.txt

# 🏃‍♂️ Executando os Testes

robot --output output/output.xml --log output/log.html --report output/report.html test/cadastro_test_.robot

# 📊 Resultados dos Testes
Após a execução, você encontrará em output/:

output.xml: arquivo XML com o resumo completo da execução

log.html: log detalhado e navegável da execução

report.html: relatório resumido e visual dos testes executados

# 📦 Controle de Versão - .gitignore

O arquivo .gitignore já está configurado para ignorar arquivos temporários, ambientes virtuais e outputs do Robot Framework.

# Visão Geral

Este documento consolida o escopo de testes, os bugs identificados, a classificação de criticidade e a recomendação sobre prontidão para produção do sistema de pontos e caixinha.

⸻

# Escopo de Teste
	1.	Cadastrar
	2.	Confirmar e-mail
	3.	Realizar login
	4.	Enviar pontos a alguém
	5.	Guardar parte do saldo na caixinha
	6.	Conferir o saldo (pontos, caixinha e total)
	7.	Excluir conta

⸻

# Há bugs? Quais e cenários esperados

Sim, há bugs. Abaixo, os cenários esperados e os problemas observados:
	•	Guardar saldo na caixinha / Resgatar
	•	Esperado: ao guardar um valor (ex.: 30), deve ser possível resgatar qualquer valor ≤ ao saldo guardado (ex.: 10).
	•	Observado: o sistema retorna “saldo insuficiente” ao tentar resgatar 10 mesmo havendo 30 na caixinha.
	•	Consultar saldo de pontos quando o valor é 100
	•	Esperado: ao adicionar 100 pontos, a consulta de saldo deve exibir 100.
	•	Observado: ao adicionar 100 pontos, a consulta exibe 0. Com 50 pontos, o saldo aparece corretamente.

⸻

# Classificação de criticidade
	•	BUG‑001 (Resgate da caixinha reporta saldo insuficiente): Crítico — impacta função financeira central (resgate), bloqueia fluxo essencial e pode gerar chamados e desconfiança no produto.
	•	BUG‑002 (Saldo de pontos exibe 0 quando valor é exatamente 100): Alto — não impede toda a operação, mas causa inconsistência de dados, confusão do usuário e potenciais erros de negócio.

⸻

# Prontidão para Produção

Não recomendado subir para produção enquanto os bugs acima permanecerem abertos. O BUG‑001 afeta diretamente a disponibilidade de valores na caixinha; o BUG‑002 compromete a confiabilidade das consultas de saldo. Ambos precisam ser corrigidos e validados.

⸻

# Bugs Cadastrados

BUG‑001 — Resgate da caixinha retornando “saldo insuficiente”
	•	Severidade: Crítico
	•	Status: Aberto
	•	Componente: Caixinha (depósito/resgate)
	•	Ambiente: (preencher: dev/stage/prod, app/web, versão)
	•	Descrição: Após guardar 30 na caixinha, ao tentar resgatar 10 o sistema retorna “saldo insuficiente”.
	•	Passos para reproduzir:
	1.	Logar com conta válida e confirmada.
	2.	Guardar 30 na caixinha.
	3.	Tentar resgatar 10 da caixinha.
	4.	Observar retorno “saldo insuficiente”.
	•	Resultado esperado: Resgate 10 deve ser permitido quando saldo da caixinha ≥ 10; saldo final: 20.
	•	Resultado obtido: Erro de saldo insuficiente, impedindo resgate.
	•	Hipóteses de causa raiz:
	•	Comparação incorreta (ex.: usando > em vez de >=).
	•	Inconsistência entre saldo “pendente” e saldo “disponível” da caixinha.
	•	Arredondamento/precisão monetária ou tipo numérico inadequado.
	•	Latência/ordem de gravação (reserva x saldo real) ou cache desatualizado.
	•	Workaround conhecido: Nenhum confiável.
	•	Evidências: (anexar prints/logs)

BUG‑002 — Saldo de pontos mostra 0 quando valor é exatamente 100
	•	Severidade: Alto
	•	Status: Aberto
	•	Componente: Pontos (acúmulo/consulta)
	•	Ambiente: (preencher)
	•	Descrição: Ao adicionar 100 pontos, a consulta de saldo retorna 0. Com 50 pontos, o saldo é exibido corretamente.
	•	Passos para reproduzir:
	1.	Logar com conta válida e confirmada.
	2.	Adicionar 100 pontos à conta.
	3.	Acessar a tela/endpoint de saldo de pontos.
	4.	Observar saldo exibindo 0.
	•	Resultado esperado: Saldo deve exibir 100.
	•	Resultado obtido: Saldo exibido 0.
	•	Hipóteses de causa raiz:
	•	Regra de faixa incorreta (ex.: if (saldo < 100) ... else ... com lógica errada).
	•	Overflow/underflow, casting, ou serialização/deserialização com tipo inadequado.
	•	Cache não invalidado após a operação de crédito de 100.
	•	Workaround conhecido: Verificar se operações subsequentes (ex.: adicionar +1 ponto) atualizam o saldo; não resolve a causa.
	•	Evidências: (anexar prints/logs)

⸻

# Checklist de Testes (para revalidação após correções)

# Conta e Acesso
	•	Cadastrar com dados válidos cria conta e dispara e-mail de confirmação.
	•	Link de confirmação ativa a conta e permite login.
	•	Login só funciona com e-mail confirmado e credenciais corretas.

# Pontos
	•	Adicionar 50, 100, 101 e valores limites (0, 1) atualiza e exibe saldo corretamente.
	•	Consultar saldo reflete a última operação sem divergências entre telas/endpoint.
	•	Enviar pontos a outro usuário debita/credita corretamente e registra histórico.

# Caixinha
	•	Guardar valores (10, 30, 100, limites) reduz saldo disponível e aumenta saldo da caixinha.
	•	Resgatar valores ≤ saldo da caixinha funciona; > saldo deve bloquear com mensagem correta.
	•	Saldos (conta, caixinha, total) ficam consistentes após guardar/resgatar.

# Exclusão de Conta
	•	Solicita senha, realiza anonimização/remoção conforme LGPD, impede novo login.


# Riscos e Impactos
	•	Perda de confiança do usuário por inconsistência de saldo (BUG‑002).
	•	Bloqueio de resgates/uso de valores guardados (BUG‑001) com potencial impacto financeiro e suporte.


# Recomendações
	1.	Corrigir BUG‑001 e BUG‑002 com testes unitários e de integração cobrindo limites (0, 1, 50, 100, 101, saldo igual/maior/menor).
	2.	Adicionar testes automatizados para cenários de comparação (>=, == 100) e validação de cache/consistência de leitura.
	3.	Habilitar logs de auditoria nas operações de crédito/débito e no cálculo/consulta de saldo.
	4.	Revalidar em ambiente de homologação com dados limpos e repetir o checklist.


# Status de Prontidão
	•	Atual: Não pronto para produção devido aos bugs de alta criticidade.
	•	Critério para liberar: Correções aplicadas, testes passando e checklist revalidado sem regressões.

# Histórico
	•	2025‑08‑15: Primeira consolidação de bugs e recomendação de não-liberação.