/*
  Atividade: Estrutura de banco de dados para jogo de RPG online
  SGBD: Microsoft SQL Server

  Baseado no diagrama ER fornecido na atividade. O diagrama está parcialmente
  cortado na margem direita; os campos visíveis de CLASSES são ClasseId,
  Nome e Descricao (o rótulo aparece parcialmente como "Descri...").

  Observação de segurança: Senha é armazenada como hash, nunca em texto puro.
  A aplicação deve gerar/verificar o hash usando algoritmo apropriado (por
  exemplo, Argon2id, bcrypt ou PBKDF2) e gravar o resultado neste campo.
*/

/* Criação e seleção do banco de dados. */
IF DB_ID(N'RPGOnline') IS NULL
BEGIN
    CREATE DATABASE RPGOnline;
END;
GO

USE RPGOnline;
GO

/*
  As tabelas são criadas somente se ainda não existirem para permitir que o
  script seja executado novamente sem apagar dados existentes.
*/

IF OBJECT_ID(N'dbo.USUARIOS', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.USUARIOS
    (
        UsuarioId INT IDENTITY(1,1) NOT NULL,
        Email NVARCHAR(254) NOT NULL,
        Senha NVARCHAR(255) NOT NULL,
        CONSTRAINT PK_USUARIOS PRIMARY KEY (UsuarioId),
        CONSTRAINT UQ_USUARIOS_Email UNIQUE (Email)
    );
END;
GO

IF OBJECT_ID(N'dbo.CLASSES', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CLASSES
    (
        ClasseId INT IDENTITY(1,1) NOT NULL,
        Nome NVARCHAR(100) NOT NULL,
        Descricao NVARCHAR(500) NULL,
        CONSTRAINT PK_CLASSES PRIMARY KEY (ClasseId),
        CONSTRAINT UQ_CLASSES_Nome UNIQUE (Nome)
    );
END;
GO

IF OBJECT_ID(N'dbo.HABILIDADES', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.HABILIDADES
    (
        HabilidadeId INT IDENTITY(1,1) NOT NULL,
        Nome NVARCHAR(100) NOT NULL,
        CONSTRAINT PK_HABILIDADES PRIMARY KEY (HabilidadeId),
        CONSTRAINT UQ_HABILIDADES_Nome UNIQUE (Nome)
    );
END;
GO

IF OBJECT_ID(N'dbo.PERSONAGENS', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PERSONAGENS
    (
        PersonagemId INT IDENTITY(1,1) NOT NULL,
        NomePersonagem NVARCHAR(100) NOT NULL,
        UsuarioId INT NOT NULL,
        ClasseId INT NOT NULL,
        CONSTRAINT PK_PERSONAGENS PRIMARY KEY (PersonagemId),
        CONSTRAINT FK_PERSONAGENS_USUARIOS
            FOREIGN KEY (UsuarioId) REFERENCES dbo.USUARIOS (UsuarioId),
        CONSTRAINT FK_PERSONAGENS_CLASSES
            FOREIGN KEY (ClasseId) REFERENCES dbo.CLASSES (ClasseId)
    );
END;
GO

IF OBJECT_ID(N'dbo.CLASSES_HABILIDADES', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CLASSES_HABILIDADES
    (
        ClasseId INT NOT NULL,
        HabilidadeId INT NOT NULL,
        CONSTRAINT PK_CLASSES_HABILIDADES
            PRIMARY KEY (ClasseId, HabilidadeId),
        CONSTRAINT FK_CLASSES_HABILIDADES_CLASSES
            FOREIGN KEY (ClasseId) REFERENCES dbo.CLASSES (ClasseId),
        CONSTRAINT FK_CLASSES_HABILIDADES_HABILIDADES
            FOREIGN KEY (HabilidadeId) REFERENCES dbo.HABILIDADES (HabilidadeId)
    );
END;
GO

/* Índices para colunas usadas nas chaves estrangeiras e consultas relacionadas. */
IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PERSONAGENS_UsuarioId'
      AND object_id = OBJECT_ID(N'dbo.PERSONAGENS')
)
BEGIN
    CREATE INDEX IX_PERSONAGENS_UsuarioId ON dbo.PERSONAGENS (UsuarioId);
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_PERSONAGENS_ClasseId'
      AND object_id = OBJECT_ID(N'dbo.PERSONAGENS')
)
BEGIN
    CREATE INDEX IX_PERSONAGENS_ClasseId ON dbo.PERSONAGENS (ClasseId);
END;
GO

/*
  Relacionamentos representados:
  - USUARIOS 1:N PERSONAGENS
  - CLASSES 1:N PERSONAGENS
  - CLASSES N:N HABILIDADES, implementado por CLASSES_HABILIDADES
*/
