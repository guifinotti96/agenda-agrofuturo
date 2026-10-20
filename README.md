# Agenda Agrofuturo com login (Supabase)

Esta pasta é o sistema completo: tela de login, cada usuário com a própria agenda e a conta mestre `guifinotti96@gmail.com` vendo tudo.

| Arquivo | O que é |
|---|---|
| `index.html` | O sistema (login, dashboard, clientes, agenda, funis, relatórios, configurações) |
| `config.js` | Onde você cola os dados do seu projeto Supabase |
| `logo.webp` | Logo da Agrofuturo |
| `supabase.sql` | Cria as tabelas e as regras de acesso no banco |

## 1 e 2. Banco criado e ligado (já feito)

O projeto **Agenda Agrofuturo** (região São Paulo) já existe no Supabase, dentro da organização AgroAgenda AI, com as tabelas, as regras de acesso e o funil padrão. O `config.js` já está preenchido com o endereço e a chave pública desse projeto. O `supabase.sql` fica aqui como registro do que foi criado.

## 3. Colocar no ar (Netlify, grátis)

1. Entre em https://app.netlify.com/drop.
2. Arraste esta pasta inteira para a página.
3. O Netlify gera um link como `https://agrofuturo-xyz.netlify.app`. Esse é o endereço do sistema.

## 4. Ajustar o login no Supabase

1. Em **Authentication > URL Configuration**, coloque o link do Netlify em **Site URL** e também em **Redirect URLs**.
2. Em **Authentication > Sign In / Providers > Email**, deixe **Confirm email** ligado. Isso garante que só quem tem acesso ao e-mail `guifinotti96@gmail.com` vira conta mestre.
3. Crie a sua conta primeiro: abra o link, clique em **Criar conta** com `guifinotti96@gmail.com` e confirme pelo e-mail.

## Como funciona o acesso

- Cada usuário cria a conta na tela de login e só vê os próprios clientes, compromissos e dados.
- A conta mestre vê todos, escolhe no topo de qualquer tela qual usuário quer ver e pode passar um cliente para outro usuário pelo campo **Responsável**.
- Os funis são da empresa: todos usam, só a conta mestre cria ou edita.
- Para trocar o e-mail da conta mestre, altere em `config.js` e na primeira função do `supabase.sql` (rode o SQL de novo).
