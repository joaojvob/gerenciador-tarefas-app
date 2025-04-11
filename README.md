# app_tarefas_frontend

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev) [![Dart](https://img.shields.io/badge/Dart-2.12+-brightgreen.svg)](https://dart.dev)

Um aplicativo Flutter para gerenciamento de tarefas, integrado a uma API RESTful. Permite criar, editar, excluir e visualizar tarefas com uma interface intuitiva e responsiva.

## Sobre o Projeto
Este é o frontend de um sistema de gerenciamento de tarefas desenvolvido com Flutter. Ele se conecta a um backend Laravel via API para oferecer funcionalidades como autenticação de usuários, listagem de tarefas e atualização de perfil.

## Funcionalidades
- **Autenticação**:
  - Login e registro de usuários.
  - Logout seguro com remoção de token local.
- **Gerenciamento de Tarefas**:
  - Criar, editar e excluir tarefas.
  - Listagem de tarefas com ordenação por `ordem`.
  - Sincronização manual com o backend.
- **Interface**:
  - Design responsivo com tema personalizado (gradientes, sombras).
  - Modal interativo para tarefas.
  - Cores indicativas para prioridade (vermelho: alta, laranja: média, verde: baixa).
- **Perfil**:
  - Exibição de nome e email.
  - Atualização de senha.

## Tecnologias
- **Flutter**: 3.0+ (Material 3)
- **Dart**: 2.12+
- **Dependências**:
  - `http: ^1.2.1` - Requisições HTTP.
  - `shared_preferences: ^2.2.3` - Armazenamento local.

## Configuração
### Pré-requisitos
- Flutter SDK instalado ([Guia de Instalação](https://flutter.dev/docs/get-started/install)).
- Emulador Android/iOS ou dispositivo físico.
- Editor (ex.: VS Code ou Android Studio).

### Passos
1. **Clone o Repositório**:
   ```bash
   git clone https://github.com/seu-usuario/app_tarefas_frontend.git
   cd app_tarefas_frontend
